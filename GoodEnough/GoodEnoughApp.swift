//
//  GoodEnoughApp.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/1/26.
//

import SwiftUI

var goodEnough: GoodEnoughManagement?

class GoodEnoughManagement: NSObject {
    @StateObject private var store = GoalStore()
    @State private var hasCompletedSetup: Bool = false   // track if setup completed
    
}

@main
struct GoodEnoughApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

