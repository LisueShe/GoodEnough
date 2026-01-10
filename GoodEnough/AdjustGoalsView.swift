//
//  AdjustGoalsView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/7/26.
//

import Foundation
import SwiftUI

enum AdjustmentType {
    case reduceGoals
    case miniGoals
    case essentialOnly
}

struct AdjustGoalsView: View {
    @ObservedObject var store: GoalStore
    @ObservedObject var dailyGoals: DailyGoalStore

    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: AdjustmentType? = nil
    @State private var showReduceGoals = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Text("Let’s make today Good Enough")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text("What kind of help would feel right?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                // Option A — Reduce goals
                Button {
                    selectedType = .reduceGoals
                    showReduceGoals = true
                } label: {
                    adjustmentRow(
                        title: "Reduce today’s goals",
                        subtitle: "Focus on just 1–2 things"
                    )
                }

                // Option B — Coming soon
                adjustmentRow(
                    title: "Lighter versions (coming soon)",
                    subtitle: "Smaller steps on low-energy days",
                    disabled: true
                )

                // Option C — Coming soon
                adjustmentRow(
                    title: "Essential only (coming soon)",
                    subtitle: "Just the most important thing",
                    disabled: true
                )

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding()
            .navigationTitle("Adjust Today")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showReduceGoals) {
                ReduceGoalsView(
                        store: store,
                        dailyGoals: dailyGoals,
                        parentIsPresented: $isPresented   
                    )
            }
        }
    }

    // MARK: - Row UI
    @ViewBuilder
    private func adjustmentRow(
        title: String,
        subtitle: String,
        disabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(disabled ? .gray : .primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .opacity(disabled ? 0.5 : 1)
    }
}

