import SwiftUI
import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var completion: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, completion: completion)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        var completion: (Result<URL, Error>) -> Void
        
        init(_ parent: ImagePicker, completion: @escaping (Result<URL, Error>) -> Void) {
            self.parent = parent
            self.completion = completion
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                uploadImageToFirebase(image, completion: completion)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func uploadImageToFirebase(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image conversion to data failed"])))
                return
            }
            
            guard let userID = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
                return
            }
            
            let storageRef = Storage.storage().reference()
            let imageID = UUID().uuidString
            let imageRef = storageRef.child("images/\(imageID).jpg")
            
            let timestamp = Timestamp()
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                        let db = Firestore.firestore()
                        let imageURL = url.absoluteString
                        let imageData: [String: Any] = [
                            "url": imageURL,
                            "timestamp": timestamp
                        ]
                        db.collection("users").document(userID).updateData([
                            "images": FieldValue.arrayUnion([imageData])
                        ]) { error in
                            if let error = error {
                                print("Error saving image data to Firestore: \(error.localizedDescription)")
                            } else {
                                print("Image data successfully added to Firestore")
                            }
                        }
                    }
                }
            }
        }
    }
}
