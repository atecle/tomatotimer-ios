import SwiftUI

struct PlannerListRow: View {

    // MARK: - Properties

    var focus: FocusState<PlannerHomeReducer.PlannerListItem?>.Binding
    @Binding var task: PlannerHomeReducer.PlannerListItem
    let onEditingChanged: (Bool) -> Void
    let onSubmit: () -> Void

    var body: some View {
        HStack {
            CircularCheckbox(task: $task)
                .animation(nil, value: UUID())
            TextField(
                "Add Task",
                text: $task.title,
                onEditingChanged: { isEditing in
                    onEditingChanged(isEditing)
                }
            )
            .lineLimit(5, reservesSpace: true)
            .onSubmit(onSubmit)
            .focused(focus, equals: task)
            .foregroundColor(.primary.opacity(task.completed ? 0.5 : 1))
            Spacer()
            Image(systemName: "timer.circle.fill")
                .frame(width: 25, height: 25)
                .isHidden(!task.inProgress)

        }
    }
}

private struct CircularCheckbox: View {
    @Binding var task: PlannerHomeReducer.PlannerListItem

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.blue, lineWidth: 2)
                .frame(width: 25, height: 25)
            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
                .isHidden(task.completed == false)

        }.onTapGesture {
            task.completed.toggle()
            HapticFeedbackGenerator.impactOccurred(.light)
        }
    }
}

struct PlannerListRow_Previews: PreviewProvider {

    @FocusState static var focus: PlannerHomeReducer.PlannerListItem?
    static var previews: some View {
        List {
            ForEach(
                [
                    (UUID(), "write reducer tests", true, false),
                    (UUID(), "update README", false, true),
                    (UUID(), "refactor main view", false, true)
                ]
                    .map { PlannerHomeReducer.PlannerListItem.task(.init(id: $0.0, title: $0.1, completed: $0.2, inProgress: $0.3)) }
            ) { task in
                PlannerListRow(
                    focus: $focus,
                    task: .constant(task),
                    onEditingChanged: { _ in },
                    onSubmit: { }
                )
            }
        }
    }
}
