//
//  ProUpgradeReducerTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 6/29/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
import ComposableArchitecture
@testable import TomatoTimer

// swiftlint:disable line_length

@MainActor
final class ProUpgradeReducerTests: XCTestCase {

    func test_purchasePro() async {
        var settings = Settings()
        let sut = TestStore(
            initialState: ProUpgradeReducer.State(
                settings: settings
            ),
            reducer: ProUpgradeReducer()
        )
        let mockServices = MockServices()
        sut.dependencies.services = mockServices
        let isDismissInvoked = LockIsolated(false)
        sut.dependencies.dismiss = .init({
            isDismissInvoked.setValue(true)
        })

        await sut.send(.purchasePro)
        await sut.receive(.setLoading(true)) {
            $0.isLoading = true
        }
        await sut.receive(.didPurchasePro) {
            $0.settings.purchasedPro = true
        }
        settings.purchasedPro = true
        await sut.receive(.delegate(.purchasedPro(settings)))

        await sut.receive(.setLoading(false)) {
            $0.isLoading = false
        }
        XCTAssertEqual(isDismissInvoked.value, true)
    }

    func test_restorePurchases_none_to_restore() async {
        let settings = Settings()
        let sut = TestStore(
            initialState: ProUpgradeReducer.State(
                settings: settings
            ),
            reducer: ProUpgradeReducer()
        )
        let mockServices = MockServices()
        sut.dependencies.services = mockServices
        let isDismissInvoked = LockIsolated(false)
        sut.dependencies.dismiss = .init({
            isDismissInvoked.setValue(true)
        })

        await sut.send(.restorePurchases)
        await sut.receive(.setLoading(true)) {
            $0.isLoading = true
        }
        let alertState: AlertState<ProUpgradeReducer.Action.Alert>? = .init(title: TextState("No Purchases Found"), message: TextState("There are no purchases to restore."))
        await sut.receive(.setAlertState(alertState!)) {
            $0.alert = alertState
        }
        await sut.receive(.setLoading(false)) {
            $0.isLoading = false
        }
    }

    func test_restorePurchases() async {
        var settings = Settings()
        let sut = TestStore(
            initialState: ProUpgradeReducer.State(
                settings: settings
            ),
            reducer: ProUpgradeReducer()
        )
        let mockServices = MockServices()
        //mockServices.mockPurchaseService.restorePurchasesValue = [.tomatoTimerPro]
        sut.dependencies.services = mockServices
        let isDismissInvoked = LockIsolated(false)
        sut.dependencies.dismiss = .init({
            isDismissInvoked.setValue(true)
        })

        await sut.send(.restorePurchases)
        await sut.receive(.setLoading(true)) {
            $0.isLoading = true
        }
        await sut.receive(.didPurchasePro) {
            $0.settings.purchasedPro = true
        }
        settings.purchasedPro = true
        await sut.receive(.delegate(.purchasedPro(settings)))

        await sut.receive(.setLoading(false)) {
            $0.isLoading = false
        }
        XCTAssertEqual(isDismissInvoked.value, true)
    }
}
