import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserImage: Identifiable {
    let id: String
    let userName: String
    let imageURL: String
    let timestamp: Timestamp
}

class HomeViewViewModel: ObservableObject {
    @Published var userImages: [UserImage] = []
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    
    func fetchFollowersPicture() {
        guard let currentUserID = auth.currentUser?.uid else {
            print("Error: Current user ID is nil")
            return
        }
        
        print("Current User ID: \(currentUserID)")
        
        db.collection("users").document(currentUserID).collection("following").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching followed users: \(error.localizedDescription)")
                return
            }
            
            var userIDs = [currentUserID]
            if let documents = snapshot?.documents {
                userIDs.append(contentsOf: documents.map { $0.documentID })
            }
            
            print("Fetched followed user IDs: \(userIDs)")
            
            if !userIDs.isEmpty {
                self?.fetchImages(for: userIDs)
            } else {
                print("User is not following anyone")
                self?.userImages = []
            }
        }
    }
    
    private func fetchImages(for userIDs: [String]) {
        let dispatchGroup = DispatchGroup()
        var allImages: [UserImage] = []
        
        for userID in userIDs {
            dispatchGroup.enter()
            db.collection("users").document(userID).getDocument { [weak self] documentSnapshot, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Error fetching user document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot, let data = document.data(), let userName = data["name"] as? String else {
                    print("User document is missing required data")
                    return
                }
                
                if let images = data["images"] as? [[String: Any]] {
                    let userImages = images.compactMap { imageDict -> UserImage? in
                        guard let imageURL = imageDict["url"] as? String,
                              let timestamp = imageDict["timestamp"] as? Timestamp else {
                            return nil
                        }
                        return UserImage(id: UUID().uuidString, userName: userName, imageURL: imageURL, timestamp: timestamp)
                    }
                    allImages.append(contentsOf: userImages)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.userImages = allImages.sorted(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            print("Final userImages count: \(self.userImages.count)")
        }
    }
}
