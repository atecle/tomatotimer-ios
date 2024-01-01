//
//  WeeklyActivityTotalsView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/17/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import Charts

struct WeeklyActivityTotalsView: View {

    let data: WeeklyActivityTotals
    let showSectionHeader: Bool

    init(data: WeeklyActivityTotals, showSectionHeader: Bool = true) {
        self.data = data
        self.showSectionHeader = showSectionHeader
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("WEEKLY")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemSymbol: .clockFill)
                Spacer()
                HStack {
                    Text("See more")
                    Image(systemSymbol: .chevronRight)
                }
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding([.leading, .trailing])
            .isHidden(!showSectionHeader, remove: true)
            VStack {
                HStack {
                    HStack {
                        Text("Total")
                            .bold()
                            .foregroundColor(.secondary)
                        Text("\(DateComponentsFormatter.abbreviated(TimeInterval(Array(data.totals.values).reduce(0, +))))")
                            .bold()
                    }
                    .foregroundColor(UIColor.label.asColor)
                    Spacer()
                    HStack(spacing: 4) {
                        if data.deltaFromLastWeek.isNaN || !data.deltaFromLastWeek.isFinite {

                        } else if data.deltaFromLastWeek > 0 {
                            Group {
                                Image(systemSymbol: .arrowUpCircleFill)
                                Text("+\(NumberFormatter.percent(data.deltaFromLastWeek)) from last week")
                                    .font(.caption)
                                    .bold()
                            }
                            .foregroundColor(.accentColor)
                        } else if data.deltaFromLastWeek < 0 {
                            Group {
                                Image(systemSymbol: .arrowDownCircleFill)
                                Text("\(NumberFormatter.percent(data.deltaFromLastWeek)) from last week")
                                    .font(.caption)
                                    .bold()
                            }
                            .foregroundColor(.red)
                        } else {
                            Group {
                                Image(systemSymbol: .minusCircleFill)
                                Text("No change from last week")
                                    .font(.caption)
                                    .bold()
                            }
                            .foregroundColor(.gray)
                        }

                    }
                }

                Chart {
                    ForEach(WeekDay.allCases) { day in
                        BarMark(
                            x: .value(day.shortAbbreviation, day.abbreviation),
                            y: .value("Elapsed", (data.totals[day] ?? 0) / 60)
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { value in
                        if let val = value.as(Int.self) {
                            AxisValueLabel("\(val)m")
                        }

                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: (data.thisWeekTotals / 60) + (2))))
                .chartXAxis {
                    AxisMarks(position: .top)
                }

            }
            .foregroundStyle(Color.accentColor)
            .padding()
            .background(UIColor.secondarySystemGroupedBackground.asColor)
            .cornerRadius(10)
            .padding(showSectionHeader ? 16 : 0)

        }

    }
}

struct WeeklyActivityTotalsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack {
                WeeklyActivityTotalsView(
                    data: .dummy
                )
            }
        }
        .background(UIColor.systemGroupedBackground.asColor)
    }
}

extension WeeklyActivityTotals {
    static var dummy: WeeklyActivityTotals = .init(
        totals: [
            .sunday: 60 * 30,
            .monday: 60 * 20,
            .tuesday: 60 * 45,
            .wednesday: 60 * 93,
            .thursday: 60 * 0,
            .friday: 60 * 10,
            .saturday: 60 * 25
        ],
        lastWeekTotals: (60 * 30) + (60 * 20) + (60 * 45) + (60 * 93) + (60 * 0) + (60 * 10) + (60 * 25)
    )

    static var dummy1: WeeklyActivityTotals = .init(
        totals: [
            .sunday: 60 * 30,
            .monday: 60 * 20,
            .tuesday: 60 * 45,
            .wednesday: 60 * 93,
            .thursday: 60 * 0,
            .friday: 60 * 10,
            .saturday: 60 * 25
        ],
        lastWeekTotals: 60 * 93
    )
}
