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
    @State private var location: String = ""
    @State private var extraInfo: String = ""
    @State private var fakePhone = false
    
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    rowInput("Company", text: $companyName)
                    rowInput("Job Title", text: $jobName)
                    rowInput("Job Location", text: $location)
                    rowInput("Site URL", text: $siteURL)
                    rowInput("Extra Info", text: $extraInfo)
                }

                Section {
                    Toggle("Included Cover Letter", isOn: $isCoverLetter)
                    Toggle("Gave Fake Phone", isOn: $fakePhone)
                }

                Section {
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
            .lineSpacing(3)
        }.padding()
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
        if fakePhone{
            extraInfo = "\(extraInfo) | Fake Phone"
        }
        let newJob = Jobs(
            companyName: companyName,
            jobName: jobName,
            site: siteURL,
            jobDescription: jobDescription,
            location: location,
            extraInfo: extraInfo,
            isCoverLetter: isCoverLetter,
            fakePhone: fakePhone
        )
        
        #if os(macOS)
        newJob.addResumeData()
        #endif
        
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
