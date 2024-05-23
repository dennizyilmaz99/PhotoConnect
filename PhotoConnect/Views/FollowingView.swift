import SwiftUI

struct FollowingView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FollowViewModel()
    
    var body: some View {
        VStack {
            if viewModel.following.isEmpty {
                Text("Du följer ingen ännu.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(viewModel.following) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                                .padding(.vertical, 5)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.unfollowUser(user)
                        }) {
                            Text("Avfölj")
                                .font(.system(size: 14)).bold()
                                .foregroundColor(.black)
                                .padding(7)
                                .frame(width: 70) // Fixed width for button
                                .background(Color(.systemGray5))
                                .cornerRadius(7)
                                
                        }
                    }
                }
            }
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
