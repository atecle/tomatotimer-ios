import Foundation
import StoreKit
import Combine

protocol PurchaseServiceProvider {
    var purchaseService: PurchaseServiceType { get }
}

protocol PurchaseServiceType {

    func fetchPurchases() async throws -> [InAppPurchaseProduct]

    /// All purchases as of 2023 were done prior to RevenueCat, so they exist Apple-side, but RC doesn't know about them.
    /// This function performs a client-side migration to move those purchases into RC.
    /// Should call on app launch - however subsequent app launches won't perform migration, until the user deletes and reinstalls.
    /// - Returns: A boolean indicating whether there were purchases migrated
    func migratePurchases() async throws -> [InAppPurchase]

    /// Returns whether the user has purchased a particular IAP
    /// - Parameter product: An IAP
    /// - Returns: A boolean of whether the IAP was purchased
    func didPurchaseProduct(product: InAppPurchase) async throws -> Bool

    /// Purchases an IAP
    /// - Parameter product: The IAP to purchase
    func purchaseProduct(product: InAppPurchase) async throws

    /// Restores purchases
    func restorePurchases() async throws -> [InAppPurchase]
}

enum InAppPurchase: String, Equatable, CaseIterable {
    case tomatoTimerPro = "com.adamtecle.TomatoTimer.IAP.Pro"
    case tomatoTimerPlus = "com.adamtecle.tomatotimer.iap.plus"

    var entitlementID: String {
        switch self {
        case .tomatoTimerPro: return "tomato_timer_pro"
        case .tomatoTimerPlus: return "tomato_timer_plus"
        }
    }
}

struct InAppPurchaseProduct: Equatable {
    let type: InAppPurchase
    let price: String

    init?(
        productID: String,
        price: String
    ) {
        guard let type = InAppPurchase(rawValue: productID) else { return nil }
        self.type = type
        self.price = price
    }

}

struct PurchaseService: PurchaseServiceType {

    // MARK: - Definitions

    // MARK: - Properties

    private let purchaseClient: PurchaseClient
    private let userDefaultsService: UserDefaultsServiceType

    // MARK: - Methods

    init(
        purchaseClient: PurchaseClient,
        userDefaultsService: UserDefaultsServiceType
    ) {
        self.purchaseClient = purchaseClient
        self.userDefaultsService = userDefaultsService
    }

    // MARK: PurchaseServiceType

    func fetchPurchases() async throws -> [InAppPurchaseProduct] {
        return try await purchaseClient.fetchPurchases()
    }

    func migratePurchases() async throws -> [InAppPurchase] {
        return try await purchaseClient.migratePurchases()
    }

    func didPurchaseProduct(
        product: InAppPurchase
    ) async throws -> Bool {
        return try await purchaseClient.didPurchaseProduct(product: product)
    }

    func purchaseProduct(product: InAppPurchase) async throws {
        return try await purchaseClient.purchaseProduct(product: product)
    }

    func restorePurchases() async throws -> [InAppPurchase] {
        return try await purchaseClient.restorePurchases()
    }
}
