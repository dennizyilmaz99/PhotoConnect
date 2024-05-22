import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var isSkeletonVisible = false
    @Binding var isFetched: Bool
    
    var body: some View {
        VStack {
            VStack {
                Text("Flöde")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                ScrollView(.vertical, showsIndicators: false) {
                    if isSkeletonVisible {
                        SkeletonView()
                            .padding(.horizontal)
                    }

                    if !isFetched {
                        ForEach(0..<5) { _ in
                            SkeletonView()
                                .padding(.horizontal)
                        }
                    } else {
                        ForEach(viewModel.userImages) { userImage in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(userImage.userName)
                                    .font(.headline)
                                    .padding(.leading, 10)
                                
                                WebImage(url: URL(string: userImage.imageURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height * 0.5)
                                    .cornerRadius(10)
                                    .padding(.bottom, 25)
                            }
                        }
                    }
                }
            }

            Button(action: {
                showingImagePicker = true
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
            .offset(y: -20)
        }
        .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $image) { result in
                        switch result {
                        case .success:
                            isSkeletonVisible = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                viewModel.fetchAllUserImages()
                            }
                        case .failure(let error):
                            print("Image picker error: \(error)")
                        }
                    }
                }
                .onAppear {
                    print("isFetched: \(isFetched)")
                    if !isFetched {
                        print("hämtar bilden 1")
                        isSkeletonVisible = true
                        viewModel.fetchAllUserImages()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFetched = true
                            print("isFetched: \(isFetched)")
                            isSkeletonVisible = false
                        }
                    } else {
                        viewModel.fetchAllUserImages()
                    }
                }
                .onChange(of: image) { newImage in
                    if newImage != nil {
                        isSkeletonVisible = true
                    }
                }
                .onReceive(viewModel.$userImages) { _ in
                    isSkeletonVisible = false
                }
    }
}

struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 20)
                .padding(.leading)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height * 0.5)
                .padding(.bottom, 25)

            
        }
        .shimmer()
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0.0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]), startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase * UIScreen.main.bounds.width)
                    .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 2.0
                }
            }
    }
}
