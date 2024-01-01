import SwiftUI
import Foundation

extension TomatoTimerView {
    struct ViewState: Equatable {
        var timerState: TomatoTimer
        var animation: TomatoTimerReducer.Animation?
        var themeColor: Color
    }
}

extension TomatoTimerReducer.State {
    var toViewState: TomatoTimerView.ViewState {
        return TomatoTimerView.ViewState(
            timerState: tomatoTimer,
            animation: animation,
            themeColor: settings.themeColor.asColor
        )
    }
}
