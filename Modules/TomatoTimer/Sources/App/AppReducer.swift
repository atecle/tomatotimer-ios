import ComposableArchitecture
import Foundation

struct AppReducer: ReducerProtocol {

    // MARK: - Definitions

    struct State: Equatable {
        var appDelegate: AppDelegateReducer.State = .init()
        var didPurchasePlus: Bool = false

        // Classic
        var classicHome: TomatoTimerHomeReducer.State = .init()
        @PresentationState var classicOnboarding: ClassicOnboardingReducer.State?

        // New App
        var focusTab: FocusTabReducer.State = .init()
        var activityTab: ActivityTabReducer.State = .init()
        var settingsTab: SettingsTabReducer.State = .init()
        @PresentationState var paywall: PaywallReducer.State?
        @PresentationState var onboarding: OnboardingReducer.State?

        // Local state
        var showNewApp: Bool = false
        var tab: Tab = .focus
    }

    enum Tab: Int, Equatable {
        case focus
        case activity
        case user
    }

    enum Action: Equatable {
        case appDelegate(AppDelegateReducer.Action)
        case setTab(Tab)
        case setDidPurchasePlus(Bool)

        case classicHome(TomatoTimerHomeReducer.Action)
        case classicOnboarding(PresentationAction<ClassicOnboardingReducer.Action>)

        case paywall(PresentationAction<PaywallReducer.Action>)
        case focusTab(FocusTabReducer.Action)
        case activityTab(ActivityTabReducer.Action)
        case settingsTab(SettingsTabReducer.Action)
        case onboarding(PresentationAction<OnboardingReducer.Action>)
    }

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.userClient) var userClient
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.date) var date

    var body: some ReducerProtocolOf<Self> {
        Scope(state: \.appDelegate, action: /Action.appDelegate) {
            AppDelegateReducer()
        }
        Scope(state: \.focusTab, action: /Action.focusTab) {
            FocusTabReducer()
        }
        Scope(state: \.activityTab, action: /Action.activityTab) {
            ActivityTabReducer()
        }
        Scope(state: \.settingsTab, action: /Action.settingsTab) {
            SettingsTabReducer()
        }
        Scope(state: \.classicHome, action: /Action.classicHome) {
            TomatoTimerHomeReducer()
        }
        Reduce { state, action in
            switch action {
            case let .setDidPurchasePlus(plus):
                state.didPurchasePlus = plus
                return .none

            case .appDelegate(.didFinishLaunching):
                state.showNewApp = UserDefaults.standard.bool(forKey: "classic_mode") == false

                let didPresentOnboarding: Bool = services.userDefaultsService.getValue(key: .presentedOnboarding) ?? false
                if !didPresentOnboarding && state.showNewApp {
                    state.classicOnboarding = ClassicOnboardingReducer.State()
                }

                return userClient.monitorUser()
                    .catchToEffect().map { result in
                        switch result {
                        case let .success(user):
                            return .setDidPurchasePlus(user.didPurchasePlus)
                        case .failure:
                            fatalError()
                        }
                    }

            case .appDelegate(.willTerminate):
                return .none

            case .appDelegate(.didEnterBackground):
                services.userDefaultsService.setValue(key: .didEnterBackground, value: date())
                return .none

            case .appDelegate(.didBecomeActive):
                let activeDate = date()
                guard let resumedDate: Date = services.userDefaultsService.getValue(key: .didEnterBackground) else {
                    return .none
                }
                let elapsed = Int(activeDate.timeIntervalSince(resumedDate))
                services.userDefaultsService.setValue(key: .didEnterBackground, value: (nil as Date?))
                return .run { [state] send in
                    if state.showNewApp {
                        await send(.focusTab(.setTimeElapsed(elapsed)))
                    } else {
                        await send(.classicHome(.timer(.setTimeElapsed(elapsed))))
                    }
                }

            case .appDelegate:
                return .none

            case .onboarding(.presented(.delegate(.createFirstTimer))):
                return .run { send in
                    await send(.focusTab(.plusButtonPressed))
                }
                .delay(for: .seconds(1), scheduler: mainQueue)
                .eraseToEffect()

            case .classicOnboarding(.presented(.skipButtonTapped)), .classicOnboarding(.presented(.finishButtonTapped)):
                return .run { send in
                    await send(.focusTab(.presentNewFeaturesOnboarding))
                }
                .delay(for: .seconds(1), scheduler: mainQueue)
                .eraseToEffect()

            case let .setTab(tab):
                if tab == .activity && !state.didPurchasePlus {
                    state.paywall = .init()
                    return .none
                }
                state.tab = tab
                return .none

            case .classicHome, .onboarding, .classicOnboarding, .focusTab, .settingsTab, .activityTab, .paywall:
                return .none
            }
        }
        .ifLet(\.$classicOnboarding, action: /Action.classicOnboarding) {
            ClassicOnboardingReducer()
        }
        .ifLet(\.$onboarding, action: /Action.onboarding) {
            OnboardingReducer()
        }
        .ifLet(\.$paywall, action: /Action.paywall) {
            PaywallReducer()
        }
    }
}
