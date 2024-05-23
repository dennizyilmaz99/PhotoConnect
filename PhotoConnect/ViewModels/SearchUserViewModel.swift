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

    private var db = Firestore.firestore()
    private var auth = Auth.auth()

    init() {
        fetchFollowing()
    }

    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        db.collection("users")
            .whereField("name", isGreaterThanOrEqualTo: searchText)
            .whereField("name", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }

                self?.searchResults = documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? "Unknown"
                    return SearchUser(id: id, name: name)
                }.filter { $0.id != self?.auth.currentUser?.uid } // Exclude current user
            }
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

        db.collection("users").document(currentUserID).collection("following").document(user.id).setData([
            "name": user.name
        ]) { error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
            } else {
                self.fetchFollowing()
            }
        }
    }

    func unfollowUser(_ user: SearchUser) {
        guard let currentUserID = auth.currentUser?.uid else { return }

        db.collection("users").document(currentUserID).collection("following").document(user.id).delete { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                self.fetchFollowing()
            }
        }
    }
}
