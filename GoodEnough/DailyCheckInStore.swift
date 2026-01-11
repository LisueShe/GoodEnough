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

struct DailyGoalData: Codable {
    let completedGoalIDs: [UUID]
    let activeGoalIDs: [UUID]
    let date: Date
}

struct DailyHistory: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let completedGoals: [UUID]
    let mood: Mood?
}

struct SavedCheckInData: Codable {
    let history: [DailyHistory]
    let lastSavedDate: Date
}

struct DailyReflection {
    static func generate(
        mood: Mood?,
        completed: Int,
        total: Int
    ) -> String {
        if completed == 0 {
            //"Today is complete 🌱"
            return "Showing up is still progress. Rest without guilt."
        }

        if completed < total {
            return "You made progress today. That matters."
        }

        return "You honored your intentions today. Well done."
    }
}

enum TomorrowIntent: String, Codable {
    case same
    case lighter
    case undecided
}

class DailyCheckInStore: ObservableObject {
    @Published var isLocked = false
    @Published var selectedMood: Mood? = nil {
            didSet { save() }
    }
    @Published private(set) var lastSavedDate: Date = Date()
    @Published private(set) var history: [DailyHistory] = []

    private let storageKey = "DailyCheckInData"

    init() {
        load()
    }

    func lockToday() {
        isLocked = true
        save()
    }

    func unlockToday() {
        isLocked = false
        save()
    }

    func saveDay(completedGoals: [UUID]) {
        let today = Calendar.current.startOfDay(for: Date())
        let record = DailyHistory(date: today, completedGoals: completedGoals, mood: selectedMood)
        history.append(record)
        lastSavedDate = today
        save()
    }

    func resetForNewDay() {
        selectedMood = nil
        isLocked = false
        save()
    }
    
    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(SavedCheckInData.self, from: data)
        else { return }
        
        history = decoded.history
        lastSavedDate = decoded.lastSavedDate
    }

    private func save() {
        let data = SavedCheckInData(history: history, lastSavedDate: lastSavedDate)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
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

extension DailyGoalStore {
    func initializeForToday(with allGoals: [Goal]) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // If lastSavedDate is today, do nothing
        if let last = lastSavedDate, Calendar.current.isDate(last, inSameDayAs: today) {
            return
        }

        // Reset for new day
        resetForNewDay()
        activeGoalIDs = Set(allGoals.map { $0.id })
        lastSavedDate = today
    }
}
