import XCTest
import ComposableArchitecture

@testable import TomatoTimer

@MainActor
final class AppReducerTests: XCTestCase {

    var sut: TestStoreOf<AppReducer>!
    var mockServices: MockServices!

    override func setUp() async throws {
        sut = TestStore(initialState: AppReducer.State(showNewApp: true), reducer: AppReducer())
        mockServices = .init()
    }

    func test_presentation_state_is_initially_nil() async {
        XCTAssertNil(sut.state.onboarding)
    }

    func test_destination_changes_to_onboarding_if_not_presented() async {
        mockServices.mockUserDefaultsService.getValueResponse = false
        sut.dependencies.services = mockServices
        await sut.send(.appDelegate(.didFinishLaunching)) {
            $0.onboarding = .init()
        }
    }

    func test_no_presentation_state_if_onboarding_already_presented() async {
        mockServices.mockUserDefaultsService.getValueResponse = true
        sut.dependencies.services = mockServices
        await sut.send(.appDelegate(.didFinishLaunching))
    }

    func test_didBecomeActive_should_set_time_elapsed_if_didEnterBackground_is_present_in_user_defaults() async {

    }

    func test_didBecomeActive_should_not_set_time_elapsed_if_didEnterBackground_is_not_present_in_user_defaults() async {

    }

}
