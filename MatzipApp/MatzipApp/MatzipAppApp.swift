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
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
        }
    }
}
