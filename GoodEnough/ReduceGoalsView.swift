//
//  ReduceGoalsView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/7/26.
//

import Foundation
import SwiftUI

struct ReduceGoalsView: View {
    @ObservedObject var store: GoalStore
    @ObservedObject var dailyGoals: DailyGoalStore
    @Binding var parentIsPresented: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var selectedGoalIDs: Set<UUID> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                Text("Choose up to 2 goals for today")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("The rest can wait. This is enough.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                List {
                    ForEach(store.goals) { goal in
                        Button {
                            toggle(goal.id)
                        } label: {
                            HStack {
                                Image(systemName:
                                    selectedGoalIDs.contains(goal.id)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )
                                .foregroundColor(
                                    selectedGoalIDs.contains(goal.id)
                                    ? .blue
                                    : .gray
                                )

                                Text(goal.title)
                                    .foregroundColor(.primary)
                            }
                        }
                        .disabled(
                            selectedGoalIDs.count >= 2 &&
                            !selectedGoalIDs.contains(goal.id)
                        )
                    }
                }
                .listStyle(.plain)

                Button("Apply for today") {
                    dailyGoals.setActiveGoals(selectedGoalIDs)

                    // 1️⃣ Close ReduceGoalsView
                    dismiss()

                    // 2️⃣ Close AdjustGoalsView
                    parentIsPresented = false
                }
                .disabled(selectedGoalIDs.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedGoalIDs.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Reduce Goals")
            .navigationBarTitleDisplayMode(.inline)

        }
    }

    private func toggle(_ id: UUID) {
        if selectedGoalIDs.contains(id) {
            selectedGoalIDs.remove(id)
        } else if selectedGoalIDs.count < 2 {
            selectedGoalIDs.insert(id)
        }
    }
}
