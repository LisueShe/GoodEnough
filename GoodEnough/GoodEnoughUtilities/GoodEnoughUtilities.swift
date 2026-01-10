//
//  utilities.swift
//  GoodEnough
//
//  Created by Lisue Jocelyn She on 1/7/26.
//

import Foundation

struct DayTracker {
    static let lastActiveDayKey = "lastActiveDay"

    static func isNewDay() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastDate = UserDefaults.standard.object(forKey: lastActiveDayKey) as? Date else {
            UserDefaults.standard.set(today, forKey: lastActiveDayKey)
            return false
        }

        if !calendar.isDate(today, inSameDayAs: lastDate) {
            UserDefaults.standard.set(today, forKey: lastActiveDayKey)
            return true
        }

        return false
    }
}
