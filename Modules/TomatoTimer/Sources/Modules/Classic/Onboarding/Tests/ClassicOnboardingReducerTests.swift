import XCTest
import ComposableArchitecture
@testable import TomatoTimer

// swiftlint:disable force_cast

@MainActor
final class ClassicOnboardingReducerTests: XCTestCase {

    var sut: TestStoreOf<ClassicOnboardingReducer>!
    var mockServices: MockServices!

    override func setUp() async throws {
        sut = TestStore(initialState: ClassicOnboardingReducer.State(), reducer: ClassicOnboardingReducer())
        mockServices = MockServices()
    }

    func test_onAppear_should_mark_onboarding_presented() async {
        sut.dependencies.services = mockServices
        await sut.send(.onAppear)
        XCTAssertEqual(mockServices.mockUserDefaultsService.setValue as! Bool, true)
    }

    func test_skip_button_pressed_dismisses_view() async {
        let isDismissInvoked = LockIsolated(false)
        sut.dependencies.dismiss = .init({
            isDismissInvoked.setValue(true)
        })

        await sut.send(.skipButtonTapped)

        XCTAssertEqual(isDismissInvoked.value, true)
    }

    func test_finish_button_pressed_dismisses_view() async {
        let isDismissInvoked = LockIsolated(false)
        sut.dependencies.dismiss = .init({
            isDismissInvoked.setValue(true)
        })

        await sut.send(.finishButtonTapped)

        XCTAssertEqual(isDismissInvoked.value, true)
    }
}
