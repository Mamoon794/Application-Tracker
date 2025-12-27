//
//  SeperateFuncs.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2025-12-26.
//

import SwiftUI
import SwiftData

#if os(macOS)
func runSaveScript(company: String, jobTitle: String, site: String, location: String, coverLetter:Bool, summary: String, extraInfo: String) async throws {
    // 1. Create the process
    let process = Process()
    // 2. Point to the shell (usually /bin/zsh or /bin/bash)
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    
    // 3. Define the path to your script and any arguments
    // Ensure your script is at this path and has 'chmod +x' permissions
    let scriptPath = "/Users/primus/Documents/Job Applications/move"
    var isCover = "n"
    if coverLetter{
        isCover = "y"
    }
    process.arguments = [scriptPath, company, jobTitle, site, location, isCover, summary, extraInfo]
    
    do {
        try process.run()
    } catch {
        print("Failed to run bash script: \(error)")
    }
}

#endif


var bodyBackgroundColor: Color {
    #if os(macOS)
    return Color(nsColor: .windowBackgroundColor)
    #else
    return Color(uiColor: .systemBackground)
    #endif
}

var cardBackground: Color {
    #if os(macOS)
    return Color(nsColor: .controlBackgroundColor)
    #else
    // This provides a clean, elevated look on iOS similar to Mac controls
    return Color(uiColor: .secondarySystemGroupedBackground)
    #endif
}
