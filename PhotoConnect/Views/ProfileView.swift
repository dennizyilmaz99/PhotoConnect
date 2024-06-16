import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @State private var showingActionSheet: Bool = false
    @State private var actionSheetType: ActionSheetType? = nil
    @State private var alertMessage = ""
    @State private var selectedImage: ImageItem? = nil
    @State private var showFullScreenImage = false
    @State private var longPressingImage: ImageItem? = nil
    
    var userID: String
    
    init(userID: String) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userID: userID))
    }
    
    enum ActionSheetType: Identifiable {
        case logOut
        case deleteImage
        
        var id: Int {
            hashValue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text(viewModel.userName).frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title).bold()
                        .padding(.horizontal)
                    
                    Button(action: {
                        actionSheetType = .logOut
                        showingActionSheet = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.blue).padding(.horizontal)
                    }
                }
                VStack {
                    let columns = [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ]
                    
                    ScrollView {
                        HStack {
                            VStack {
                                Text("Ditt galleri")
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
                                ZStack(alignment: .topTrailing) {
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
                                            actionSheetType = .deleteImage
                                            showingActionSheet = true
                                        } onPressingChanged: { isPressing in
                                            if isPressing {
                                                longPressingImage = image
                                            } else {
                                                longPressingImage = nil
                                            }
                                        }
                                    
                                    Button(action: {
                                        selectedImage = image
                                        actionSheetType = .deleteImage
                                        showingActionSheet = true
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(longPressingImage == image ? Color.black.opacity(0.3) : Color.black.opacity(0.9))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: -1, y: 6)
                                }
                            }
                        }.padding()
                    }.refreshable {
                        await refreshContent()
                    }
                }
                Spacer()
            }
            .actionSheet(isPresented: $showingActionSheet) {
                switch actionSheetType {
                case .logOut:
                    return ActionSheet(title: Text("Är du säker?"),
                                       message: Text("Är du säker att du vill logga ut?"),
                                       buttons: [
                                        .destructive(Text("Logga ut")) {
                                            logOut()
                                        },
                                        .cancel()
                                       ])
                case .deleteImage:
                    return ActionSheet(title: Text("Är du säker?"),
                                       message: Text("Är du säker på att du vill ta bort denna bild?"),
                                       buttons: [
                                        .destructive(Text("Ta bort")) {
                                            if let image = selectedImage {
                                                viewModel.deleteImage(image: image)
                                            }
                                        },
                                        .cancel()
                                       ])
                case .none:
                    return ActionSheet(title: Text("Error"), message: Text("Något gick fel."), buttons: [.cancel()])
                }
            }
            .fullScreenCover(isPresented: $showFullScreenImage) {
                if let image = selectedImage {
                    FullScreenImageView(imageUrl: image.imageName, isPresented: $showFullScreenImage)
                }
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            print("Användaren har loggat ut.")
        } catch {
            print("Ett fel uppstod vid utloggning: \(error.localizedDescription)")
        }
    }
    
    private func refreshContent() async {
        viewModel.fetchUserProfile()
    }
}

struct FullScreenImageView: View {
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
    ProfileView(userID: "exampleUserID")
}
