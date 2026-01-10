//
//  MainView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/2/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var store = GoalStore()
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    var body: some View {
        if store.goals.isEmpty || !hasCompletedSetup {
            GoalSetupView(
                store: store,
                hasCompletedSetup: $hasCompletedSetup
            )
        } else {
            MainView(store: store)
        }
    }
}
/*
import SwiftUI

struct RootView: View {
    @StateObject private var store = GoalStore()
    @State private var hasCompletedSetup: Bool = false   // track if setup completed

    var body: some View {
        if store.goals.isEmpty {
            GoalSetupView(store: store, hasCompletedSetup: $hasCompletedSetup)
        } else {
            MainView(store: store)
        }
    }
}
*/
