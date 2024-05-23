import SwiftUI

struct FollowerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FollowViewModel()
    
    var body: some View {
        VStack {
            if viewModel.followers.isEmpty {
                Text("Du har inga följare ännu.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(viewModel.followers) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                                .padding(.vertical, 5)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.removeFollower(user)
                        }) {
                            Text("Ta bort")
                                .foregroundColor(.red)
                                .padding(5)
                                .background(Color(.systemGray5))
                                .cornerRadius(5)
                        }
                    }
                }
            }
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
