//
//  InFlightNotificationsHandler.swift
//  TomatoTimer
//
//  Created by adam on 12/25/19.
//  Copyright © 2019 Adam Tecle. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

// An object with 3 responsibilities
// 1. keep track of in flight notifications in an array
// 2. print debug info when scheduling/delivering notifications
// 3. respond to notification system events to appropriately
// swiftlint:disable all
class InFlightNotificationsHandler: NSObject, UNUserNotificationCenterDelegate {

    private(set) var inFlightNotifications: [UNNotificationRequest] = []

    override init() {
        super.init()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func trackNotification(_ notification: UNNotificationRequest) {
        print(
            "=========== Scheduling notification with ID \(notification.identifier) || Rings in \(printSecondsToHoursMinutesSeconds(seconds: Int((notification.trigger! as! UNTimeIntervalNotificationTrigger).timeInterval))) || Title: \(notification.content.title) || Body: \(notification.content.body)"
        )
        inFlightNotifications.append(notification)
    }

    @objc func clearInFlightNotifications() {
        inFlightNotifications = []
        print("============ removing all notifications")
        print("\n\n")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("=========== Delivering notification with id \(notification.request.identifier)")
        inFlightNotifications.removeAll { notification.request.identifier == $0.identifier }

        print("\n\n")

        completionHandler([.banner, .sound])
    }
}

func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

func printSecondsToHoursMinutesSeconds(seconds: Int) -> String {
    let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
    return "\(h) Hours, \(m) Minutes, \(s) Seconds"
}

func secondsToHoursMinutesSeconds(seconds: Double) -> (Double, Double, Double) {
    let (hr, minf) = modf(seconds / 3600)
    let (min, secf) = modf(60 * minf)
    return (hr, min, 60 * secf)
}
