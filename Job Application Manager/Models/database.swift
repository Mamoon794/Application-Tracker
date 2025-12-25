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
    var companyName: String
    var jobName: String
    var applicationSite: String
    var isCoverLetter: Bool = false
    var jobDescription: String
    var summary: String = ""
    
    
    init(companyName: String, jobName: String, site: String, jobDescription: String, isCoverLetter: Bool){
        print("HERE")
        self.companyName = companyName
        self.jobName = jobName
        self.applicationSite = site
        self.jobDescription = jobDescription
        self.isCoverLetter = isCoverLetter
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
        let response = try await session.respond(to: "Summarize this job description in one sentence: \(text)")
        
        // Access the generated string via the 'content' property
        return response.content
    }
}

