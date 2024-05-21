import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showLogOutAlert = false
    @State private var showDeletePicAlert = false
    @State private var alertMessage = ""
    @State private var selectedImage: ImageItem? = nil
    @State private var showFullScreenImage = false

    var body: some View {
        VStack {
            HStack {
                Text(viewModel.userName).frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title).bold()
                    .padding()
                
                Button(action: {
                    alertMessage = "Är du säker att du vill logga ut?"
                    showLogOutAlert = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.blue).padding()
                }.alert(isPresented: $showLogOutAlert) {
                    Alert(title: Text("Är du säker?"),
                          message: Text(alertMessage),
                          primaryButton: .destructive(Text("Logga ut")) {
                        logOut()
                    },
                          secondaryButton: .cancel())
                }
            }
            VStack {
                Text("Ditt galleri")
                    .font(.headline).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                let columns = [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.images) { image in
                            WebImage(url: URL(string: image.imageName))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 115, height: 115)
                                .clipped()
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedImage = image
                                    showFullScreenImage = true
                                    print("Selected image URL: \(image.imageName)")
                                }
                                .onLongPressGesture {
                                    selectedImage = image
                                    alertMessage = "Är du säker på att du vill ta bort denna bild?"
                                    showDeletePicAlert = true
                                }
                        }
                    }.padding()
                }
            }
            Spacer()
        }
        .alert(isPresented: $showDeletePicAlert) {
            Alert(title: Text("Är du säker?"),
                  message: Text(alertMessage),
                  primaryButton: .destructive(Text("Ta bort")) {
                if let image = selectedImage {
                    viewModel.deleteImage(image: image)
                }
            },
                  secondaryButton: .cancel())
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let image = selectedImage {
                FullScreenImageView(imageUrl: image.imageName, isPresented: $showFullScreenImage)
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
    ProfileView()
}
