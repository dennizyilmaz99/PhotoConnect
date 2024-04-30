import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showModal: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text(viewModel.userName).frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title).bold()
                    .padding()
                
                Button(action: {
                    print("Settings icon clicked")
                    showModal = true
                }) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.blue).padding()
                }
            }.sheet(isPresented: $showModal) {
                ModalView()
            }
            
            VStack {
                Text("Dina bilder")
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
                        }
                    }.padding()
                }
            }
            Spacer()
        }
    }
}

private struct ModalView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title3).bold()
                .padding()
            Spacer()
            Button(action: logOut) {
                Text("Logga ut")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
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

// Preview
#Preview {
    ProfileView()
}
