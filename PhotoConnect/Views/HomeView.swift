import SwiftUI

struct HomeView: View {
    var body: some View {
    VStack{
        Spacer()
        VStack{
            Text("Home")
        }
        Spacer()
        HStack{
            Button(action: {
                        print("Upload button tapped")
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .background(Color.blue.opacity(0.5))
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
            }.offset(y: -20)
        }
    }
}

#Preview {
    HomeView()
}
