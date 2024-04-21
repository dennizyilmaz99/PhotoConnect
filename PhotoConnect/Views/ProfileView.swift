import SwiftUI
import FirebaseAuth

struct ImageItem: Identifiable {
    let id = UUID()  // Automatiskt genererat unikt ID
    let imageName: String
}

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showModal: Bool = false
    
    let images = [
           ImageItem(imageName: "photo"),
           ImageItem(imageName: "photo"),
           ImageItem(imageName: "photo"),
           ImageItem(imageName: "photo.fill"),
           ImageItem(imageName: "photo.fill"),
           ImageItem(imageName: "photo.fill"),
           ImageItem(imageName: "photo"),
           ImageItem(imageName: "photo"),
           ImageItem(imageName: "photo"),
           ImageItem(imageName: "photo.fill"),
           ImageItem(imageName: "photo.fill"),
           ImageItem(imageName: "photo.fill")
       ]

    var body: some View {
        
        VStack {
            HStack{
                Text(viewModel.userName).frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title).bold()
                    .padding()
                
                Button(action: {
                    print("Settings ikon klickad")
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
            VStack {
                Text("Dina bilder")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.padding()
            VStack {
                let columns = [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(images) { image in
                            Image(systemName: image.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 115, height: 115)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }.padding()
                }
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
               // Hantera vad som händer efter en lyckad utloggning, t.ex. navigera till inloggningsskärmen
               print("Användaren har loggat ut.")
               
           } catch {
               print("Ett fel uppstod vid utloggning: \(error.localizedDescription)")
           }
       }
}

#Preview {
    ProfileView()
}
