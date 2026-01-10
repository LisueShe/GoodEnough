//
//  DailyCheckInStore.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/4/26.
//

import Foundation
import SwiftUI

struct DailyCheckInData: Codable {
    let selectedMood: Mood?
    let isLocked: Bool
    let date: Date
}

class DailyCheckInStore: ObservableObject {
  //  @Published var selectedMood: Mood?
  //  @Published var isLocked: Bool = false
    private let moodKey = "daily_mood"
    private let dateKey = "daily_mood_date"

    @Published var selectedMood: Mood? {
        didSet { save() }
    }

    @Published var isLocked: Bool = false {
        didSet { save() }
    }

    private let storageKey = "DailyCheckIn"
    
    init() {
        load()
    }

    func lockToday() {
        isLocked = true
    }

    func unlockToday() {
        isLocked = false
    }

    private func save() {
            let data = DailyCheckInData(
                selectedMood: selectedMood,
                isLocked: isLocked,
                date: Date()
            )

            if let encoded = try? JSONEncoder().encode(data) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
            }
        }

        private func load() {
            guard
                let data = UserDefaults.standard.data(forKey: storageKey),
                let decoded = try? JSONDecoder().decode(DailyCheckInData.self, from: data)
            else { return }

            selectedMood = decoded.selectedMood
            isLocked = decoded.isLocked
        }
    
    func resetForNewDay() {
        selectedMood = nil
        isLocked = false
    }
}

struct DailyGoalData: Codable {
    let completedGoalIDs: [UUID]
    let activeGoalIDs: [UUID]
    let date: Date
}

class DailyGoalStore: ObservableObject {

    @Published var activeGoalIDs: Set<UUID> = [] {
        didSet { save() }
    }

    @Published var completedGoalIDs: Set<UUID> = [] {
        didSet { save() }
    }

    private let storageKey = "DailyGoals"
    private var lastSavedDate: Date?

    // MARK: - Computed
    func allGoalsCompleted(allGoals: [Goal]) -> Bool {
        let goalsToCheck: Set<UUID>
        if !activeGoalIDs.isEmpty {
            goalsToCheck = activeGoalIDs
        } else {
            goalsToCheck = Set(allGoals.map { $0.id })
        }

        return !goalsToCheck.isEmpty && goalsToCheck.isSubset(of: completedGoalIDs)
    }


    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Public API

    /// Call this once per day when goals are known
   
    func initializeForToday(with allGoalIDs: [UUID]) {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = lastSavedDate, lastDate == today {
            // Today’s data exists, do nothing
            return
        }

        // Fresh day
        activeGoalIDs = Set(allGoalIDs)
        completedGoalIDs = []
        save()
    }
    
    func toggleGoal(_ id: UUID) {
        if !activeGoalIDs.isEmpty && !activeGoalIDs.contains(id) {
            return
        }
       // guard activeGoalIDs.contains(id) else { return }

        if completedGoalIDs.contains(id) {
            completedGoalIDs.remove(id)
        } else {
            completedGoalIDs.insert(id)
        }
    }

    func setActiveGoals(_ ids: Set<UUID>) {
        activeGoalIDs = ids
        completedGoalIDs = completedGoalIDs.intersection(ids)
    }

    func isGoalActive(_ id: UUID) -> Bool {
        activeGoalIDs.isEmpty || activeGoalIDs.contains(id)
    }
    
    func resetForToday() {
        completedGoalIDs.removeAll()
        activeGoalIDs.removeAll()
        save()
    }

    func resetForNewDay() {
        completedGoalIDs.removeAll()
        activeGoalIDs.removeAll()
        save()
    }
    // MARK: - Persistence

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(DailyGoalData.self, from: data)
        else { return }

        completedGoalIDs = Set(decoded.completedGoalIDs)
        activeGoalIDs = Set(decoded.activeGoalIDs)
        lastSavedDate = Calendar.current.startOfDay(for: decoded.date)
    }

    private func save() {
        let data = DailyGoalData(
            completedGoalIDs: Array(completedGoalIDs),
            activeGoalIDs: Array(activeGoalIDs),
            date: Date()
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

