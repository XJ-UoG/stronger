//
//  strongerApp.swift
//  stronger
//
//  Created by Tan Xin Jie on 4/12/24.
//

import SwiftUI

@main
struct strongerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
