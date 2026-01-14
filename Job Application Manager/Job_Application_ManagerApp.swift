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
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([Jobs.self])
            
            let modelConfiguration = ModelConfiguration(url: getDatabaseURL())

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()

        var body: some Scene {
            WindowGroup {
                ContentView()
            }
            .modelContainer(sharedModelContainer)
        }
}
