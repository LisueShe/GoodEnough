//
//  GoalsView.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/2/26.
//

import SwiftUI

struct GoalSetupView: View {
    @ObservedObject var store: GoalStore
    @Binding var hasCompletedSetup: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var newGoalTitle: String = ""
    
    private var helperText: String {
         store.goals.isEmpty
         ? "One goal is enough to begin."
         : "You can always adjust this later."
    }
     
    var body: some View {
        NavigationView {
            VStack {
                Text(helperText)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                    .padding(.top, 50)
        
                HStack {
                    TextField("Enter goal", text: $newGoalTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        guard !newGoalTitle.isEmpty else { return }
                        store.addGoal(title: newGoalTitle)
                        newGoalTitle = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding()

                List {
                    ForEach(store.goals) { goal in
                   // ForEach(store.goals.filter { $0.status != .deleted }) { goal in
                        HStack {
                            Text(goal.title)
                            Spacer()
                            Button(action: {
                                if let index = store.goals.firstIndex(where: { $0.id == goal.id }) {
                                    store.goals.remove(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: store.deleteGoal)
                }

                if !store.goals.isEmpty {
                    Button("Done") {
                        hasCompletedSetup = true
                        dismiss()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
          //  .navigationTitle("Setup Goals")
          //  .navigationBarTitleDisplayMode(.inline)
        }
        .navigationTitle("Setup Goals")
        .navigationBarTitleDisplayMode(.inline)
    }
}
