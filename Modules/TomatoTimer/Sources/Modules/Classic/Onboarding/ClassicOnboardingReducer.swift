import Foundation
import ComposableArchitecture

struct ClassicOnboardingReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case onAppear
        case skipButtonTapped
        case finishButtonTapped
    }

    struct State: Equatable {}

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.dismiss) var dismiss

    // MARK: - Methods

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            services.userDefaultsService.setValue(key: .presentedOnboarding, value: true)
            return .none
        case .skipButtonTapped, .finishButtonTapped:
            return .fireAndForget {
                await self.dismiss()
            }
        }
    }
}
