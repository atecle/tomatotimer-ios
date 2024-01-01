import Foundation
import ComposableArchitecture

struct SettingsTabReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setDidPurchasePlus(Bool)
        case unlockPlusSectionPressed
        case iCloudSyncSettingsRowPressed
        case advancedSettingsRowPressed
        case setClassicMode(Bool)
        case path(StackAction<Path.State, Path.Action>)
        case paywall(PresentationAction<PaywallReducer.Action>)
    }

    struct State: Equatable {
        var didPurchasePlus: Bool = false
        var classicMode: Bool = false
        var path: StackState<Path.State> = .init()

        @PresentationState var paywall: PaywallReducer.State?
    }

    struct Path: ReducerProtocol {
        enum Action: Equatable {
            case iCloudSync(SyncSettingsReducer.Action)
            case advanced(AdvancedSettingsReducer.Action)
        }

        enum State: Equatable {
            case iCloudSync(SyncSettingsReducer.State)
            case advanced(AdvancedSettingsReducer.State)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.iCloudSync, action: /Action.iCloudSync) {
                SyncSettingsReducer()
            }
            Scope(state: /State.advanced, action: /Action.advanced) {
                AdvancedSettingsReducer()
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.userClient) var userClient

    // MARK: Body

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                state.classicMode = UserDefaults.standard.bool(forKey: "classic_mode")
                return monitor()

            case let .setDidPurchasePlus(purchased):
                state.didPurchasePlus = purchased
                return .none

            case let .setClassicMode(isOn):
                state.classicMode = isOn
                UserDefaults.standard.set(isOn, forKey: "classic_mode")
                return .none

            case .unlockPlusSectionPressed:
                state.paywall = .init()
                return .none

            case .iCloudSyncSettingsRowPressed:
                state.path.append(
                    .iCloudSync(.init())
                )
                return .none

            case .advancedSettingsRowPressed:
                state.path.append(
                    .advanced(.init())
                )
                return .none

            case .path, .paywall:
                return .none
            }
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
        .forEach(\State.path, action: /Action.path) {
            Path()
        }
    }

    func monitor() -> EffectTask<Action> {
        return userClient.monitorUser()
            .catchToEffect().map { result in
                switch result {
                case let .success(user):
                    return .setDidPurchasePlus(user.didPurchasePlus)
                case .failure:
                    fatalError()
                }
            }
    }
}
