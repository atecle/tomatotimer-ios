//
//  RevenueCatClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 6/21/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation

protocol PurchaseClient {
    func fetchPurchases() async throws -> [InAppPurchaseProduct]
    func migratePurchases() async throws -> [InAppPurchase]
    func didPurchaseProduct(product: InAppPurchase) async throws -> Bool
    func purchaseProduct(product: InAppPurchase) async throws
    func restorePurchases() async throws -> [InAppPurchase]
}

struct RevenueCatClient: PurchaseClient {

    enum Error: Swift.Error {
        case generic
    }

    // MARK: - Properties

    // MARK: - Methods

    // MARK: PurchaseClient

    func fetchPurchases() async throws -> [InAppPurchaseProduct] {
        return []
    }

    func migratePurchases() async throws -> [InAppPurchase] {
        return []
    }

    func didPurchaseProduct(product: InAppPurchase) async throws -> Bool {
        return false
    }

    func purchaseProduct(product: InAppPurchase) async throws {
    }

    func restorePurchases() async throws -> [InAppPurchase] {
        return []
    }
}
