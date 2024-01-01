//
//  FocusProjectCompletedView.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/10/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import SwiftUI

struct FocusProjectCompletedView: View {

    @Environment(\.colorScheme) var colorScheme
    let project: FocusProject
    let resumeProjectAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Summary")
                        .font(.title)
                        .bold()
                        .padding([.bottom], 12)
                }
                Spacer()
            }
            VStack(spacing: 30) {
                VStack {
                    Text(project.timer.totalElapsedTimeString)
                        .bold()
                    Text("Total Elapsed Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text(project.timer.totalWorkTimeString)
                        .bold()
                    Text("Total Work Time")
                        .font(.caption)
                        .foregroundColor(.secondary)

                }
                VStack {
                    Text(project.timer.totalBreakTimeString)
                        .bold()
                    Text("Total Break Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text(project.totalTasksCompleteString)
                        .bold()
                    Text("Tasks Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .isHidden(project.list.isSingleTask || project.list.isNone, remove: true)
            }
            .font(.title)
            .padding([.bottom], 12)

            HStack {
                Spacer()
                Button(
                    action: resumeProjectAction
                ) {
                    HStack {
                        Text("Resume")
                    }
                    .padding([.leading, .trailing], 24)
                    .contentShape(Rectangle())
                }
                .foregroundColor(.white)
                .bold()
                .frame(minHeight: 44)
                .background(UIColor.appOrange.asColor)
                .cornerRadius(10)
                Spacer()
            }
        }
        .padding()

        .cornerRadius(10)
        .padding(50)

    }
}

struct FocusProjectCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        FocusProjectCompletedView(
            project: .init(),
            resumeProjectAction: {}
        )
        .padding(40)
    }
}
