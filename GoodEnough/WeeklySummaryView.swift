//
//  WeeklySummaryView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/14/26.
//

import Foundation
import SwiftUI

struct WeeklySummaryView: View {
    let days: [DailyHistory]

    private var averageMoodText: String {
        let moods = days.compactMap { $0.mood }
        guard !moods.isEmpty else { return "No mood data yet" }

        let counts = Dictionary(grouping: moods, by: { $0 })
        let dominant = counts.max(by: { $0.value.count < $1.value.count })?.key

        return dominant?.rawValue ?? ""
    }

    private var reflection: String {
        if days.count == 0 {
            return "A quiet start. This space will fill gently."
        } else if days.count <= 2 {
            return "You showed up a few times. That already counts 🌱"
        } else if averageMoodText.contains("😔") {
            return "This week felt heavy. You still kept going."
        } else {
            return "You found some steadiness this week."
        }
    }


    var body: some View {
        VStack(spacing: 16) {
            Text("This Week")
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(days.count) check-ins")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !averageMoodText.isEmpty {
                Text(averageMoodText)
                    .font(.largeTitle)
            }

            Text(reflection)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
