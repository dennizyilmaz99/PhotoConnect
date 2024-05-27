import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FollowUser: Identifiable {
    let id: String
    let name: String
}

class FollowViewModel: ObservableObject {
    @Published var followers: [FollowUser] = []
    @Published var following: [FollowUser] = []
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    
    init() {
        fetchFollowers()
        fetchFollowing()
    }
    
    func fetchFollowers() {
        guard let currentUserID = auth.currentUser?.uid else { return }
        
        db.collection("users").document(currentUserID).collection("followers").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No followers found")
                return
            }
            
            var followers: [FollowUser] = []
            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                let id = document.documentID
                self?.db.collection("users").document(id).getDocument { userSnapshot, error in
                    if let error = error {
                        print("Error fetching user data: \(error.localizedDescription)")
                        group.leave()
                        return
                    }
                    
                    let name = userSnapshot?.data()?["name"] as? String ?? "Unknown"
                    followers.append(FollowUser(id: id, name: name))
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self?.followers = followers
            }
        }
    }
    
    func fetchFollowing() {
        guard let currentUserID = auth.currentUser?.uid else { return }
        
        db.collection("users").document(currentUserID).collection("following").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching following: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No following found")
                return
            }
            
            var following: [FollowUser] = []
            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                let id = document.documentID
                self?.db.collection("users").document(id).getDocument { userSnapshot, error in
                    if let error = error {
                        print("Error fetching user data: \(error.localizedDescription)")
                        group.leave()
                        return
                    }
                    
                    let name = userSnapshot?.data()?["name"] as? String ?? "Unknown"
                    following.append(FollowUser(id: id, name: name))
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self?.following = following
            }
        }
    }
    
    func unfollowUser(_ user: FollowUser) {
        guard let currentUserID = auth.currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let followingRef = db.collection("users").document(currentUserID).collection("following").document(user.id)
        batch.deleteDocument(followingRef)
        
        let followerRef = db.collection("users").document(user.id).collection("followers").document(currentUserID)
        batch.deleteDocument(followerRef)
        
        batch.commit { [weak self] error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                self?.following.removeAll { $0.id == user.id }
            }
        }
    }
    
    func removeFollower(_ user: FollowUser) {
        guard let currentUserID = auth.currentUser?.uid else { return }
        
        let batch = db.batch()
        
        let followerRef = db.collection("users").document(currentUserID).collection("followers").document(user.id)
        batch.deleteDocument(followerRef)
        
        let followingRef = db.collection("users").document(user.id).collection("following").document(currentUserID)
        batch.deleteDocument(followingRef)
        
        batch.commit { [weak self] error in
            if let error = error {
                print("Error removing follower: \(error.localizedDescription)")
            } else {
                self?.followers.removeAll { $0.id == user.id }
            }
        }
    }
    
}
