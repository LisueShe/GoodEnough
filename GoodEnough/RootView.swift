//
//  MainView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/2/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var store = GoalStore()
    
    // Persistence variables
    @AppStorage("hasOnboardingDone") private var hasOnboardingDone = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    var body: some View {
        // Step 1: Check Onboarding
        if !hasOnboardingDone {
            OnboardingView(hasOnboardingDone: $hasOnboardingDone)
        }
        // Step 2: Check if they've set up their first goals
        else if !hasCompletedSetup || store.goals.isEmpty {
            GoalSetupView(
                store: store,
                hasCompletedSetup: $hasCompletedSetup
            )
        }
        // Step 3: Show the actual app
        else {
            MainView(store: store)
        }
    }
}

class OnBoarding: ObservableObject {
    var shouldShowOnboarding: Bool = true
    init() {
        let data = UserDefaults.standard.data(forKey: "hasOnboardingDone")
        if data == nil {
            shouldShowOnboarding = false
            UserDefaults.standard.set(true, forKey: "hasOnboardingDone")
        }
    }
}

struct OnboardingSlide: View {
    let title: String
    let description: String
    let image: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct OnboardingView: View {
    @Binding var hasOnboardingDone: Bool
    
    var body: some View {
        TabView {
            OnboardingSlide(
                title: "Welcome to GoodEnough",
                description: "A space to track your goals without the pressure of perfection.",
                image: "heart.text.square"
            )
            
            OnboardingSlide(
                title: "Check-in with yourself",
                description: "Start your day by noting your energy levels. We adjust to you, not the other way around.",
                image: "face.smiling"
            )
            
            VStack(spacing: 20) {
                OnboardingSlide(
                    title: "Ready to start?",
                    description: "Your data stays on your device, and your progress is your own.",
                    image: "lock.shield"
                )
                Button("Get Started") {
                    hasOnboardingDone = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
