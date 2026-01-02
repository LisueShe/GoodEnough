//
//  GoodEnoughApp.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/1/26.
//

import SwiftUI

@main
struct GoodEnoughApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
