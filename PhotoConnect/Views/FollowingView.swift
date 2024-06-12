import SwiftUI

struct FollowingView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: FollowViewModel
    
    var userID: String
    
    init(userID: String) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: FollowViewModel(userID: userID))
    }
    
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
                            if user.isFollowing {
                                viewModel.unfollowUser(user)
                            } else {
                                viewModel.followUser(user)
                            }
                        }) {
                            Text(user.isFollowing ? "Avfölj" : "Följ")
                                .font(.system(size: 14)).bold()
                                .foregroundColor(user.isFollowing ? Color(.black) : Color(.white))
                                .padding(7)
                                .frame(width: 70)
                                .background(user.isFollowing ? Color(.systemGray5) : Color(.systemBlue))
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
    FollowingView(userID: "exampleUserID")
}
