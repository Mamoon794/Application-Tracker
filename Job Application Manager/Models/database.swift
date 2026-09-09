//
//  database.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2025-12-06.
//

import SwiftData
import Foundation
import FoundationModels

private func processJobSummary(description: String)-> String {
    let service = AIService()
    
    Task {
        do {
            let result: String
            
            result = try await service.summarizeOnDevice(description)
            print("result: \(result)")
            
            
        } catch {
            print("AI error: \(error.localizedDescription)")
            
        }
    }
    return ""
}

@Model
final class Jobs {
    var companyName: String = ""
    var jobName: String = ""
    var applicationSite: String = ""
    var isCoverLetter: Bool = false
    var jobDescription: String = ""
    var location: String = ""
    var summary: String = ""
    var resumeData: Data? = nil
    var coverLetterData: Data? = nil
    var date: Date = Date.now
    var status: String = "Applied"
    var interviewDate: Date = Date()
    var extraInfo: String = ""
    var fakePhone: Bool = false
    var isPinned: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \InterviewQuestion.job)
        var questions: [InterviewQuestion]? = []

        @Relationship(deleteRule: .cascade, inverse: \InterviewNote.job)
        var notes: [InterviewNote]? = []
    
    
    init(companyName: String, jobName: String, site: String, jobDescription: String, location: String, extraInfo: String, isCoverLetter: Bool, fakePhone: Bool){
        print("HERE")
        self.companyName = companyName
        self.jobName = jobName
        self.applicationSite = site
        self.jobDescription = jobDescription
        self.isCoverLetter = isCoverLetter
        self.location = location
        self.resumeData = nil
        self.coverLetterData = nil
        self.extraInfo = extraInfo
        self.fakePhone = fakePhone
    }
    
    #if os(macOS)
    func addResumeData(){
        var homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let resumeURL = homeDirectory.appendingPathComponent("Documents/Job Applications/Mamoon Akhtar Resume.pdf")
        do{
            let data = try Data(contentsOf: resumeURL)
            self.resumeData = data
        } catch{
            self.resumeData = nil
        }
        
        homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        if isCoverLetter{
            let coverURL = homeDirectory.appendingPathComponent("Documents/Job Applications/Mamoon Akhtar Cover Letter.pdf")
            do{
                let data = try Data(contentsOf: coverURL)
                self.coverLetterData = data
            } catch{
                self.coverLetterData = nil
            }
        }
    }
    #endif
}

@Model
final class InterviewQuestion {
    var question: String = ""
    var answer: String = ""
    var date: Date = Date.now
    var job: Jobs?

    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}

@Model
final class InterviewNote {
    var content: String = ""
    var date: Date = Date.now
    var job: Jobs?

    init(content: String) {
        self.content = content
    }
}

@MainActor
func generateSummary(for job: Jobs) async {
    let service = AIService()
    do {
        // Now it actually waits for the result
        let result = try await service.summarizeOnDevice(job.jobDescription)
        job.summary = result
        print("Summary updated: \(result)")
    } catch {
        print("AI error: \(error.localizedDescription)")
        job.summary = "Summary generation failed."
    }
}



struct AIService {
    // Cloud-based logic (e.g., calling an API or Private Cloud Compute)
    func summarizeWithCloud(_ text: String) async throws -> String {
        // Your API call logic here
        return "Cloud Summary: \(text.prefix(50))..."
    }

    // On-device fallback using Apple's Foundation Models
    func summarizeOnDevice(_ text: String) async throws -> String {
        // Initialize the session (this maintains context/instructions)
        let session = LanguageModelSession()
        
        // Use 'respond(to:)' which is the correct throwing async method
        let prompt = "Summarize the job description in maximum of 2 sentences. Focus on the requirements they are asking for: \(text)"
        let response = try await session.respond(to: prompt)
        
        // Access the generated string via the 'content' property
        return response.content
    }
}

