import SwiftUI
import FirebaseAuth

struct HomeScreen: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Hem", systemImage: "house")
                }

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    HomeScreen()
}
