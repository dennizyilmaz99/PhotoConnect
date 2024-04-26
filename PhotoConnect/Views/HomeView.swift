import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Ingen uppdatering krävs
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


struct HomeView: View {
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
    VStack{
        VStack{
            Text("Flöde").font(.title).bold().frame(maxWidth: .infinity, alignment: .leading).padding()
        }
        Spacer()
        HStack{
            Button(action: {
                showingImagePicker = true
                        print("Upload button tapped")
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
            }.offset(y: -20)
        }.sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image)
        }
    }
}

#Preview {
    HomeView()
}
