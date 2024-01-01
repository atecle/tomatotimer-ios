import UIKit
import UserNotifications
import SwiftUI
import ComposableArchitecture
import XCTestDynamicOverlay
import CoreData

@main
struct TomatoTimerApp: SwiftUI.App {
    // MARK: - Properties

    let store = Store(
        initialState: AppReducer.State(showNewApp: true),
        reducer: AppReducer().transformDependency(\.self) {
            $0.userNotifications = .liveValue
        }
    )

    var viewStore: ViewStore<Void, AppReducer.Action> {
        ViewStore(self.store.stateless)
    }

    @Environment(\.scenePhase) var scenePhase

    // MARK: - Init

    init() {
        viewStore.send(.appDelegate(.didFinishLaunching))
    }

    // MARK: - View

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                AppView(store: store)
                    .onChange(of: scenePhase) { newScenePhase in
                        switch newScenePhase {
                        case .active:
                            viewStore.send(.classicHome(.timer(.checkNotificationStatus)))
                        default:
                            break
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                        viewStore.send(.appDelegate(.didEnterBackground))
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        viewStore.send(.appDelegate(.didBecomeActive))
                    }
            }
        }
    }
}
