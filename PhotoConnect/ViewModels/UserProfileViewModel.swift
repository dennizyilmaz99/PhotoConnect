import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

struct ImageItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let timestamp: Timestamp
    
    static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class UserProfileViewModel: ObservableObject {
    @Published var images: [ImageItem] = []
    @Published var userName: String = ""
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    
    private var userListener: ListenerRegistration?
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    
    init() {
        fetchUserName()
        fetchImages()
        fetchFollowerCount()
        fetchFollowingCount()
    }
    
    deinit {
        unsubscribe()
    }
    
    func fetchUserName() {
        guard let uid = auth.currentUser?.uid else {
            userName = "Ingen inloggad"
            return
        }
        
        userListener = db.collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
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
    
    func fetchImages() {
        guard let uid = auth.currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(uid)
        
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
            
            var newImages: [ImageItem] = []
            
            for imageDataDict in imageData {
                if let imageName = imageDataDict["url"] as? String,
                   let timestamp = imageDataDict["timestamp"] as? Timestamp {
                    let newImage = ImageItem(imageName: imageName, timestamp: timestamp)
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
    
    func fetchFollowerCount() {
        guard let uid = auth.currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("followers").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            
            self.followersCount = snapshot?.documents.count ?? 0
        }
    }
    
    func fetchFollowingCount() {
        guard let uid = auth.currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("following").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching following: \(error.localizedDescription)")
                return
            }
            
            self.followingCount = snapshot?.documents.count ?? 0
        }
    }
    
    func deleteImage(image: ImageItem) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let storageRef = Storage.storage().reference(forURL: image.imageName)
        
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from storage: \(error.localizedDescription)")
                return
            }
            
            self.db.collection("users").document(uid).updateData([
                "images": FieldValue.arrayRemove([["url": image.imageName, "timestamp": image.timestamp]])
            ]) { error in
                if let error = error {
                    print("Error deleting image from Firestore: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.images.removeAll { $0.id == image.id }
                }
            }
        }
    }
    
    private func unsubscribe() {
        userListener?.remove()
    }
}
