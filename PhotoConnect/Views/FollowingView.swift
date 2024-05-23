import SwiftUI

struct FollowingView: View {
    @Environment(\.presentationMode) var presentationMode

        var body: some View {
            VStack {
                Text("Jalla da")
            }
            .navigationBarTitle("Följer", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
            })
        }
}

#Preview {
    FollowingView()
}
