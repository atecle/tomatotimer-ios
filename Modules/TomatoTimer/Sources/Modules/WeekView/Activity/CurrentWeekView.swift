//
//  WeekView.swift
//  InfiniteWeekView
//
//  Created by Philipp Knoblauch on 13.05.23.
//

import SwiftUI

struct CurrentWeekView: View {
    @EnvironmentObject var weekStore: WeekStore

    var week: Week
    @State var showDatePicker: Bool = false

    var body: some View {
        HStack {
            Button(action: {
                weekStore.update(to: .past)
            }) {
                Image(systemSymbol: .chevronLeft)
            }
            Spacer()
            if Calendar.current.isDateInToday(week.referenceDate) {
                Button(action: { showDatePicker = true }) {
                    Text("Current Week")
                }

            } else {
                Button(action: { showDatePicker = true }) {
                    Group {
                        Text("\(DateFormatter.monthDayYear(from: week.referenceDate.startOfWeek))")
                        + Text(" - ")
                        + Text("\(DateFormatter.monthDayYear(from: week.referenceDate.endOfWeek))")
                    }
                }
            }
            Spacer()
            Button(action: {
                weekStore.update(to: .future)
            }) {
                Image(systemSymbol: .chevronRight)
            }
            .disabled(Calendar.current.isDateInToday(week.referenceDate))
            .opacity(Calendar.current.isDateInToday(week.referenceDate) ? 0.5 : 1)
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Select Date", selection: $weekStore.selectedDate)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .cornerRadius(15)
                    .padding()
                    .presentationDetents([.medium, .large])
                    .onChange(of: weekStore.selectedDate, perform: { _ in
                        showDatePicker = false
                    })
            }
        }
        .bold()
        .foregroundColor(.secondary)
    }
}

struct CurrentWeekView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWeekView(week: .init(index: 1, dates:
                                [
                                    Date().yesterday.yesterday.yesterday,
                                    Date().yesterday.yesterday,
                                    Date().yesterday,
                                    Date(),
                                    Date().tomorrow,
                                    Date().tomorrow.tomorrow,
                                    Date().tomorrow.tomorrow.tomorrow
                                ],
                             referenceDate: Date()))
        .environmentObject(WeekStore())
    }
}
