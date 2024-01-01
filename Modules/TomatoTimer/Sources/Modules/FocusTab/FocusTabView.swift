import SwiftUI
import ComposableArchitecture
import SFSafeSymbols

struct FocusTabView: View {

    // MARK: - Properties

    @EnvironmentObject var weekStore: WeekStore
    @State var showDatePicker = false
    let store: StoreOf<FocusTabReducer>

    // MARK: Body

    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: { .path($0) })
        ) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                CalendarWeekTabView { day in

                    // MARK: - Main Scroll View

                    ScrollView {
                        LazyVStack(spacing: -20) {
                            ForEach(viewStore.projectsForDate(day)) { project in
                                FocusProjectRow(
                                    store: store,
                                    project: project,
                                    date: day
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.selectedProject(project))
                                }
                                .disabled(Calendar.current.isDateInFuture(day))
                            }
                        }
                    }

                    // MARK: - Presentation and Overlays

                    .overlay(self.EmptyState(
                        show: viewStore.showEmptyState(day),
                        action: { viewStore.send(.plusButtonPressed) }
                    ))
                    .alert(
                        store: self.store.scope(
                            state: \.$alert,
                            action: FocusTabReducer.Action.alert
                        )
                    )
                    .fullScreenCover(
                        store: self.store.scope(
                            state: \.$createTimer,
                            action: FocusTabReducer.Action.createTimer
                        ),
                        content: CreateFocusProjectView.init(store:)
                    )
                    .fullScreenCover(
                        store: self.store.scope(
                            state: \.$paywall,
                            action: FocusTabReducer.Action.paywall
                        ),
                        content: PaywallView.init(store:)
                    )
                    .fullScreenCover(
                        store: self.store.scope(
                            state: \.$newOnboarding,
                            action: FocusTabReducer.Action.newOnboarding
                        ),
                        content: NewFeaturesOnboardingView.init(store:)
                    )
                    .sheet(isPresented: $showDatePicker) {
                        DatePicker(
                            "Select Date",
                            selection: $weekStore.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .presentationDetents([.medium, .large])
                        .onChange(of: weekStore.selectedDate, perform: { _ in
                            showDatePicker = false
                        })
                        .presentationDetents([.medium])
                    }

                    // MARK: Callbacks

                    .onReceive(weekStore.$selectedDate) { _ in
                        viewStore.send(.loadDay(weekStore.selectedDate))
                    }
                    .onAppear {
                        viewStore.send(.viewDidAppear)
                        viewStore.send(.loadDay(day))
                    }
                    .onChange(of: viewStore.shouldSelectToday) {
                        if $0 {
                            weekStore.selectToday()
                        }
                    }
                }

                // MARK: - Toolbar and UI

                .background(UIColor.systemGroupedBackground.asColor)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text(weekStore.selectedDate.monthToString())
                                .font(.system(size: 24))
                                .fontWeight(.heavy)
                                .foregroundColor(.accentColor)
                            Text(weekStore.selectedDate.toString(format: "yyyy"))
                                .font(.system(size: 24))
                                .fontWeight(.semibold)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: -5) {
                            Button {
                                withAnimation {
                                    weekStore.selectToday()
                                }
                            } label: {
                                Text("Today")
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(4)
                                    .background(.secondary)
                                    .cornerRadius(4)
                            }

                            Button {
                                showDatePicker = true
                            } label: {
                                Image(systemName: "calendar")
                                    .font(.system(size: 24))
                            }

                            Button(action: { viewStore.send(.plusButtonPressed) }) {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }
                }
            }

            // MARK: - Transitions

        } destination: { state in
            switch state {
            case .timerHome:
                CaseLet(
                    state: /FocusTabReducer.Path.State.timerHome,
                    action: FocusTabReducer.Path.Action.timerHome,
                    then: FocusProjectView.init(store:)
                )
            }
        }

    }

    func EmptyState(
        show: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Group {
            if show {
                VStack(spacing: 30) {
                    TomatoTimerAsset.tomato.swiftUIImage
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 100)
                        .opacity(0.3)
                    Button(action: action) {
                        HStack {
                            Image(systemSymbol: .plusCircleFill)
                            Text("What are you working on?")
                        }
                        .padding()
                        .foregroundColor(UIColor.label.asColor)
                        .background(UIColor.secondarySystemGroupedBackground.asColor)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct FocusTabView_Previews: PreviewProvider {
    static var previews: some View {
        FocusTabView(
            store: Store(
                initialState: FocusTabReducer.State(),
                reducer: FocusTabReducer()
            )
        )
        .environmentObject(WeekStore())
    }
}

extension FocusTimer {
    var displayColor: Color {
        if isRunning {
            return currentSession.isBreak ? UIColor.appBlue.asColor : UIColor.appOrange.asColor
        } else {
            return UIColor.label.asColor
        }
    }
}

extension StandardTimer {
    var displayColor: Color {
        if isRunning {
            return currentSession.isBreak ? UIColor.appBlue.asColor : UIColor.appOrange.asColor
        } else {
            return UIColor.label.asColor
        }
    }
}

extension StopwatchTimer {
    var displayColor: Color {
        if isRunning {
            return currentSession.isBreak ? UIColor.appBlue.asColor : UIColor.appOrange.asColor
        } else {
            return UIColor.label.asColor
        }
    }
}
