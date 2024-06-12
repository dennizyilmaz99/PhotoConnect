import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FollowUser: Identifiable {
    let id: String
    let name: String
    var isFollowing: Bool = false
}

class FollowViewModel: ObservableObject {
    @Published var followers: [FollowUser] = []
    @Published var following: [FollowUser] = []
    private var db = Firestore.firestore()
    
    private var userID: String
    private var currentUserID: String?
    
    init(userID: String) {
        self.userID = userID
        self.currentUserID = Auth.auth().currentUser?.uid
        fetchFollowers()
        fetchFollowing()
    }
    
    func fetchFollowers() {
        db.collection("users").document(userID).collection("followers").getDocuments { [weak self] snapshot, error in
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
                    
                    self?.isCurrentUserFollowing(id) { isFollowing in
                        followers.append(FollowUser(id: id, name: name, isFollowing: isFollowing))
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self?.followers = followers
            }
        }
    }
    
    func fetchFollowing() {
        db.collection("users").document(userID).collection("following").getDocuments { [weak self] snapshot, error in
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
                    
                    self?.isCurrentUserFollowing(id) { isFollowing in
                        following.append(FollowUser(id: id, name: name, isFollowing: isFollowing))
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self?.following = following
            }
        }
    }
    
    func isCurrentUserFollowing(_ userID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUserID else {
            completion(false)
            return
        }
        
        db.collection("users").document(currentUserID).collection("following").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func followUser(_ user: FollowUser) {
        guard let currentUserID = currentUserID else { return }
        
        let batch = db.batch()
        
        let followingRef = db.collection("users").document(currentUserID).collection("following").document(user.id)
        batch.setData([:], forDocument: followingRef)
        
        let followerRef = db.collection("users").document(user.id).collection("followers").document(currentUserID)
        batch.setData([:], forDocument: followerRef)
        
        batch.commit { [weak self] error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
            } else {
                self?.updateFollowingStatus(for: user.id, isFollowing: true)
            }
        }
    }
    
    func unfollowUser(_ user: FollowUser) {
        guard let currentUserID = currentUserID else { return }
        
        let batch = db.batch()
        
        let followingRef = db.collection("users").document(currentUserID).collection("following").document(user.id)
        batch.deleteDocument(followingRef)
        
        let followerRef = db.collection("users").document(user.id).collection("followers").document(currentUserID)
        batch.deleteDocument(followerRef)
        
        batch.commit { [weak self] error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                self?.updateFollowingStatus(for: user.id, isFollowing: false)
            }
        }
    }
    
    private func updateFollowingStatus(for userID: String, isFollowing: Bool) {
        if let index = self.followers.firstIndex(where: { $0.id == userID }) {
            self.followers[index].isFollowing = isFollowing
        }
        if let index = self.following.firstIndex(where: { $0.id == userID }) {
            self.following[index].isFollowing = isFollowing
        }
    }
    
    func removeFollower(_ user: FollowUser) {
        guard let currentUserID = currentUserID else { return }
        
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
                self?.fetchFollowers()
            }
        }
    }
}
