import Foundation
import ComposableArchitecture

struct FocusListReducer: ReducerProtocol {

    // MARK: - Definitions

    enum Action: Equatable {
        case standard(StandardListReducer.Action)
        case session(SessionListReducer.Action)
    }

    enum State: Equatable {
        case standard(StandardListReducer.State)
        case session(SessionListReducer.State)

        init?(
            project: FocusProject
        ) {
            switch project.list {
            case let .standard(list):
                self = .standard(StandardListReducer.State(list: list, project: project))
            case let .session(list):
                self = .session(SessionListReducer.State(list: list, project: project))
            default:
                return nil
            }
        }
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocolOf<Self> {
        Scope(state: /State.standard, action: /Action.standard) {
            StandardListReducer()
        }
        Scope(state: /State.session, action: /Action.session) {
            SessionListReducer()
        }
        Reduce { _, action in
            switch action {
            case .standard, .session:
                return .none
            }
        }
    }
}
