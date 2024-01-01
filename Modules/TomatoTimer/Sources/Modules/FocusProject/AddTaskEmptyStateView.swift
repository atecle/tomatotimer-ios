import SwiftUI

struct AddTaskEmptyStateView: View {

    // MARK: - Properties

    @Environment(\.colorScheme) var colorScheme
    @State var isPressedDown = false
    var scale: Double { isPressedDown ? 0.98 : 1 }
    private var onTap: () -> Void

    init(
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap
    }

    // MARK: Body

    var body: some View {
        HStack {
            Image(systemName: "plus")
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .bold()
            Text("Add a task to get started")
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .bold()
        }
        .contentShape(Rectangle())
        .frame(height: 50)
        .padding()
        .background(UIColor.label.asColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .scaleEffect(scale)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressedDown = true
                }
                .onEnded { _ in
                    isPressedDown = false
                    onTap()
                }
        )
        .animation(
            .linear(
                duration: 0.065
            ),
            value: scale
        )
    }
}

struct AddTaskEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskEmptyStateView(
            onTap: {}
        )
    }
}
