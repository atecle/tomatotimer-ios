import Foundation
import SwiftUI
import ComposableArchitecture

struct FocusProjectRow: View {

    let store: StoreOf<FocusTabReducer>
    let project: FocusProject
    let date: Date

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                        Spacer()
                        HStack {
                            Text("\(project.recurrenceString)")
                                .isHidden(project.recurrenceString.isEmpty, remove: true)
                            Text("\(Image(systemSymbol: .clockFill)) \(project.timer.shortDescription)")
                            Text("\(Image(systemSymbol: .checklist)) \(project.list.shortDescription)")
                        }
                        .foregroundColor(UIColor.secondaryLabel.asColor)
                        .font(.caption)
                    }

                    Spacer()
                    Button(action: { viewStore.send(.menuButtonPressed(project)) }) {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundColor(UIColor.label.asColor)
                    }
                    .id(project.id)
                    .confirmationDialog(
                        store: self.store.scope(
                            state: \.$confirmationDialog,
                            action: FocusTabReducer.Action.confirmationDialog
                        )
                    )
                }

                Divider()
                    .padding([.top, .bottom], 6)

                HStack {
                    if Calendar.current.isDateInFuture(self.date) || project.isRecurrenceTemplate {
                        HStack {
                            Image(systemSymbol: .calendar)
                            Text("Scheduled")
                                .bold()
                        }
                        .foregroundColor(
                            UIColor.secondaryLabel.asColor
                        )
                    } else {
                        Button(action: { viewStore.send(.toggleCompleted(project)) }) {
                            HStack(spacing: 6) {
                                Image(systemSymbol: .checkmarkCircleFill)
                                Text("\(project.timer.isComplete ? "Done" : "Complete")")
                                    .bold()
                            }
                            .foregroundColor(
                                project.timer.isComplete
                                ? UIColor.appGreen.asColor
                                : UIColor.secondaryLabel.asColor
                            )
                        }
                    }

                    Spacer()
                    Group {
                        if project.timer.wasStarted {
                            if project.timer.currentSession.isBreak {
                                Text("Break")
                                    .bold()
                                    .foregroundColor(project.timer.displayColor)
                                Image(systemName: "timer.circle.fill")
                                    .background(UIColor.label.asColor.opacity(0.05))
                                    .foregroundColor(project.timer.displayColor)
                            } else {
                                Text("\(project.timer.totalWorkTimeString)")
                                    .foregroundColor(project.timer.displayColor)
                                    .bold()
                                Image(systemName: project.timer.isRunning ? "timer.circle.fill" : "play.circle.fill")
                                    .background(UIColor.label.asColor.opacity(0.05))
                                    .foregroundColor(project.timer.displayColor)
                            }

                        } else {
                            Text("Start")
                                .bold()
                            Image(systemSymbol: .arrowForwardCircleFill)
                                .background(UIColor.label.asColor.opacity(0.05))
                            .clipShape(Circle())
                        }
                    }
                    .isHidden(project.isRecurrenceTemplate)

                }
                .foregroundColor(
                    UIColor.secondaryLabel.asColor
                )
                .font(.callout)

            }
            .padding()
            .background(UIColor.secondarySystemGroupedBackground.asColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        project.timer.displayColor,
                        lineWidth: project.isActive ? 5 : 0
                    )
            )
            .cornerRadius(10)
            .padding()
            .opacity((project.timer.isComplete || Calendar.current.isDateInFuture(self.date)) ? 0.4 : 1)
        }
    }
}

struct FocusProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack {
                FocusProjectRow(
                    store: Store(initialState: FocusTabReducer.State(), reducer: FocusTabReducer()),
                    project: .standardTimerNoListPreview,
                    date: .now
                )
                FocusProjectRow(
                    store: Store(initialState: FocusTabReducer.State(), reducer: FocusTabReducer()),
                    project: .standardTimerNoListPreview,
                    date: .now
                )
            }
        }.background(UIColor.systemGroupedBackground.asColor)
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
