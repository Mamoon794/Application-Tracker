//
//  Job_Application_ManagerApp.swift
//  Job Application Manager
//
//  Created by Mamoon Akhtar on 2025-12-06.
//

import SwiftUI
import SwiftData

@main
struct Job_Application_ManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: Jobs.self)
    }
}
