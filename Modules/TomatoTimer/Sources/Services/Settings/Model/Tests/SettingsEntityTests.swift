//
//  SettingsEntityTests.swift
//  TomatoTimerTests
//
//  Created by adam tecle on 6/29/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import XCTest
import UIColorHexSwift
import ComposableArchitecture
@testable import TomatoTimer

final class SettingsEntityTests: EntityTestCase {

    // swiftlint:disable function_body_length
    override func test_update() {
        let settings = Settings()
        let entity = SettingsEntity(context: context)

        entity.update(from: settings, context: context)
        XCTAssertEqual(
            entity.id,
            settings.id
        )
        XCTAssertEqual(
            entity.totalSecondsInWorkSession,
            Int64(settings.timerConfig.totalSecondsInWorkSession)
        )
        XCTAssertEqual(
            entity.totalSecondsInShortBreakSession,
            Int64(settings.timerConfig.totalSecondsInShortBreakSession)
        )
        XCTAssertEqual(
            entity.totalSecondsInLongBreakSession,
            Int64(settings.timerConfig.totalSecondsInLongBreakSession)
        )
        XCTAssertEqual(
            entity.numberOfTimerSessions,
            Int64(settings.timerConfig.numberOfTimerSessions)
        )
        XCTAssertEqual(
            entity.shouldAutostartNextWorkSession,
            settings.timerConfig.shouldAutostartNextWorkSession
        )
        XCTAssertEqual(
            entity.shouldAutostartNextBreakSession,
            settings.timerConfig.shouldAutostartNextBreakSession
        )
        XCTAssertEqual(
            entity.themeColorHexString,
            settings.themeColor.hexString()
        )
        XCTAssertEqual(
            entity.usingCustomColor,
            settings.usingCustomColor
        )
        XCTAssertEqual(
            entity.usingTodoList,
            settings.usingTodoList
        )
        XCTAssertEqual(
            entity.workSound,
            Int64(settings.workSound.rawValue)
        )
        XCTAssertEqual(
            entity.breakSound,
            Int64(settings.breakSound.rawValue)
        )
        XCTAssertEqual(
            entity.keepDeviceAwake,
            settings.keepDeviceAwake
        )
        XCTAssertEqual(
            entity.purchasedPro,
            settings.purchasedPro
        )
        XCTAssertEqual(
            entity.isZenModeOn,
            settings.isZenModeOn
        )
    }

    override func test_toNonManagedObject() {
        let settings = Settings()
        let entity = SettingsEntity(context: context)

        entity.update(from: settings, context: context)
        // XCTAssertNoDifference(entity.toNonManagedObject(), settings)
    }

}
