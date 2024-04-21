import SwiftUI

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
        }
    }
}

#Preview {
    HomeScreen()
}
