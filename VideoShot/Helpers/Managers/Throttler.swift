//
//  Trottler.swift
//  FreezeFrame
//
//  Created by admin on 13/10/25.
//

import Foundation

class Throttler {
    private var lastRun: Date = Date.distantPast
    private let queue: DispatchQueue
    private let interval: TimeInterval
    private let syncQueue = DispatchQueue(label: "throttler.sync.queue")

    init(interval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.interval = interval
        self.queue = queue
    }

    func throttle(action: @escaping () -> Void) {
        syncQueue.sync {
            let now = Date()
            let timeSinceLastRun = now.timeIntervalSince(lastRun)

            if timeSinceLastRun >= interval {
                lastRun = now
                queue.async(execute: action)
            }
        }
    }
}

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
   
 init(delay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.delay = delay
        self.queue = queue
    }
 func debounce(action: @escaping (() -> Void)) {
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            action()
            self?.workItem = nil
        }
        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
