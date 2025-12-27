//
//  JobDetailView.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2025-12-25.
//

import SwiftUI
import SwiftData
import QuickLook

struct JobDetailView: View {
    @Bindable var job: Jobs
    @State private var previewURL: URL?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    let statuses = ["Applied", "Interviewing", "Offered", "Rejected"]
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isEditing {
                    editingInterface
                } else {
                    viewingInterface
                }
            }
            .padding(30)
        }
        .navigationTitle(isEditing ? "Edit Details" : job.companyName)
        .background(bodyBackgroundColor)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .fontWeight(isEditing ? .bold : .regular)
            }
            
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .quickLookPreview($previewURL)
    }
    
    
    

    // MARK: - View Components
    private var viewingInterface: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerSection
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Application Status").font(.headline)
                
                HStack(spacing: 20) {
                    Picker("Status", selection: $job.status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)

                    // Only show if the status is "Interviewing"
                    if job.status == "Interviewing" {
                        DatePicker("Interview Time:", selection: $job.interviewDate)
                            .labelsHidden() // Keeps it clean on Mac
                    }
                }
                .padding()
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if job.resumeData != nil {
                resumeCoverSection
            }
            
            if !job.summary.isEmpty {
                summarySection
            }
            
            descriptionSection
        }
        .padding(30)
    }
    
    private var editingInterface: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Position Info").font(.headline)
            
            Group {
                TextField("Company", text: $job.companyName)
                TextField("Job Title", text: $job.jobName)
                TextField("Location", text: $job.location)
                TextField("Site URL", text: $job.applicationSite)
                TextField("Extra Info", text: $job.extraInfo)
            }
            .textFieldStyle(.roundedBorder)
            
            Divider().padding(.vertical, 8)
            
            Text("Job Description").font(.headline)
            TextEditor(text: $job.jobDescription)
                .frame(minHeight: 200)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
        }
    }
    
    private var resumeCoverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Documents")
                .font(.headline)
            
            Button {
                prepareAndShowResume()
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.red)
                    Text("View Saved Resume")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "eye")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            if job.isCoverLetter{
                Button {
                    prepareAndShowCoverLetter()
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.red)
                        Text("View Saved Cover Letter")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Logic Functions

    private func prepareAndShowResume() {
        guard let data = job.resumeData else { return }
        
        // 1. Create a temporary file path
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(job.companyName)_Resume.pdf")
        
        do {
            // 2. Write the data to the temporary file
            try data.write(to: tempURL)
            
            // 3. Set the previewURL to trigger the .quickLookPreview modifier
            self.previewURL = tempURL
        } catch {
            print("Error creating temporary resume file: \(error)")
        }
    }
    
    private func prepareAndShowCoverLetter() {
        guard let data = job.coverLetterData else { return }
        
        // 1. Create a temporary file path
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(job.companyName)_Cover Letter.pdf")
        
        do {
            // 2. Write the data to the temporary file
            try data.write(to: tempURL)
            
            // 3. Set the previewURL to trigger the .quickLookPreview modifier
            self.previewURL = tempURL
        } catch {
            print("Error creating temporary cover letter file: \(error)")
        }
    }
    

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(job.jobName)
                    .font(.system(size: 28, weight: .bold))
                
                HStack(spacing: 12) {
                    Text(job.companyName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    if job.isCoverLetter {
                        Text("Cover Letter Included")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.emerald500.opacity(0.15))
                            .foregroundStyle(Color.emerald500)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            if let url = URL(string: job.applicationSite), !job.applicationSite.isEmpty {
                Button {
                    openLink(url)
                } label: {
                    Label("View Site", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI Summary", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(.blue)
            
            Text(job.summary)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                )
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Job Description")
                .font(.headline)
            
            Text(job.jobDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(cardBackground)
                )
            
            Text("Extra Info").font(.headline)
            Text(job.extraInfo)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(cardBackground)
                )
        }
    }

    // MARK: - Action Functions

    private func openLink(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
