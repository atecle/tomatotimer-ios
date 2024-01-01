import SwiftUI

struct UnlockPlusSectionView: View {
    var body: some View {
        Section {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Unlock all features")
                    Text("Tomato Timer+")
                        .font(.title3)
                        .bold()
                }
                Spacer()
                Image(systemSymbol: .starCircleFill)

            }
            .contentShape(Rectangle())
            .foregroundColor(.white)
            .listRowBackground(
                UIColor.appPomodoroRed.asColor
                    .shadow(radius: 5)
            )
        }

    }
}

struct UnlockPlusSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            UnlockPlusSectionView()
        }
    }
}
