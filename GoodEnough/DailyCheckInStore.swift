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
    let beenLocked: Bool
    let tomorrowIntent: TomorrowIntent
    let date: Date
}

struct DailyGoalData: Codable {
    let completedGoalIDs: [UUID]
    let activeGoalIDs: [UUID]
    let date: Date
}

struct DailyHistory: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Mood?
    let completedGoals: [UUID]
    let allGoals: [Goal]
    let reflection: String
    
    var tomorrowIntent: TomorrowIntent?
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
/*
enum TomorrowIntent: String, Codable {
    case keepAll
    case startFresh
    case oneGoal
}
*/
enum TomorrowIntent: String, Codable {
    case keepAll
    case startFresh
    case none
}


class DailyCheckInStore: ObservableObject {
    @Published var isLocked = false
    @Published var beenLocked = false
    @Published var selectedMood: Mood? = nil {
            didSet { save() }
    }
    @Published var tomorrowIntent: TomorrowIntent = .none
    @Published private(set) var lastSavedDate: Date = Date()
    @Published private(set) var history: [DailyHistory] = []
   
    private let storageKey = "DailyCheckInData"
    private let duringDaystorageKey = "DuringDayCheckIn"

    init() {
        load()
    }

    func lockToday() {
        isLocked = true
        beenLocked = true
        save()
    }

    func unlockToday() {
        isLocked = false
        saveDuringDay()
    }

    func setTomorrowIntent(_ intent: TomorrowIntent) {
        tomorrowIntent = intent
        saveDuringDay()
    }
    
    func saveDay(
        completedGoals: [UUID],
        totalGoals: Int,
        allGoals: [Goal],
        saveDate: Date
    ) {
        //let today = Calendar.current.startOfDay(for: Date())

        // ⚠️ Prevent duplicate save for same day
       // if history.contains(where: {
       //     Calendar.current.isDate($0.date, inSameDayAs: today)
       // }) {
       //     return
       // }

        let reflection = DailyReflection.generate(
            mood: selectedMood,
            completed: completedGoals.count,
            total: totalGoals
        )

        let entry = DailyHistory(
            id: UUID(),
            date: saveDate,
            mood: selectedMood,
            completedGoals: completedGoals,
            allGoals: allGoals,
            reflection: reflection
        )

        history.append(entry)
        let data = SavedCheckInData(history: history, lastSavedDate: lastSavedDate)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func resetForNewDay() {
        selectedMood = nil
        isLocked = false
        beenLocked = false
        tomorrowIntent = .none
        saveDuringDay()
        save()
    }
    
    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(SavedCheckInData.self, from: data)
        else { return }
        
        history = decoded.history
        lastSavedDate = decoded.lastSavedDate
        
        let today = Calendar.current.startOfDay(for: Date())
        
        guard
            let todayData = UserDefaults.standard.data(forKey: duringDaystorageKey),
            let todayDecoded = try? JSONDecoder().decode(DailyCheckInData.self, from: todayData)
        else { return }
        
        if Calendar.current.isDate(todayDecoded.date, inSameDayAs: today) {
            selectedMood = todayDecoded.selectedMood
            isLocked = todayDecoded.isLocked
            beenLocked = todayDecoded.beenLocked
            lastSavedDate = todayDecoded.date
        }
    }

    private func save() {
        let data = SavedCheckInData(history: history, lastSavedDate: lastSavedDate)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let todayData = DailyCheckInData(selectedMood: selectedMood, isLocked: isLocked, beenLocked: beenLocked, tomorrowIntent: tomorrowIntent, date: today)
        if let encoded = try? JSONEncoder().encode(todayData) {
            UserDefaults.standard.set(encoded, forKey: duringDaystorageKey)
        }
    }
    
    func saveDuringDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayData = DailyCheckInData(selectedMood: selectedMood, isLocked: isLocked, beenLocked: beenLocked, tomorrowIntent: tomorrowIntent, date: today)
        if let encoded = try? JSONEncoder().encode(todayData) {
            UserDefaults.standard.set(encoded, forKey: duringDaystorageKey)
        }
    }
    
    func last7Days() -> [DailyHistory] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: Date())!

        return history.filter {
            $0.date >= calendar.startOfDay(for: start)
        }
    }
}

class DailyGoalStore: ObservableObject {
    private var dailyStatus = DailyCheckInStore()
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
   
    func toggleGoal(_ id: UUID) {
        if !activeGoalIDs.isEmpty && !activeGoalIDs.contains(id) {
            return
        }

        if completedGoalIDs.contains(id) {
            completedGoalIDs.remove(id)
        } else {
            completedGoalIDs.insert(id)
        }
        save()
    }

    func setActiveGoals(_ ids: Set<UUID>) {
        activeGoalIDs = ids
        completedGoalIDs = completedGoalIDs.intersection(ids)
    }

    func isGoalActive(_ id: UUID) -> Bool {
        activeGoalIDs.isEmpty || activeGoalIDs.contains(id)
    }
    
    func resetForToday(with allGoals: [Goal]) {
        completedGoalIDs.removeAll()
        activeGoalIDs.removeAll()
        activeGoalIDs = Set(allGoals.map { $0.id })
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(DailyGoalData.self, from: data)
        else { return }

        let today = Calendar.current.startOfDay(for: Date())
        completedGoalIDs = Set(decoded.completedGoalIDs)
        activeGoalIDs = Set(decoded.activeGoalIDs)
        lastSavedDate = Calendar.current.startOfDay(for: decoded.date)
        
        let store = GoalStore()
        if !Calendar.current.isDate(decoded.date, inSameDayAs: today), !dailyStatus.beenLocked {
            dailyStatus.saveDay(
                completedGoals: decoded.completedGoalIDs,
                totalGoals: decoded.activeGoalIDs.count,
                allGoals: store.goals,
                saveDate: decoded.date
            )
        } else if !Calendar.current.isDate(decoded.date, inSameDayAs: today) {
            initializeForToday(with: store.goals)
        }
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
        if Calendar.current.isDate(dailyStatus.lastSavedDate, inSameDayAs: today) {
            return
        }
        
        switch dailyStatus.tomorrowIntent {
        case .keepAll:
            activeGoalIDs = activeGoalIDs
            
        case .startFresh, .none:
            let ids = allGoals
                .filter { $0.status != .deleted }
                .map(\.id)
            activeGoalIDs = Set(ids)
        }
        
        // Reset for new day
        dailyStatus.resetForNewDay()
        completedGoalIDs.removeAll()
        save()
    }
}
