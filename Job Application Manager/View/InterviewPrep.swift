//
//  InterviewPrep.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2026-01-13.
//

import SwiftUI
import SwiftData

struct InterviewPrepView: View {
    @Bindable var job: Jobs
    @State private var newQ = ""
    @State private var newA = ""
    @State private var newNote = ""
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Input Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("New Entry")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    // Question Input
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Enter Question", text: $newQ, axis: .vertical)
                            .lineLimit(3...6) // Starts at 3 lines, grows up to 6
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        TextEditor(text: $newA)
                            .frame(height: 60)
                            .padding(4)
                            .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2)))
                            .overlay(alignment: .topLeading) {
                                if newA.isEmpty {
                                    Text("Enter Answer...").foregroundStyle(.tertiary).padding(8)
                                        .allowsHitTesting(false)
                                }
                            }
                        
                        Button {
                            addQuestion(to: job, q: newQ, a: newA)
                            newQ = ""; newA = ""
                        } label: {
                            Text("Add Q&A")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newQ.isEmpty || newA.isEmpty)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Note Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Note")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 2)

                        ZStack(alignment: .topLeading) {
                            // The actual editor
                            TextEditor(text: $newNote)
                                .font(.system(size: 15))
                                .frame(height: 100) // Fixed height for the editor
                                .padding(4)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )

                            // Custom Placeholder (visible only when empty)
                            if newNote.isEmpty {
                                Text("Enter general thoughts, impressions, or reminders...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false) // Ensures clicks pass through to the editor
                            }
                        }

                        HStack {
                            Spacer()
                            Button("Add Note") {
                                addNote(to: job, content: newNote)
                                newNote = ""
                            }
                            .buttonStyle(.bordered)
                            .disabled(newNote.isEmpty)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.05)) // Subtle orange tint to distinguish from Q&A
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.bottom, 10)

                Divider()

                // MARK: - Questions List
                if let questions = job.questions, !questions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("Interview Questions")
                        
                        ForEach(questions.sorted(by: { $0.date > $1.date })) { q in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(q.question)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Divider().opacity(0.5)
                                
                                Text(q.answer)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading) // Forces left alignment
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1)) // Subtle bar background
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            )
                            .contextMenu {
                                Button(role: .destructive) { performDeletion(q) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                // MARK: - Notes List
                if let notes = job.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("General Notes")
                        
                        ForEach(notes.sorted(by: { $0.date > $1.date })) { n in
                            HStack(alignment: .top) {
                                Image(systemName: "note.text")
                                    .foregroundStyle(.orange)
                                    .padding(.top, 2)
                                
                                Text(n.content)
                                    .font(.callout)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.05)) // Different color for notes
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                            )
                            .contextMenu {
                                Button(role: .destructive) { performDeletion(n) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(20) // General padding for the whole scroll view
        }
        .navigationTitle("Interview Prep: \(job.companyName)")
        #if os(iOS)
        .toolbar { EditButton() }
        #endif
    }
    
    // MARK: - Helpers
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .padding(.top, 10)
    }

    // MARK: - Action Functions
    private func addQuestion(to job: Jobs, q: String, a: String) {
        let newQ = InterviewQuestion(question: q, answer: a)
        newQ.job = job
        modelContext.insert(newQ)
    }

    private func addNote(to job: Jobs, content: String) {
        let newNote = InterviewNote(content: content)
        newNote.job = job
        modelContext.insert(newNote)
    }

    private func performDeletion(_ item: any PersistentModel) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

#Preview{
//    InterviewPrepView()
}
