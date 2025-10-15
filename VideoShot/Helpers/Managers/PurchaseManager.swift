//
//  PurchaseManager.swift
//  FreezeFrame
//
//  Created by admin on 11/10/25.
//

import AppKit
import RevenueCat

extension Notification.Name {
    static let purchaseSuccess = Notification.Name("purchaseSuccess")
    static let purchaseFailed = Notification.Name("purchaseFailed")
    static let purchaseCancelled = Notification.Name("purchaseCancelled")
    static let restoreSuccess = Notification.Name("restoreSuccess")
    static let restoreFailed = Notification.Name("restoreFailed")
    static let nothingToRestore = Notification.Name("nothingToRestore")
    static let subscriptionsVerified = Notification.Name("subscriptionsVerified")
}

enum Products: String, CaseIterable {
    case weekly = "com.appriqo.videoshotpro.weekly"
    case monthly = "com.appriqo.videoshotpro.monthly"
    
    var entitlemets: String {
        switch self {
        case .weekly:
            return "videoshotpro.weekly"
        case .monthly:
            return "videoshotpro.monthly"
        }
    }
}

final class PurchaseManager: NSObject {
    
    // MARK: - Sigleton
    
    static let shared = PurchaseManager()
    
    private override init() {
#if DEBUG
        Purchases.logLevel = .debug
#else
        Purchases.logLevel = .error
#endif
        Purchases.configure(withAPIKey: "appl_DCarOtClFhuPvTSZlqOuhgklIVh")
        super.init()
        fetchProducts()
        checkSubscriptionStatus()
        Purchases.shared.delegate = self
    }
    
    // MARK: - Private
    var products: [StoreProduct] = []
    
    var isSubscribed: Bool {
        get async {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                return customerInfo.entitlements.active.contains { $0.value.isActive }
            } catch {
                return false
            }
        }
    }
    
    var isFree: Bool = false
    
    // MARK: - Helpers
    
    func checkSubscriptionStatus(completion: (() -> Void)? = nil) {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let info = customerInfo else { return }

            let entitlementsToCheck = [Products.weekly.entitlemets, Products.monthly.entitlemets]

            let isPremium = entitlementsToCheck.contains { key in
                info.entitlements.all[key]?.isActive == true
            }
            self?.isFree = isPremium
            NotificationCenter.default.post(name: .subscriptionsVerified, object: nil)
        }
    }
    
    func fetchProducts(completion: (() -> Void)? = nil) {
        let productIds = Products.allCases.map { $0.rawValue }
        Purchases.shared.getProducts(productIds) { [weak self] products in
            guard let self else { return }
            self.products = products
            completion?()
        }
    }
    
    func isTrialActiveForUser() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            for entitlement in customerInfo.entitlements.active.values {
                if entitlement.isActive,
                   entitlement.latestPurchaseDate != nil,
                   entitlement.willRenew == true,
                   entitlement.periodType == .trial {
                    return true
                }
            }
            return false
        } catch {
            return false
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: StoreProduct) {
        Purchases.shared.purchase(product: product) { transaction, customerInfo, error, userCancelled in
            if let error = error {
                AnalyticsManager.shared.logEvent("Purchase.failed")
                NotificationCenter.default.post(name: .purchaseFailed, object: error)
            } else if userCancelled {
                AnalyticsManager.shared.logEvent("Purchase.cancelled")
                NotificationCenter.default.post(name: .purchaseCancelled, object: nil)
            } else {
                AnalyticsManager.shared.logEvent("Purchase.success")
                NotificationCenter.default.post(name: .purchaseSuccess, object: nil)
                self.checkSubscriptionStatus()
            }
        }
    }
    
    // MARK: - Restore purchases
    func restorePurchases() {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                AnalyticsManager.shared.logEvent("Restore.failed")
                NotificationCenter.default.post(name: .restoreFailed, object: error)
            } else {
                guard let customerInfo = customerInfo else {
                    AnalyticsManager.shared.logEvent("Restore.nothing")
                    NotificationCenter.default.post(name: .nothingToRestore, object: nil)
                    return
                }
                AnalyticsManager.shared.logEvent("Restore.success")
                NotificationCenter.default.post(name: .restoreSuccess, object: nil)
                self.checkSubscriptionStatus()
            }
        }
    }
    
    // MARK: - Customer Info
    private func fetchCustomerInfo() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let self, let info = customerInfo else { return }
            checkSubscriptionStatus()
        }
    }
    
    
    func hasTrial(_ product: StoreProduct) -> Bool {
        guard let discount = product.introductoryDiscount else { return false }
        return discount.paymentMode == .freeTrial
    }
    
    // MARK: - Convenience methods
    
    func product(with id: Products) -> StoreProduct? {
        return products.first { $0.productIdentifier == id.rawValue }
    }
    
    func currentSubscriptionStatus() async -> Bool {
        do {
            let info = try await Purchases.shared.customerInfo()
            return info.entitlements.active.contains { $0.value.isActive }
        } catch {
            print("Ошибка проверки подписки: \(error)")
            return false
        }
    }
    
    func purchaseMonthly() {
        guard let product = product(with: .monthly) else { return }
        purchase(product)
    }
    
    func purchaseWeekly() {
        guard let product = product(with: .weekly) else { return }
        purchase(product)
    }
    
    private func postSubscriptionStatus(_ customerInfo: CustomerInfo?) {
        let isActive = customerInfo?.entitlements.active.contains { $0.value.isActive } ?? false
        NotificationCenter.default.post(name: .subscriptionsVerified, object: isActive)
    }
}

// MARK: - PurchasesDelegate

extension PurchaseManager: PurchasesDelegate {
    
}
