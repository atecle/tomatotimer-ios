import Foundation
import ComposableArchitecture

public typealias TestStoreOf<R: ReducerProtocol> = TestStore<R.State, R.Action, R.State, R.Action, ()>
