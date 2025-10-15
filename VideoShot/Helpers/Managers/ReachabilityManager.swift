//
//  ReachabilityManager.swift
//  FreezeFrame
//
//  Created by admin on 13/10/25.
//

import Foundation
import Network

extension Notification.Name {
    static let internetConnectionRestored = Notification.Name("InternetConnectionRestored")
}

class ReachabilityManager {
    static let shared = ReachabilityManager()
    
    private let monitor: NWPathMonitor
    private var wasConnected: Bool = false
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isNowConnected = path.status == .satisfied
            
            if !self.wasConnected && isNowConnected {
                self.postConnectionRestoredNotification()
            }
            
            self.wasConnected = isNowConnected
        }
        
        let queue = DispatchQueue(label: "com.appriqo.VideoShot.ReachabilityMonitor")
        monitor.start(queue: queue)
    }
    
    private func postConnectionRestoredNotification() {
        NotificationCenter.default.post(name: .internetConnectionRestored, object: nil)
    }
}
