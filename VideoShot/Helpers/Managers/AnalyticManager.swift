//
//  AnalyticManager.swift
//  FreezeFrame
//
//  Created by admin on 13/10/25.
//

import Foundation
import AmplitudeSwift

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    let amplitude: Amplitude

    private init() {
        amplitude = Amplitude(configuration: Configuration(apiKey: "51810c4e10312cdf3aecde68b624b581"))
    }

    func logEvent(_ name: String, properties: [String: Any]? = nil) {
        amplitude.track(eventType: name, eventProperties: properties)
    }
}
