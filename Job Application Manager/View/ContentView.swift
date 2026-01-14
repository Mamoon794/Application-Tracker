//
//  ContentView.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2025-12-06.
//

import SwiftUI
import SwiftData



extension Color {
      static let emerald400 = Color(red: 0.06, green: 0.78, blue: 0.53) // example values
      static let emerald500 = Color(red: 0.00, green: 0.70, blue: 0.50)
      static let slate400   = Color(red: 0.56, green: 0.60, blue: 0.67)
      static let slate800   = Color(red: 0.12, green: 0.14, blue: 0.18)
      static let slate300   = Color(red: 0.69, green: 0.73, blue: 0.78)
  }

struct ContentView: View {
    @Query(sort: \Jobs.date, order: .reverse) private var allJobs: [Jobs]
        @Environment(\.modelContext) private var modelContext
    @State private var selectedFilter: Filter = .all
    @State private var showingAddJob = false
    @State private var searchText: String = ""
    
    func getColor(job: Jobs) -> Color {
        if job.status == "Applied" {
            return .blue
        }
        else if job.status == "Interviewing"{
            return .yellow
        }
        else if job.status == "Offered"{
            return .green
        }
        return .red
    }

    enum Filter: String, CaseIterable, Identifiable {
        case all = "All", applied = "Applied", interviewing = "Interviewing", offered = "Offered", rejected = "Rejected"
        var id: String { rawValue }
    }
    
    var filteredJobs: [Jobs] {
      let base = (selectedFilter == .all) ? allJobs : allJobs.filter { $0.status == selectedFilter.rawValue }
      let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return base }
      return base.filter { job in
          job.companyName.localizedCaseInsensitiveContains(trimmed) ||
          job.jobName.localizedCaseInsensitiveContains(trimmed) ||
          job.location.localizedCaseInsensitiveContains(trimmed)
      }
    }
    
    private var groupedJobs: [(Date, [Jobs])] {
        // Group jobs by the "start of day" to ignore time differences
        let dictionary = Dictionary(grouping: filteredJobs) { job in
            Calendar.current.startOfDay(for: job.date)
        }
        // Sort the dates descending
        return dictionary.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar
                searchBar
                
                
                ScrollView {
                    LazyVStack(spacing: 5, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedJobs, id: \.0) { date, jobs in
                            Section {
                                ForEach(jobs) { job in
                                    NavigationLink(destination: JobDetailView(job: job)) {
                                        jobRow(job)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button(role: .destructive) { deleteJob(job) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                headerView(for: date, count: jobs.count)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(minWidth: 600, minHeight: 450)
            .background(bodyBackgroundColor.opacity(0.5)) // Subtle Mac background
            .sheet(isPresented: $showingAddJob) {
                NewJobView()
            }
        }
        .onAppear {
            print("The path")
            print(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path ?? "")
        }
    }
    
    private func deleteJob(_ job: Jobs){
        modelContext.delete(job)
    }

    // MARK: - Components

    private var topBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Jobs")
                    .font(.headline)
                // The dynamic count label
                Text("\(selectedFilter.rawValue): \(filteredJobs.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .fixedSize()
            Spacer()
            Picker("Filter", selection: $selectedFilter) {
                ForEach(Filter.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            
            Button(action: addJob) {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial)
        
    }
    
    private var searchBar: some View{
        HStack {
              Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
              TextField("Search company, title, or location", text: $searchText)
                  .textFieldStyle(.plain)
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
          .background(
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .fill(Color.primary.opacity(0.05))
          )
          .padding([.horizontal, .top])
    }
    
    private func headerView(for date: Date, count: Int) -> some View {
        HStack {
            Text("Applied on \(date, format: .dateTime.month().day().year())")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(count)")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(bodyBackgroundColor.opacity(0.9)) // Solidifies header when pinned
    }
    
    private func jobRow(_ job: Jobs) -> some View {
        let statusColor = getColor(job: job)
        return HStack(spacing: 16) {
            // Icon Circle (similar to your image)
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "briefcase.fill")
                    .foregroundStyle(statusColor)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack{
                    Text(job.companyName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(job.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack{
                    Text(job.jobName)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Spacer()
                    if job.status == "Interviewing"{
                        Text(formattedInterviewDate(for: job))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !job.summary.isEmpty {
                    Text(job.summary)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(3)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
        .padding()
        // The "Card" styling
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(bodyBackgroundColor) // Adapts to Mac Dark/Light mode
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    // MARK: - Helpers
    private func formattedInterviewDate(for job: Jobs) -> String {
        // Safely format a Date to a short, user-friendly string
        // Adjust the formatter as needed for your locale/style
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: job.interviewDate)
    }
    
    private func addJob() {
        showingAddJob = true
    }
}

#Preview {
    ContentView()
}

