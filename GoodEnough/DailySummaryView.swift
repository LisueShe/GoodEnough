//
//  DailySummaryView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/14/26.
//

import SwiftUI

struct DailySummaryView: View {
    let mood: Mood?
    let completed: Int
    let total: Int
    let reflection: String

    var body: some View {
        VStack(spacing: 16) {

            Text("Today’s Summary")
                .font(.title2)
                .fontWeight(.semibold)

            if let mood = mood {
                Text(mood.rawValue)
                    .font(.largeTitle)
            }

            Text("Completed \(completed) of \(total) goals")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(reflection)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Good enough for today 🌱")
                .font(.footnote)
                .foregroundColor(.green)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
