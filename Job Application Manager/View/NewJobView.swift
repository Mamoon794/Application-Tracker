//
//  NewJob.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2025-12-24.
//

import SwiftUI
import SwiftData

struct NewJobView: View {
    // Keep local state for the form inputs
    @State private var companyName: String = ""
    @State private var jobName: String = ""
    @State private var siteURL: String = ""
    @State private var isCoverLetter: Bool = false
    @State private var jobDescription: String = ""
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    rowInput("Company", text: $companyName)
                    rowInput("Job Title", text: $jobName)
                    rowInput("Site URL", text: $siteURL)
                }

                Section {
                    Toggle("Included Cover Letter", isOn: $isCoverLetter)
                }

                Section("Job Description") {
                    descriptionEditor
                }
            }
            .navigationTitle("New Application")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.bold)
                        .disabled(isInvalid)
                        .foregroundStyle(.blue)
                }
            }
        }
    }

    // MARK: - Separated UI Components

    private var descriptionEditor: some View {
        TextEditor(text: $jobDescription)
            .frame(minHeight: 150)
            .overlay(alignment: .topLeading) {
                if jobDescription.isEmpty {
                    Text("Paste the job description here...").foregroundStyle(.tertiary)
                }
            }
    }

    private func rowInput(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(label, text: text)
            #if os(iOS)
                .textInputAutocapitalization(.words)
            #endif
        }
        .padding(.vertical, 2)
    }

    // MARK: - Logic functions

    private var isInvalid: Bool {
        companyName.trimmingCharacters(in: .whitespaces).isEmpty ||
        jobName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        // 1. Initialize the SwiftData Model
        let newJob = Jobs(
            companyName: companyName,
            jobName: jobName,
            site: siteURL,
            jobDescription: jobDescription,
            isCoverLetter: isCoverLetter
        )
        
        // 2. Insert into Context
        modelContext.insert(newJob)
        Task {
            await generateSummary(for: newJob)
        }
        
        // 3. Dismiss
        dismiss()
    }
}

#Preview {
    NewJobView()
}
