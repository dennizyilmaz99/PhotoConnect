import SwiftUI
import FirebaseAuth

struct HomeScreen: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var isFetched = false
    
    var userID: String
        
        init() {
            if let currentUser = Auth.auth().currentUser {
                self.userID = currentUser.uid
            } else {
                // Hantera fallet om ingen användare är inloggad
                self.userID = "no_user"
            }
        }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    if selectedTab == 0 {
                        HomeView(isFetched: $isFetched)
                            .transition(.push(from: .leading))
                            .id(selectedTab)
                    } else if selectedTab == 1 {
                        SearchUserView().transition(.push(from: .leading))
                    } else if selectedTab == 2 {
                        ProfileView(userID: userID)
                            .transition(.push(from: .leading))
                            .id(selectedTab)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    if selectedTab != 0 {
                        withAnimation {
                            previousTab = selectedTab
                            selectedTab = 0
                            scaleEffect = 1.5
                        }
                        withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                            scaleEffect = 1.0
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 22))
                            .scaleEffect(selectedTab == 0 ? scaleEffect : 1.0).padding(.bottom, 2)
                        Text("Hem").font(.system(size: 12))
                    }
                    .padding()
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)
                }
                .disabled(selectedTab == 0)
                
                Spacer()
                
                Button(action: {
                    if selectedTab != 1 {
                        withAnimation {
                            previousTab = selectedTab
                            selectedTab = 1
                            scaleEffect = 1.5
                        }
                        withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                            scaleEffect = 1.0
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 22))
                            .scaleEffect(selectedTab == 1 ? scaleEffect : 1.0).padding(.bottom, 2)
                        Text("Sök").font(.system(size: 12))
                    }
                    .padding()
                    .foregroundColor(selectedTab == 1 ? .blue : .gray)
                }
                .disabled(selectedTab == 1)
                
                Spacer()
                
                Button(action: {
                    if selectedTab != 2 {
                        withAnimation {
                            previousTab = selectedTab
                            selectedTab = 2
                            scaleEffect = 1.5
                        }
                        withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                            scaleEffect = 1.0
                        }
                    }
                }) {
                    VStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .scaleEffect(selectedTab == 2 ? scaleEffect : 1.0).padding(.bottom, 2)
                        Text("Profil").font(.system(size: 12))
                    }
                    .padding()
                    .foregroundColor(selectedTab == 2 ? .blue : .gray)
                }
                .disabled(selectedTab == 2)
                
                Spacer()
            }
            .background(Color(.white))
            .frame(height: 50)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    HomeScreen()
}
