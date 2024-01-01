import SwiftUI
import ComposableArchitecture

struct SelectRecurrenceSectionView: View {

    // MARK: - Properties

    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<CreateFocusProjectReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                VStack {
                    HStack {
                        Toggle(
                            isOn: viewStore.binding(
                            get: \.repeats,
                            send: { .setRepeats($0) }
                            )) {
                                HStack {
                                    Text("Repeat")
                                    Spacer()
                                    Image(systemSymbol: .starCircleFill)
                                        .isHidden(viewStore.didPurchasePlus, remove: true)
                                }
                            }
                    }

                    VStack {
                        HStack {
                            ForEach(WeekDay.allCases) { day in
                                ZStack {
                                    Circle()
                                        .foregroundColor(
                                            UIColor.label.asColor
                                                .opacity(viewStore.repeatingDays.contains(day) ? 1 : 0.2)
                                        )
                                    Text("\(day.shortAbbreviation)")
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                }
                                .contentShape(Circle())
                                .frame(maxWidth: 60, maxHeight: 50)
                                .onTapGesture {
                                    viewStore.send(.toggleDayRecurrence(day))
                                }
                            }
                        }
                        .padding([.top, .bottom], 8)

                        VStack {
                            Divider()
                            Toggle(
                                "End Repeat",
                                isOn: viewStore.binding(
                                    get: \.endRepeat,
                                    send: { .setEndRepeat($0) }
                                ))

                            DatePicker(
                                "End Repeat Date",
                                selection: viewStore.binding(
                                    get: { $0.endRepeatDate ?? Date() },
                                    send: { .setEndRepeatDate($0) }
                                ),
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .padding([.top, .bottom], 8)
                            .isHidden(!viewStore.endRepeat, remove: true)

                        }
                    }
                    .isHidden(!viewStore.repeats, remove: true)
                }

//                VStack {
//                    Toggle(
//                        "Enable Reminders",
//                        isOn: viewStore.binding(
//                            get: \.remindersEnabled,
//                            send: { .setRemindersEnabled($0) }
//                        )
//                    )
//                    DatePicker(
//                        "Reminder Time",
//                        selection: viewStore.binding(
//                            get: { $0.reminderDate ?? Date() },
//                            send: { .setReminderTime($0) }
//                        ),
//                        displayedComponents: .hourAndMinute
//                    )
//                    .padding([.top, .bottom], 8)
//                    .isHidden(!viewStore.remindersEnabled, remove: true)
//                }
//                .isHidden(!viewStore.repeats, remove: true)
            } header: {
                Text("Recurrence")
            } footer: {
                // swiftlint:disable line_length
                if let recurrence = viewStore.recurrence {
                    let recurrenceString = recurrence.isEveryday ? recurrence.recurrenceString.lowercased() : recurrence.recurrenceString
                    let untilString = recurrence.endDate == nil ? "" : " until \(DateFormatter.monthDayYear(from: recurrence.endDate!))"
                    let reminderString = viewStore.remindersEnabled ? " and you'll be reminded at \(DateFormatter.hoursAndMinutes(from: viewStore.reminderDate!)) on each scheduled day." : "."
                    Text("This project will repeat \(recurrenceString)\(untilString)\(reminderString)")
                } else {
                    Text("This is a one off project.")
                }
                // swiftlint:enable line_length
            }

        }
    }
}

struct SelectRecurrenceSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SelectRecurrenceSectionView(
                store: Store(
                    initialState: CreateFocusProjectReducer.State(
                    ),
                    reducer: CreateFocusProjectReducer()
                )
            )
        }
    }
}
