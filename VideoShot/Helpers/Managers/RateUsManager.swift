//
//  RateUsManager.swift
//  VideoShot
//
//  Created by admin on 15/10/25.
//

import StoreKit

final class RateUsManager {
    
    // MARK: - Singleton
    
    static let shared = RateUsManager()
    private init() {}
    
    // MARK: - Keys
    
    private let shownCountKey = "rateus.shown.count"
    private let lastResetKey = "rateus.last.reset.date"
    private let sessionCountKey = "rateus.session.count"
    private let screenTapCountKey = "rateus.screen.tap.count"
    private let lastShownDateKey = "rateus.last.shown.date"
    
    // MARK: - Constants
    
    private let maxShowsPerYear = 3
    private let oneYear: TimeInterval = 365 * 24 * 60 * 60
    private let minIntervalBetweenPrompts: TimeInterval = (365.0 / 3.0) * 24 * 60 * 60
    
    // MARK: - Public API
    
    func trackSessionStart() {
        resetIfNeeded()
        
        let defaults = UserDefaults.standard
        let sessions = defaults.integer(forKey: sessionCountKey) + 1
        defaults.set(sessions, forKey: sessionCountKey)
        
        if sessions == 2 {
            requestRateIfPossible()
            AnalyticsManager.shared.logEvent("2session.rateus")
        }
    }
    
    func handleScreenButtonTap() {
        resetIfNeeded()
        
        let defaults = UserDefaults.standard
        let taps = defaults.integer(forKey: screenTapCountKey) + 1
        defaults.set(taps, forKey: screenTapCountKey)
        
        if taps == 3 {
            AnalyticsManager.shared.logEvent("3tap.rateus")
            requestRateIfPossible()
        }
    }
    
    func didTriggerMultiScreen() {
        resetIfNeeded()
        requestRateIfPossible()
        AnalyticsManager.shared.logEvent("multiscreen.rateus")
    }
    
    // MARK: - Core logic
    
    private func requestRateIfPossible() {
        let defaults = UserDefaults.standard
        let shownCount = defaults.integer(forKey: shownCountKey)
        guard shownCount < maxShowsPerYear else { return }
        
        if let lastShown = defaults.object(forKey: lastShownDateKey) as? Date,
           Date().timeIntervalSince(lastShown) < minIntervalBetweenPrompts {
            return
        }
        
        SKStoreReviewController.requestReview()
        
        defaults.set(shownCount + 1, forKey: shownCountKey)
        defaults.set(Date(), forKey: lastShownDateKey)
    }
    
    // MARK: - Year reset
    
    private func resetIfNeeded() {
        let defaults = UserDefaults.standard
        let now = Date()
        
        if let lastReset = defaults.object(forKey: lastResetKey) as? Date {
            if now.timeIntervalSince(lastReset) > oneYear {
                resetCounters()
            }
        } else {
            defaults.set(now, forKey: lastResetKey)
        }
    }
    
    private func resetCounters() {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: shownCountKey)
        defaults.set(0, forKey: sessionCountKey)
        defaults.set(0, forKey: screenTapCountKey)
        defaults.removeObject(forKey: lastShownDateKey)
        defaults.set(Date(), forKey: lastResetKey)
    }
}
