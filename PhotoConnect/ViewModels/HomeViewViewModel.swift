import SwiftUI
import FirebaseFirestore

struct UserImage: Identifiable {
    let id: String  // Använd UUID eller bildens unika identifierare
    let userName: String
    let imageURL: String
}


class HomeViewViewModel: ObservableObject {
    @Published var userImages: [UserImage] = []
    private var listener: ListenerRegistration?

    deinit {
        unsubscribe()
    }

    func fetchAllUserImages() {
        guard userImages.isEmpty else { return }  // Endast hämta om listan är tom

        let db = Firestore.firestore()
        listener = db.collection("users").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("No documents found")
                return
            }

            var newImages: [UserImage] = []

            for document in snapshot.documents {
                let data = document.data()
                let userName = data["name"] as? String ?? "Unknown User"
                
                if let images = data["images"] as? [String] {
                    for imageURL in images {
                        let newImage = UserImage(id: UUID().uuidString, userName: userName, imageURL: imageURL)
                        newImages.append(newImage)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.userImages = newImages
            }
        }
    }

    private func unsubscribe() {
        listener?.remove()
    }
}
