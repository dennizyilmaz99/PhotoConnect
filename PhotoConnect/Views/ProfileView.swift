import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showModal: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.userName).frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title).bold()
                    .padding()
                
                Button(action: {
                    alertMessage = "Är du säker att du vill logga ut?"
                    showAlert = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.blue).padding()
                }.alert(isPresented: $showAlert) {
                    Alert(title: Text("Bekräfta"),
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
                        }
                    }.padding()
                }
            }
            Spacer()
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

#Preview {
    ProfileView()
}
