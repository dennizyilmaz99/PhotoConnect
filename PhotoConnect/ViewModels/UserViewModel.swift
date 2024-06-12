import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

struct ImageeItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let timestamp: Timestamp
    
    static func ==(lhs: ImageeItem, rhs: ImageeItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class UserViewModel: ObservableObject {
    @Published var images: [ImageeItem] = []
    @Published var userName: String = ""
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    
    private var userListener: ListenerRegistration?
    private var db = Firestore.firestore()
    private var userID: String
    
    init(userID: String) {
        self.userID = userID
        fetchUserProfile()
    }
    
    deinit {
        unsubscribe()
    }
    
    func fetchUserProfile() {
        fetchUserName()
        fetchImages()
        fetchFollowerCount()
        fetchFollowingCount()
    }
    
    private func fetchUserName() {
        userListener = db.collection("users").document(userID).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                self.userName = "Anonym användare"
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                self.userName = "Anonym användare"
                print("User document does not exist")
                return
            }
            
            if let data = document.data() {
                self.userName = data["name"] as? String ?? "Anonym användare"
            } else {
                self.userName = "Anonym användare"
                print("User document is empty")
            }
        }
    }
    
    private func fetchImages() {
        let userRef = db.collection("users").document(userID)
        
        userRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("User document does not exist")
                return
            }
            
            guard let imageData = document.data()?["images"] as? [[String: Any]] else {
                print("No image data found in user document")
                return
            }
            
            var newImages: [ImageeItem] = []
            
            for imageDataDict in imageData {
                if let imageName = imageDataDict["url"] as? String,
                   let timestamp = imageDataDict["timestamp"] as? Timestamp {
                    let newImage = ImageeItem(imageName: imageName, timestamp: timestamp)
                    newImages.append(newImage)
                } else {
                    print("Error parsing image data")
                }
            }
            
            newImages.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            
            DispatchQueue.main.async {
                self.images = newImages
            }
        }
    }
    
    private func fetchFollowerCount() {
        db.collection("users").document(userID).collection("followers").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            
            self.followersCount = snapshot?.documents.count ?? 0
        }
    }
    
    private func fetchFollowingCount() {
        db.collection("users").document(userID).collection("following").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching following: \(error.localizedDescription)")
                return
            }
            
            self.followingCount = snapshot?.documents.count ?? 0
        }
    }
    
    private func unsubscribe() {
        userListener?.remove()
    }
}
