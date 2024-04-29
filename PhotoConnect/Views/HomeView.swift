import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var uploadStatus: String = ""
    
    var body: some View {
        VStack {
            Text("Flöde").font(.title).bold().frame(maxWidth: .infinity, alignment: .leading).padding()

            // ScrollView for displaying user images
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(viewModel.userImages) { userImage in
                    VStack(alignment: .leading, spacing: 10) {
                        WebImage(url: URL(string: userImage.imageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height * 0.4)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        Text(userImage.userName)
                            .font(.headline)
                            .padding(.leading, 20)
                    }
                }
            }

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            if !uploadStatus.isEmpty {
                Text(uploadStatus)
            }
            
            Spacer()
            
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
                    .overlay(
                        Circle()
                        .stroke(Color.white, lineWidth: 5)
                    )
                    .foregroundColor(.blue)
            }
            .offset(y: -22)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image) { result in
                switch result {
                case .success(let url):
                    viewModel.fetchAllUserImages()  // Refresh the images after upload
                case .failure(let error): break
                }
            }
        }
        .onAppear {
            viewModel.fetchAllUserImages()  // Load the images when the view appears
        }
    }
}

// Assuming you have the appropriate ImagePicker and ViewModel setup as discussed in previous messages.
#Preview {
    HomeView()
}
