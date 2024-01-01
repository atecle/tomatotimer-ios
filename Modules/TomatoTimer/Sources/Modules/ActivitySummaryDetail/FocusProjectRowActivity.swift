import Foundation
import SwiftUI
import ComposableArchitecture

struct FocusProjectRowActivity: View {

    let project: FocusProject

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(project.emoji)")
                    .padding(10)
                    .background(project.themeColor.asColor)
                    .cornerRadius(10)

                VStack(alignment: .leading) {
                    Text("\(project.title)")
                        .strikethrough(project.timer.isComplete)
                        .bold()
                    HStack {

                        Text("\(Image(systemSymbol: .clockFill)) \(project.timer.shortDescription)")
                        Text("\(Image(systemSymbol: .checklist)) \(project.list.shortDescription)")
                    }
                    .foregroundColor(UIColor.secondaryLabel.asColor)
                    .font(.caption)
                }
                Spacer()

                HStack {
                    Spacer()
                    Group {
                        if project.timer.wasStarted {
                            if project.timer.currentSession.isBreak {
                                Text("\(project.timer.totalElapsedTimeString)")
                                    .bold()
                                    .foregroundColor(project.timer.displayColor)
                                Image(systemName: "timer.circle.fill")
                                    .background(UIColor.label.asColor.opacity(0.05))
                                    .foregroundColor(project.timer.displayColor)
                            } else {
                                Text("\(project.timer.totalElapsedTimeString)")
                                    .foregroundColor(project.timer.displayColor)
                                    .bold()
                                Image(systemName: project.timer.isRunning ? "timer.circle.fill" : "play.circle.fill")
                                    .background(UIColor.label.asColor.opacity(0.05))
                                    .foregroundColor(project.timer.displayColor)
                            }

                        }
                    }
                    .isHidden(project.isRecurrenceTemplate)

                }
                .foregroundColor(
                    UIColor.secondaryLabel.asColor
                )
                .font(.callout)
            }
        }
        .padding([.vertical])
    }
}

private extension FocusTimer {
    var shortDescription: String {
        switch self {
        case .standard:
            return "Standard"
        case .stopwatch:
            return "Stopwatch"
        }
    }
}

private extension FocusList {
    var shortDescription: String {
        switch self {
        case .standard:
            return "Standard"
        case .session:
            return "Session"
        case .singleTask:
            return "Single"
        case .none:
            return "None"
        }
    }
}
