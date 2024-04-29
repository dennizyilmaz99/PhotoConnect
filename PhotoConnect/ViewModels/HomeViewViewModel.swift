import SwiftUI
import FirebaseFirestore

struct UserImage: Identifiable {
    let id: String  // Använd UUID eller bildens unika identifierare
    let userName: String
    let imageURL: String
}


class HomeViewViewModel: ObservableObject {
    @Published var userImages: [UserImage] = []

    func fetchAllUserImages() {
        guard userImages.isEmpty else { return }  // Endast hämta om listan är tom

        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            var newImages: [UserImage] = []
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            for document in documents {
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
                self.userImages.append(contentsOf: newImages)
            }
        }
    }
}
