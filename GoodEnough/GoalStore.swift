//
//  GoalStore.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/2/26.
//

import Foundation
import Combine

enum GoalStatus: String, Codable {
    case created
    case deleted
    case suggested
}

struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var status: GoalStatus
    
    init(id: UUID = UUID(), title: String, date: Date, status: GoalStatus) {
        self.id = id
        self.title = title
        self.date = date
        self.status = status
    }
}

class GoalStore: ObservableObject {
    @Published var goals: [Goal] = [] {
        didSet {
            saveGoals()
        }
    }
    
    init() {
        loadGoals()
        
        // UserDefaults.standard.removeObject(forKey: "hasOnboardingDone")
        // UserDefaults.standard.removeObject(forKey: "hasCompletedSetup")
        // UserDefaults.standard.removeObject(forKey: "goals")
        // UserDefaults.standard.removeObject(forKey: "DailyGoals")
        // UserDefaults.standard.removeObject(forKey: "DailyCheckInData")
        // UserDefaults.standard.removeObject(forKey: "DuringDayCheckIn")
         
    }

    func addGoal(title: String) {
        let newGoal = Goal(id: UUID(), title: title, date: Date(), status: .created)
        goals.append(newGoal)
        saveGoals()
    }
    
    func deleteGoal(at offsets: IndexSet) {
       // goals.remove(atOffsets: offsets)
        for index in offsets {
            goals[index].status = .deleted
        }
        saveGoals()
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
            var validateGoal: [Goal] = []
            for eachGoal in decoded {
                if eachGoal.status == .created || (eachGoal.status == .suggested && Calendar.current.isDate(Date(), inSameDayAs: eachGoal.date)) {
                    validateGoal.append(eachGoal)
                }
            }
            goals = validateGoal
        }
    }
}
