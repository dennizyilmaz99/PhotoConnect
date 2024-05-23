import SwiftUI

struct FollowerView: View {
    @Environment(\.presentationMode) var presentationMode

        var body: some View {
            VStack {
                Text("dfdfdfdf")
            }
            .navigationBarTitle("Följare", displayMode: .inline)
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
    FollowerView()
}
