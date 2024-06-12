import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct UserView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: UserViewModel
    @State private var alertMessage = ""
    @State private var selectedImage: ImageeItem? = nil
    @State private var showFullScreenImage = false
    @State private var longPressingImage: ImageeItem? = nil
    
    var userID: String
    
    init(userID: String) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: UserViewModel(userID: userID))
    }
    
    var body: some View {
        VStack {
            VStack {
                let columns = [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]
                ScrollView {
                    HStack{
                        VStack {
                            Text("\(viewModel.userName)'s galleri")
                                .font(.headline).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                        HStack {
                            VStack {
                                Text("\(viewModel.images.count)").bold()
                                Text("inlägg").font(.system(size: 12))
                            }.padding(.trailing, 20)
                            
                            NavigationLink(destination: FollowerView(userID: userID)) {
                                VStack {
                                    Text("\(viewModel.followersCount)").bold()
                                    Text("följare").font(.system(size: 12))
                                }.padding(.trailing, 20)
                            }.foregroundColor(.primary)
                            
                            NavigationLink(destination: FollowingView(userID: userID)) {
                                VStack {
                                    Text("\(viewModel.followingCount)").bold()
                                    Text("följer").font(.system(size: 12))
                                }
                            }.foregroundColor(.primary)
                        }.padding(.trailing, 25)
                    }
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.images) { image in
                            WebImage(url: URL(string: image.imageName))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 115, height: 115)
                                .clipped()
                                .cornerRadius(10)
                                .opacity(longPressingImage == image ? 0.5 : 1.0)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedImage = image
                                    showFullScreenImage = true
                                    print("Selected image URL: \(image.imageName)")
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    selectedImage = image
                                } onPressingChanged: { isPressing in
                                    if isPressing {
                                        longPressingImage = image
                                    } else {
                                        longPressingImage = nil
                                    }
                                }
                        }
                    }.padding()
                }.refreshable {
                    await refreshContent()
                }
            }
            Spacer()
        }.navigationTitle(viewModel.userName).navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
            })
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let image = selectedImage {
                UserFullScreenImageView(imageUrl: image.imageName, isPresented: $showFullScreenImage)
            }
        }
    }
    
    private func refreshContent() async {
        viewModel.fetchUserProfile()
    }
}

struct UserFullScreenImageView: View {
    let imageUrl: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if let url = URL(string: imageUrl) {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .onTapGesture {
                        isPresented = false
                    }
                    .onAppear {
                        print("Loading image from URL: \(url)")
                    }
            } else {
                Text("Invalid URL")
                    .foregroundColor(.white)
                    .onAppear {
                        print("Invalid URL: \(imageUrl)")
                    }
            }
        }
    }
}

#Preview {
    UserView(userID: "exampleUserID")
}
