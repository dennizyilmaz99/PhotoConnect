import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SearchUser: Identifiable {
    let id: String
    let name: String
}

class SearchUserViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchUser] = []
    @Published var followingUsers: [String] = []

    private var allUsers: [SearchUser] = []
    private var db = Firestore.firestore()
    private var auth = Auth.auth()

    init() {
        fetchFollowing()
        fetchAllUsers()
    }

    func fetchAllUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            self.allUsers = documents.compactMap { document in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? "Unknown"
                return SearchUser(id: id, name: name)
            }.filter { $0.id != self.auth.currentUser?.uid } // Exclude current user
        }
    }

    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        searchResults = allUsers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }

    func fetchFollowing() {
        guard let currentUserID = auth.currentUser?.uid else { return }

        db.collection("users").document(currentUserID).collection("following").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching following users: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No following users found")
                return
            }

            self?.followingUsers = documents.map { $0.documentID }
        }
    }

    func isFollowing(_ user: SearchUser) -> Bool {
        return followingUsers.contains(user.id)
    }

    func followUser(_ user: SearchUser) {
        guard let currentUserID = auth.currentUser?.uid else { return }

        let batch = db.batch()

        // Lägg till följning i currentUser's "following" kollektion
        let followingRef = db.collection("users").document(currentUserID).collection("following").document(user.id)
        batch.setData(["name": user.name], forDocument: followingRef)

        // Lägg till följare i följda användarens "followers" kollektion
        let followerRef = db.collection("users").document(user.id).collection("followers").document(currentUserID)
        batch.setData(["name": auth.currentUser?.displayName ?? "Unknown"], forDocument: followerRef)

        batch.commit { [weak self] error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
            } else {
                self?.followingUsers.append(user.id)
                self?.performSearch() // Refresh the search results to update follow status
            }
        }
    }


    func unfollowUser(_ user: SearchUser) {
        guard let currentUserID = auth.currentUser?.uid else { return }

        db.collection("users").document(currentUserID).collection("following").document(user.id).delete { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                self.followingUsers.removeAll { $0 == user.id }
                self.performSearch() // Refresh the search results to update follow status
            }
        }
    }
}
