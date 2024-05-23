import SwiftUI
import FirebaseFirestore

struct UserImage: Identifiable {
    let id: String
    let userName: String
    let imageURL: String
    let timestamp: Timestamp
}

class HomeViewViewModel: ObservableObject {
    @Published var userImages: [UserImage] = []
    private var listener: ListenerRegistration?
    
    deinit {
        unsubscribe()
    }
    
    func fetchAllUserImages() {
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
                
                if let imagesData = data["images"] as? [[String: Any]] {
                    for imageData in imagesData {
                        if let imageURL = imageData["url"] as? String,
                           let timestamp = imageData["timestamp"] as? Timestamp {
                            let newImage = UserImage(id: UUID().uuidString, userName: userName, imageURL: imageURL, timestamp: timestamp)
                            newImages.append(newImage)
                        }
                    }
                }
            }
            
            newImages.sort(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
            
            DispatchQueue.main.async {
                self.userImages = newImages
            }
        }
    }
    
    private func unsubscribe() {
        listener?.remove()
    }
}
