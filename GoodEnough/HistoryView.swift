//
//  HistoryView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/11/26.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @ObservedObject var dailyCheckIn: DailyCheckInStore
    @ObservedObject var store: GoalStore
    
    var body: some View {
        let lastWeek = dailyCheckIn.last7Days()
        if dailyCheckIn.history.isEmpty {
            VStack(spacing: 12) {
                Text("No history yet")
                    .font(.headline)

                Text("""
        Your reflections will appear here over time.
        There’s nothing to catch up on 🌱
        """)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
       
        if !lastWeek.isEmpty {
            WeeklySummaryView(days: lastWeek)
        }
        List {
            ForEach(dailyCheckIn.history) { day in
                NavigationLink {
                    HistoryDetailView(
                        day: day,
                        allGoals: store.goals
                    )
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(day.date, style: .date)
                                .font(.headline)
                            
                            Spacer()
                            
                            if let mood = day.mood {
                                Text(mood.rawValue)
                                    .font(.subheadline)
                            }
                        }
                        
                        Text("Completed \(day.completedGoals.count) goals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        let todayGoals = summaryText(for: day)
                        Text(todayGoals.text)
                            .font(.footnote)
                            .foregroundColor(todayGoals.color)
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func summaryText(for day: DailyHistory) -> (text: String, color: Color) {
        let store = GoalStore()
        let completed = day.completedGoals.count
        let total = max(store.goals.count , 1) // avoid divide by zero
        let ratio = Double(completed) / Double(total)

        // Mood-aware summaries
        if let mood = day.mood {
            switch mood {
            case .low:
                return ratio < 0.2
                    ? ("Showed up despite a hard day 💛", .orange)
                    : ("Rest was the right choice 🌿", .green)

            case .okay:
                return ratio >= 0.5
                    ? ("A steady, good-enough day 🌱", .green)
                    : ("Took it gently today 🌿", .green)

            case .good, .calm:
                return ratio >= 0.7
                    ? ("A solid, balanced day ✨", .blue)
                    : ("Progress without pressure 🌱", .green)

            case .motivated:
                return ratio == 1.0
                    ? ("You showed up strong 🔥", .purple)
                    : ("Focused where it mattered 💪", .blue)
            }
        }

        // Fallback
        return ("Good enough 🌱", .green)
    }
}

func reflectionText(completed: Int, total: Int) -> String {
    switch completed {
    case 0:
        return "Some days are for rest."
    case total:
        return "You showed up fully today."
    default:
        return "You made progress, and that counts."
    }
}

struct HistoryDetailView: View {
    let day: DailyHistory
    let allGoals: [Goal]

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                // Date
                Text(day.date, style: .date)
                    .font(.title2)
                    .fontWeight(.semibold)

                Divider()

                // Summary
                let completed = day.completedGoals.count
               // let total = allGoals.count
                let total = day.allGoals.count
                DailySummaryView(
                    mood: day.mood,
                    completed: day.completedGoals.count,
                    total: total,
                    reflection: day.reflection
                )

                Divider()

                // Goals list (optional but grounding)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goals")
                        .font(.headline)

                   // ForEach(allGoals) { goal in
                    ForEach(day.allGoals) { goal in
                        HStack {
                            Image(systemName:
                                day.completedGoals.contains(goal.id)
                                ? "checkmark.circle.fill"
                                : "circle"
                            )
                            .foregroundColor(
                                day.completedGoals.contains(goal.id)
                                ? .green
                                : .gray
                            )

                            Text(goal.title)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Daily Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/*
struct HistoryDetailView: View {
    let day: DailyHistory
    let allGoals: [Goal]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Date
                Text(day.date, style: .date)
                    .font(.title2)
                    .fontWeight(.semibold)

                // Mood
                if let mood = day.mood {
                    Text(mood.rawValue)
                        .font(.headline)
                }

                // Reflection (NOW ACTUALLY USED)
                let completed = day.completedGoals.count
                let total = allGoals.count
                
                Text(day.reflection)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                 
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

                // Completed goals
                Text("Completed")
                    .font(.headline)

                ForEach(allGoals.filter { day.completedGoals.contains($0.id) }) { goal in
                    Label(goal.title, systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                // Skipped goals
                if allGoals.count != day.completedGoals.count {
                    Text("Skipped")
                        .font(.headline)
                        .padding(.top, 8)

                    ForEach(allGoals.filter { !day.completedGoals.contains($0.id) }) { goal in
                        Label(goal.title, systemImage: "circle")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("That Day")
        .navigationBarTitleDisplayMode(.inline)
             
    }
}

 ----
 /*
  if dailyCheckIn.history.isEmpty {
  
  VStack(spacing: 12) {
  Text("No history yet")
  .font(.headline)
  
  Text("Your reflections will appear here over time 🌱")
  .font(.subheadline)
  .foregroundColor(.secondary)
  .multilineTextAlignment(.center)
  }
  //.frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  //  else {
  */
*/
