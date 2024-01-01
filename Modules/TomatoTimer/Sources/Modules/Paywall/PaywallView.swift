//
//  PaywallView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/18/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

enum PaywallReason: String, Equatable {
    case `default`
    case dailyProjectLimitReached
    case stopwatchTimer
    case standardList
    case sessionList
    case activity

    var description: String {
        switch self {
        case .dailyProjectLimitReached:
            return "Daily project limit reached"
        default:
            return "Plus Feature"
//
//        case .stopwatchTimer:
//            return "Use Stopwatch Timer"
//        case .standardList:
//            return "Use Standard List"
//        case .sessionList:
//            return "Use Session List"
//        case .activity:
//            return "See Activity"
        }
    }
}

struct PaywallView: View {

    let store: StoreOf<PaywallReducer>

    init(
        store: StoreOf<PaywallReducer>
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            TomatoTimerAsset.logo.swiftUIImage
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding([.bottom], 15)
                            TitleView(paywallReason: viewStore.paywallReason)
                            FeaturesListView()
//                            ForEach(products) { product in
//                                PurchaseOptionRow(product: product, isSelected: product == products[0])
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(
//                                                UIColor.appPomodoroRed.asColor,
//                                                lineWidth: product == products[0] ? 5 : 0
//                                            )
//                                    )
//                                    .padding([.leading, .trailing])
//                                    .padding([.bottom, .top], 10)
//                            }
                            //RatingsView()
                        }
                        .padding([.bottom], 200)
                    }
                    .scrollIndicators(.hidden)
                    .background(UIColor.systemGroupedBackground.asColor)

                    VStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Button(action: { viewStore.send(.purchaseButtonPressed) }) {
                                HStack {
                                    Spacer()
                                    Text("Upgrade for \(viewStore.product?.price ?? "")")
                                        .bold()
                                        .foregroundColor(.white)
                                        .font(.title3)
                                    Spacer()
                                }
                            }
                            .padding(17)
                            .frame(maxWidth: .infinity)
                            .background(UIColor.appPomodoroRed.asColor)
                            .cornerRadius(10)
                            .padding()
                            .contentShape(Rectangle())
                            .opacity(viewStore.isLoading ? 0.5 : 1)
                            .disabled(viewStore.isLoading)

                            Button(action: { viewStore.send(.restorePurchases) }) {
                                Text("Restore Purchases")
                                    .bold()
                            }
                            .opacity(viewStore.isLoading ? 0.5 : 1)
                            .disabled(viewStore.isLoading)
//                            HStack {
//                                Text("Terms of Use")
//                                    .onTapGesture {
//                                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
//                                            // Ask the system to open that URL.
//                                            UIApplication.shared.open(url)
//                                        }
//                                    }
//                                Divider()
//                                Text("Privacy Policy")
//                                    .onTapGesture {
//                                        if let url = URL(string: "https://www.termsfeed.com/live/5f2d0b09-8627-4a7e-aa5d-97aee8af9ab3") {
//                                            // Ask the system to open that URL.
//                                            UIApplication.shared.open(url)
//                                        }
//                                    }
//                            }
//                            .padding([.top])
//                            .font(.footnote)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .foregroundColor(UIColor.label.asColor)

                        .background(UIColor.secondarySystemGroupedBackground.asColor)
                        .background(UIColor.secondarySystemGroupedBackground.asColor.shadow(radius: 10).blur(radius: 10, opaque: false))
                        .shadow(radius: 10)

                    }
                }
                .alert(
                    store: self.store.scope(
                        state: \.$alert,
                        action: PaywallReducer.Action.alert
                    )
                )
                .onAppear {
                    viewStore.send(.viewDidAppear)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.dismiss) }) {
                            Image(systemSymbol: .xmark)
                        }
                        .foregroundColor(UIColor.label.asColor)
                    }
                }
            }

        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(
            store: Store(
                initialState: PaywallReducer.State(),
                reducer: PaywallReducer()
            )
        )
    }
}

struct GalleryView: View {
    var body: some View {
        TabView {
            Rectangle()
                .fill(.orange)
                .frame(height: 200)
                .cornerRadius(10)
                .padding()

            Rectangle()
                .fill(.green)
                .frame(height: 200)
                .cornerRadius(10)
                .padding()

            Rectangle()
                .fill(.blue)
                .frame(height: 200)
                .cornerRadius(10)
                .padding()
        }
        .tabViewStyle(.page)
        .frame(height: 290)
    }
}

struct TitleView: View {

    let paywallReason: PaywallReason

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(paywallReason.description)
                    .font(.caption)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(UIColor.appPomodoroRed.asColor)
                    .cornerRadius(10)
                    .isHidden(paywallReason != .dailyProjectLimitReached, remove: true)
                Group {
                    Text("Get") +
                    Text(" Tomato Timer+")
                        .foregroundColor(UIColor.appPomodoroRed.asColor)
                }
                Text("Unlock Tomato Timer's full set of features")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .bold(false)
            }
            .font(.largeTitle)
            .bold()
            Spacer()
        }.padding([.leading, .trailing])
    }
}

struct FeaturesListView: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(features) { feature in
                HStack {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(UIColor.appPomodoroRed.asColor)
                    Text(feature.title)
                    Spacer()
                }
                .bold()
            }
        }
        .padding()
    }
}

struct PurchaseOptionRow: View {
    let product: PurchasableProduct
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            CircularCheckbox(selected: isSelected, onToggle: { })
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(product.title)
                        .bold()
                    Spacer()
                    Text(product.price)
                        .bold()

                }
                Text(product.description)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(UIColor.secondarySystemGroupedBackground.asColor)
        .cornerRadius(10)
    }
}

struct RatingsView: View {

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                Image(systemSymbol: .laurelLeading)
                    .resizable()
                    .frame(width: 30, height: 50)
                    .foregroundColor(UIColor("#ff9502").asColor)
                VStack {
                    Text("4.6")
                        .font(.title2)
                        .bold()
                    Text("Average Rating")
                        .font(.body)
                        .bold()
                }
                Image(systemSymbol: .laurelTrailing)
                    .resizable()
                    .frame(width: 30, height: 50)
                    .foregroundColor(UIColor("#ff9502").asColor)
            }
            .padding([.bottom], 20)

            ForEach(ratings) { rating in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(rating.title)
                            .bold()
                            Spacer()
                        Text(rating.user)
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 0) {
                        Image(systemSymbol: .starFill)
                        Image(systemSymbol: .starFill)
                        Image(systemSymbol: .starFill)
                        Image(systemSymbol: .starFill)
                        Image(systemSymbol: .starFill)
                    }
                    .foregroundColor(UIColor("#ff9502").asColor)

                    Text(rating.comment)
                }
                .padding()
                .background(UIColor.secondarySystemFill.asColor)
                .cornerRadius(15)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
        }
        .padding([.top], 15)
    }
}

struct AdvertisedFeature: Equatable, Identifiable {
    let id = UUID()
    let title: String
}

struct PurchasableProduct: Equatable, Identifiable {
    let id = UUID()
    let price: String
    let title: String
    let description: String
}

let features: [AdvertisedFeature] = [
    .init(title: "Create unlimited projects and plan ahead with a schedule"),
    .init(title: "More ways to use the timer and list. Use Stopwatch Timer, Session Lists, and more"),
    .init(title: "Unlock all notification sounds"),
    .init(title: "Visualize activity in Activity tab and set goals"),
    .init(title: "Back up data to iCloud and sync between devices")
]

let products: [PurchasableProduct] = [
    .init(price: "$29.99 / once", title: "Lifetime", description: "No subscription, pay once."),
    .init(price: "$9.99 / year", title: "Annual", description: "Less than a dollar per month. Starts with a 7-day free trial."),
    .init(price: "$2.99 / month", title: "Monthly", description: "Try Tomato Timer+ for a month.")
]

private struct CircularCheckbox: View {
    var selected: Bool
    var onToggle: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(UIColor.appPomodoroRed.asColor, lineWidth: 2)
                .frame(width: 25, height: 25)
            Circle()
                .fill(UIColor.appPomodoroRed.asColor)
                .frame(width: 16, height: 16)
                .isHidden(selected == false)

        }
        .onTapGesture {
            onToggle()
            HapticFeedbackGenerator.impactOccurred(.light)
        }
    }
}

struct Rating: Equatable, Identifiable {
    let id = UUID()
    let user: String
    let title: String
    let comment: String
}

let ratings: [Rating] = [
    .init(user: "JWA-333", title: "Excellent and simple to use", comment: "Great to use when tackling a big/stressful project."),
    // swiftlint:disable:next line_length
    .init(user: "jtre", title: "Simple and Effective", comment: "I’ve been diagnosed with ADHD for awhile now and little tools like this have really helped me come a long way on setting specific goals throughout the day."),
    // swiftlint:disable:next line_length
    .init(user: "Catacata2021", title: "Amazing", comment: "Really great if you’re looking for something simple and straightforward. 10/10 my favorite pomodoro study method tracker/timer.")

]
