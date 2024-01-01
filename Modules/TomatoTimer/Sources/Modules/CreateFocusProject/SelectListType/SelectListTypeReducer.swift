import Foundation
import ComposableArchitecture

enum FocusListType: Equatable {
    case standard
    case session
    case singleTask
    case none
}

extension FocusList {
    var listType: FocusListType {
        switch self {
        case .standard: return .standard
        case .session: return .session
        case .singleTask: return .singleTask
        case .none: return .none
        }
    }

    var isPlusFeature: Bool {
        switch self {
        case .standard, .session: return true
        default: return false
        }
    }
}

struct SelectListTypeReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case viewDidAppear
        case setDidPurchasePlus(Bool)
        case selectedListType(FocusList)

        case paywall(PresentationAction<PaywallReducer.Action>)
    }

    struct State: Equatable {
        let selectedTimerType: TimerType
        var selectedListType: FocusList = .standard(.init())
        var didPurchasePlus: Bool = false

        @PresentationState var paywall: PaywallReducer.State?

        var listItems: [FocusList] {
            switch selectedTimerType {
            case .standard:
                    return FocusList.allCases
            case .stopwatch:
                return FocusList.allCases.filter { !$0.isSession }
            }
        }
    }

    // MARK: - Properties

    @Dependency(\.userClient) var userClient

    // MARK: - Methods

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewDidAppear:
                return monitor()

            case let .setDidPurchasePlus(didPurchase):
                state.didPurchasePlus = didPurchase
                return .none

            case let .selectedListType(type):
                if type.isPlusFeature && !state.didPurchasePlus {
                    let reason: PaywallReason
                    switch type {
                    case .standard:
                        reason = .standardList
                    case .session:
                        reason = .sessionList
                    default:
                        return .none
                    }

                    state.paywall = .init(paywallReason: reason)
                    return .none
                }

                state.selectedListType = type
                return .none

            case .paywall:
                return .none
            }
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
    }

    func monitor() -> EffectTask<Action> {
        userClient.monitorUser()
            .catchToEffect()
            .map { result in
                switch result {
                case let .success(user):
                    return .setDidPurchasePlus(user.didPurchasePlus)
                case .failure:
                    fatalError()
                }
            }
    }
}
