//
//  MatzipAppApp.swift
//  MatzipApp
//
//  Created by jonghee yun on 8/29/25.
//

import SwiftUI

@main
struct MatzipAppApp: App {
    let coreDataStack = CoreDataStack.shared
    let coreDataService = CoreDataService()
    let userManager = UserManager.shared
    
    init() {
        setupCoreData()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
                .environmentObject(coreDataService)
                .environmentObject(userManager)
        }
    }
    
    private func setupCoreData() {
        coreDataService.initializeWithSampleData()
    }
}
