//
//  MainView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/2/26.
//

import SwiftUI

enum Mood: String, CaseIterable, Codable {
    case low = "😔 Low"
    case okay = "😐 Okay"
    case good = "🙂 Good"
    case calm = "🌤️ Calm"
    case motivated = "🔥 Motivated"
}

struct MainView: View {
    @ObservedObject var store: GoalStore
    @State private var selectedMood: Mood? = nil
    @State private var completedGoals: Set<UUID> = []
    
    @State private var showAdjustGoalsSheet = false
    @StateObject private var dailyCheckIn = DailyCheckInStore()
    @StateObject private var dailyGoals = DailyGoalStore()
    var body: some View {
        NavigationView {
            // 1. Use GeometryReader to get the height of the visible screen area
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) { // Parent container
                        
                        // 2. Your existing content logic
                        VStack(alignment: .leading, spacing: 6) {
                            if store.goals.isEmpty {
                                VStack(spacing: 16) {
                                    Text("Welcome to GoodEnough")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("""
                            This app is for days when doing everything feels like too much.
                            
                            Start with one small goal.
                            That’s enough.
                            """)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    
                                    NavigationLink(
                                        destination: GoalSetupView(store: store, hasCompletedSetup: .constant(false))
                                    ) {
                                        Text("Add your first goal")
                                            .font(.headline)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(Color.blue.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                
                                /*
                                 Text("No goals found.\nGo add some!")
                                 .multilineTextAlignment(.center)
                                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                                 .foregroundColor(.gray)
                                 */
                            } else {
                                let columns = [
                                    GridItem(.adaptive(minimum: 90), spacing: 12)
                                ]
                                VStack(alignment: .leading, spacing: 12) {
                                    
                                    Text("How are you feeling today?")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(Mood.allCases, id: \.self) { mood in
                                            Button {
                                                dailyCheckIn.selectedMood = mood
                                                dailyCheckIn.saveDuringDay()
                                            } label: {
                                                Text(mood.rawValue)
                                                    .fixedSize(horizontal: true, vertical: false)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .fontWeight(dailyCheckIn.selectedMood == mood ? .bold : .regular)
                                                    .foregroundColor(dailyCheckIn.selectedMood == mood ? .white : .primary)
                                                    .background(
                                                        dailyCheckIn.selectedMood == mood
                                                        ? Color.blue.opacity(0.25)
                                                        : Color.gray.opacity(0.15)
                                                    )
                                                    .cornerRadius(10)
                                            }
                                            .disabled(dailyCheckIn.isLocked)
                                            .opacity(dailyCheckIn.isLocked ? 0.5 : 1)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                
                                    
                                    if dailyCheckIn.isLocked {
                                        VStack(spacing: 12) {
                                            DailySummaryView(
                                                mood: dailyCheckIn.selectedMood,
                                                completed: dailyGoals.completedGoalIDs.count,
                                                total: dailyGoals.activeGoalIDs.count,
                                                reflection: DailyReflection.generate(
                                                    mood: dailyCheckIn.selectedMood,
                                                    completed: dailyGoals.completedGoalIDs.count,
                                                    total: dailyGoals.activeGoalIDs.count
                                                )
                                            )
                                            
                                            Button {
                                                dailyCheckIn.unlockToday()
                                                dailyGoals.resetForToday(with: store.goals)
                                            } label: {
                                                Text("Undo today’s completion")
                                                    .font(.footnote)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Divider().padding(.top, 8)
                                            
                                            Text("Looking ahead to tomorrow")
                                                .font(.headline)
                                            
                                            Button {
                                                dailyCheckIn.setTomorrowIntent(.keepAll)
                                            } label: {
                                                Text("Keep these goals")
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.blue.opacity(0.15))
                                                    .cornerRadius(10)
                                            }
                                            
                                            Button {
                                                dailyCheckIn.setTomorrowIntent(.startFresh)
                                            } label: {
                                                Text("Start fresh tomorrow")
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.gray.opacity(0.15))
                                                    .cornerRadius(10)
                                            }
                                        }
                                        .padding(.top, 12)
                                    }
                                    
                                    else if let mood = dailyCheckIn.selectedMood,
                                            mood == .low || mood == .okay {
                                        Button {
                                            showAdjustGoalsSheet = true
                                        } label: {
                                            Text("Help me adjust today’s goals")
                                                .font(.subheadline)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(Color.blue.opacity(0.15))
                                                .cornerRadius(10)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 8)
                                    }
                                    if !dailyCheckIn.isLocked {
                                        VStack(spacing: 12) {
                                            Divider()
                                                .padding(.horizontal)
                                            HStack {
                                                Spacer()
                                                Button {
                                                    dailyCheckIn.saveDay(
                                                        completedGoals: Array(dailyGoals.completedGoalIDs),
                                                        totalGoals: dailyGoals.activeGoalIDs.count,
                                                        allGoals: store.goals,
                                                        saveDate: Calendar.current.startOfDay(for: Date())
                                                    )
                                                    dailyCheckIn.lockToday()
                                                } label: {
                                                    Text("Check Out for Today")
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 12)
                                                        .padding(.horizontal, 24)
                                                        .background(Color.orange.opacity(0.7))
                                                        .cornerRadius(12)
                                                        .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
                                                }
                                                Spacer()
                                            }
                                            
                                            Text("Lock your day even if not all goals are completed")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                        }
                                        .padding(.vertical, 12)
                                    }
                                }
                                .padding(.vertical)
                                if !store.goals.filter({ dailyGoals.isGoalActive($0.id) }).isEmpty {
                                    Text("Today's Goals")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.darkGray))
                                        .padding(.horizontal)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(store.goals.filter { dailyGoals.isGoalActive($0.id) }) { goal in
                                            HStack(spacing: 12) {
                                                Button {
                                                    dailyGoals.toggleGoal(goal.id)
                                                } label: {
                                                    Image(systemName:
                                                            dailyGoals.completedGoalIDs.contains(goal.id)
                                                          ? "checkmark.circle.fill"
                                                          : "circle"
                                                    )
                                                    .foregroundColor(
                                                        dailyGoals.completedGoalIDs.contains(goal.id)
                                                        ? .blue
                                                        : .gray
                                                    )
                                                    .font(.system(size: 18))
                                                }
                                                .disabled(dailyCheckIn.isLocked)
                                                
                                                Text(goal.title)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 12)
                                            .background(Color.clear)
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // 3. This Spacer pushes the button down if there is extra room
                        Spacer(minLength: 20)
                        
                        // 4. Your Manage Goals Button
                        NavigationLink(
                            destination: GoalSetupView(store: store, hasCompletedSetup: .constant(true))
                        ) {
                            Text("Manage Goals")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                    // 5. Crucial: Ensure the VStack is at least as tall as the screen
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationTitle("GoodEnough")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryView(dailyCheckIn: dailyCheckIn, store: store)
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
        }
    }
}
