import ComposableArchitecture
import Foundation
import Combine

struct AppDelegateReducer: ReducerProtocol {

    // MARK: - Definitions

    struct State: Equatable {}

    public enum Action: Equatable {
        case didFinishLaunching
        case willTerminate
        case didEnterBackground
        case didBecomeActive
    }

    // MARK: - Properties

    @Dependency(\.services) var services
    @Dependency(\.date) var date
    @Dependency(\.userClient) var userClient

    // MARK: - Methods

    public init() {}

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .didFinishLaunching:

            return .run { [services] _ in
                let timers = try await services.timerService.fetchAll()
                let settings = try await services.settingsService.fetchAll()
                let projects = try await services.projectService.fetchAll()
                if timers.isEmpty && settings.isEmpty && projects.isEmpty {
                    try await services.timerService.add(TomatoTimer())
                    try await services.settingsService.add(Settings())
                    try await services.projectService.add(TodoListProject(isActive: true))
                }
            }

        case .didEnterBackground, .didBecomeActive, .willTerminate:
            return .none
        }
    }
}
