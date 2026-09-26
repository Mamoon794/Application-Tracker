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
    
    @State private var isPresentingJSONImport = false
    @State private var jsonInput: String = ""
    @State private var showImportErrorAlert = false
    @State private var importErrorMessage: String = ""
    
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        isPresentingJSONImport = true
                    } label: {
                        Label("Import from JSON", systemImage: "square.and.arrow.down")
                    }
                }
                
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
        }
        .alert("Import Failed", isPresented: $showImportErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importErrorMessage)
        }
        .sheet(isPresented: $isPresentingJSONImport) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Paste a JSON object with keys \"title\", \"description\", \"location\", and \"url\". Optionally include \"company\" to populate Company. Smart quotes will be normalized automatically.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $jsonInput)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 200)
                        .overlay(alignment: .topLeading) {
                            if jsonInput.isEmpty {
                                Text("{\"company\":\"Acme Corp\",\"title\":\"Senior iOS Engineer\",\"description\":\"...\",\"location\":\"Remote\",\"url\":\"https://example.com\"}")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2))
                        )
                }
                .padding()
                .navigationTitle("Import JSON")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingJSONImport = false
                            jsonInput = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Import") {
                            importJSON()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
        .padding()
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
    
    private func importJSON() {
        struct JobImport: Decodable {
            let company: String?
            let title: String
            let description: String
            let location: String
            let url: String
        }
        do {
            // Normalize smart quotes and similar characters to standard quotes before decoding
            let sanitizedInput = jsonInput
                .replacingOccurrences(of: "\u{201C}", with: "\"") // left double smart quote
                .replacingOccurrences(of: "\u{201D}", with: "\"") // right double smart quote
                .replacingOccurrences(of: "\u{201E}", with: "\"") // double low-9 quote
                .replacingOccurrences(of: "\u{201F}", with: "\"") // double high-reversed-9 quote
                .replacingOccurrences(of: "\u{2033}", with: "\"") // double prime
                .replacingOccurrences(of: "\u{2018}", with: "'")   // left single smart quote
                .replacingOccurrences(of: "\u{2019}", with: "'")   // right single smart quote
                .replacingOccurrences(of: "\u{2032}", with: "'")   // prime

            let data = Data(sanitizedInput.utf8)
            let job = try JSONDecoder().decode(JobImport.self, from: data)

            // Populate fields
            if let company = job.company { self.companyName = company }
            self.jobName = job.title
            self.jobDescription = job.description
            self.location = job.location
            self.siteURL = job.url

            // Dismiss sheet and clear input
            self.isPresentingJSONImport = false
            self.jsonInput = ""
        } catch {
            self.importErrorMessage = "Please provide valid JSON with keys \"title\", \"description\", \"location\", and \"url\".\n\nError: \(error.localizedDescription)"
            self.showImportErrorAlert = true
        }
    }
}

#Preview {
    NewJobView()
}

