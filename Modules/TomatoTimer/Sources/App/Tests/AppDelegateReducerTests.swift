import ComposableArchitecture
import XCTest

@testable import TomatoTimer

@MainActor
final class AppDelegateReducerTests: XCTestCase {

    var sut: TestStoreOf<AppDelegateReducer>!
    var mockServices: MockServices!

    override func setUp() async throws {
        sut = TestStore(
            initialState: AppDelegateReducer.State(),
            reducer: AppDelegateReducer()
            , prepareDependencies: { $0.continuousClock = TestClock() })
        mockServices = MockServices()
    }

    func test_should_create_initial_legacy_data_if_not_present() async {
    }
}
