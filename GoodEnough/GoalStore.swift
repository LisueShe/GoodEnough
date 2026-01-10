//
//  GoalStore.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/2/26.
//

import Foundation
import Combine

class GoalStore: ObservableObject {
    @Published var goals: [Goal] = [] {
        didSet {
            saveGoals()
        }
    }
    
    init() {
        loadGoals()

        if !goals.isEmpty {
            UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        }
    }

    func addGoal(title: String) {
        let newGoal = Goal(id: UUID(), title: title)
        goals.append(newGoal)
    }
    
    func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
    
    func updateGoal(goal: Goal, title: String) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].title = title
        }
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "goals")
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
    }
}
