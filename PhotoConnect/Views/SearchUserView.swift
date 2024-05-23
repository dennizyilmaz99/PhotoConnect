import SwiftUI

struct SearchUserView: View {
    @StateObject private var viewModel = SearchUserViewModel()
    
    var body: some View {
        VStack {
            VStack {
                Text("Sök")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    
                    TextField("Sök", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(7)
                        .onChange(of: viewModel.searchText) { newValue in
                            viewModel.performSearch()
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            viewModel.searchResults.removeAll()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
            
            if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                Text("Det finns ingen som heter '\(viewModel.searchText)'")
                    .foregroundColor(.gray)
                    .padding()
            } else if !viewModel.searchResults.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.searchResults) { user in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.headline)
                                        .padding(.vertical, 5)
                                }
                                Spacer()
                                Button(action: {
                                    if viewModel.isFollowing(user) {
                                        viewModel.unfollowUser(user)
                                    } else {
                                        viewModel.followUser(user)
                                    }
                                }) {
                                    Text(viewModel.isFollowing(user) ? "Avfölj" : "Följ")
                                        .font(.subheadline)
                                        .padding(7)
                                        .frame(width: 70) // Fixed width for button
                                        .background(viewModel.isFollowing(user) ? Color.gray : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(7)
                                }
                            }
                            .padding(.horizontal)
                            Divider()
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    SearchUserView()
}
