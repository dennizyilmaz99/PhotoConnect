import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ImageItem: Identifiable {
    let id = UUID()  // Automatiskt genererat unikt ID
    let imageName: String
}


class UserProfileViewModel: ObservableObject {
    @Published var images: [ImageItem] = []
    @Published var userName: String = ""

    init() {
        fetchImages()
        fetchUserName()
    }
    
    func fetchUserName() {
            guard let uid = Auth.auth().currentUser?.uid else {
                userName = "Ingen inloggad"
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { document, error in
                if let document = document, document.exists {
                    self.userName = document.data()?["name"] as? String ?? "Anonym användare"
                } else {
                    self.userName = "Anonym användare"
                    print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }

    func fetchImages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let imageURLs = data?["images"] as? [String] {  // Kontrollerar om det finns en lista av URL:er
                    DispatchQueue.main.async {
                        self.images = imageURLs.map { ImageItem(imageName: $0) }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
