import SwiftUI

struct FollowerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: FollowViewModel
    
    var userID: String
    
    init(userID: String) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: FollowViewModel(userID: userID))
    }
    
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
                        if user.id == viewModel.currentUserID {
                            Button(action: {
                                viewModel.removeFollower(user)
                            }) {
                                Text("Ta bort")
                                    .font(.system(size: 14)).bold()
                                    .foregroundColor(.black)
                                    .padding(7)
                                    .frame(width: 70)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(7)
                            }
                        } else {
                            Button(action: {
                                if user.isFollowing {
                                    viewModel.unfollowUser(user)
                                } else {
                                    viewModel.followUser(user)
                                }
                            }) {
                                Text(user.isFollowing ? "Avfölj" : "Följ")
                                    .font(.system(size: 14)).bold()
                                    .foregroundColor(.black)
                                    .padding(7)
                                    .frame(width: 70)
                                    .background(user.isFollowing ? Color(.systemGray5) : Color(.systemBlue))
                                    .cornerRadius(7)
                            }
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
    FollowerView(userID: "exampleUserID")
}
