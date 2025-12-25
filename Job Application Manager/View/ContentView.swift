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
    @Query(sort: \Jobs.companyName) private var allJobs: [Jobs]
        @Environment(\.modelContext) private var modelContext
    @State private var selectedFilter: Filter = .all
    @State private var showingAddJob = false

    enum Filter: String, CaseIterable, Identifiable {
        case all = "All", applied = "Applied", interviewing = "Interviewing", offered = "Offered", rejected = "Rejected"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            
            List {
                ForEach(allJobs, id: \.jobName) { job in
                    jobRow(job)
                }
            }
            .listStyle(.inset) // Standard Mac list appearance
        }
        .frame(minWidth: 500, minHeight: 400)
        .sheet(isPresented: $showingAddJob) {
            NewJobView() // Your previous view
        }
    }

    // MARK: - Components

    private var topBar: some View {
        HStack(spacing: 12) {
            Text("Jobs")
                .font(.headline)
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

    private func jobRow(_ job: Jobs) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(job.jobName)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(job.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if !job.summary.isEmpty {
                Text(job.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func addJob() {
        showingAddJob = true
    }
}

#Preview {
    ContentView()
}

