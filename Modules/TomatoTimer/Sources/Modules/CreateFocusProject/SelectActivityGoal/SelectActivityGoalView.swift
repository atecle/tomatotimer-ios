import SwiftUI
import ComposableArchitecture

struct SelectActivityGoalView: View {

    // MARK: - Properties

    let store: StoreOf<SelectActivityGoalReducer>

    // MARK: Body

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.activityGoals) { goal in
                    HStack {
                        CircularCheckbox(
                            selected: viewStore.project.activityGoals.contains(where: { $0.id == goal.id }),
                            onToggle: {
                                viewStore.send(.selectActivityGoal(goal))
                            }
                        )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(goal.title)")
                                .bold()
                            Text("\(DateComponentsFormatter.abbreviated(goal.goalSeconds)) \(goal.goalIntervalType.description)")
                                .font(.caption)
                                .foregroundColor(UIColor.secondaryLabel.asColor)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.selectActivityGoal(goal))
                    }
                    .padding(4)
                }
            }
            .navigationTitle("Select Activity Goals")
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$create,
                    action: SelectActivityGoalReducer.Action.create
                ),
                content: CreateActivityGoalView.init(store:)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewStore.send(.plusButtonPressed) }) {
                        Image(systemSymbol: .plusCircle)
                    }
                }
            }
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
        }
    }
}

struct SelectActivityGoalView_Previews: PreviewProvider {
    static var previews: some View {
        SelectActivityGoalView(
            store: Store(
                initialState: SelectActivityGoalReducer.State(
                    project: .init(),
                    activityGoals: [.init()]
                ),
                reducer: SelectActivityGoalReducer()
            )
        )
    }
}

private struct CircularCheckbox: View {
    var selected: Bool
    var onToggle: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.blue, lineWidth: 2)
                .frame(width: 25, height: 25)
            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
                .isHidden(selected == false)

        }
        .onTapGesture {
            onToggle()
            HapticFeedbackGenerator.impactOccurred(.light)
        }
    }
}
