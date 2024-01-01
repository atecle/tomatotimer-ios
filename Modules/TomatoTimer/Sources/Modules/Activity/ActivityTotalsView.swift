import SwiftUI
import ComposableArchitecture
import SFSafeSymbols

struct ActivityTotalsView: View {

    let totals: ActivityTotals

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("LIFETIME")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemSymbol: .clockFill)
                Spacer()
            }
            .padding([.leading])
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Total")
                            .foregroundColor(.secondary)
                        Text("\(DateComponentsFormatter.abbreviated(TimeInterval(totals.workSecondsElapsed + totals.breakSecondsElapsed)))")
                    }
                    .font(.title2)
                    .bold()
                    Spacer()
                }

                HStack {
                    VStack {
                        Text("\(totals.numberOfProjects)")
                        Text("Projects")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    VStack {
                        Text("\(DateComponentsFormatter.abbreviated(TimeInterval(totals.workSecondsElapsed)))")
                        Text("Work")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    VStack {
                        Text("\(DateComponentsFormatter.abbreviated(TimeInterval(totals.breakSecondsElapsed)))")
                        Text("Break")
                            .foregroundColor(.secondary)
                    }
                }
                .bold()
                .font(.subheadline)
                .padding()
            }
            .padding()
            .background(UIColor.secondarySystemGroupedBackground.asColor)
            .cornerRadius(10)
            .padding()
        }
    }
}

struct ActivityUpgradeOverlayView: View {

    let text: String

    var body: some View {
        HStack {
            Text(text)
                .bold()
            Image(systemSymbol: .starCircleFill)
        }
        .foregroundColor(UIColor.label.asColor)
    }
}
struct ActivityTotalsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack {
                ActivityTotalsView(
                    totals: .init(
                        numberOfProjects: 10,
                        workSecondsElapsed: 60 * 93,
                        breakSecondsElapsed: 60 * 43
                    )
                )
            }
        }
        .background(UIColor.systemGroupedBackground.asColor)
    }
}
