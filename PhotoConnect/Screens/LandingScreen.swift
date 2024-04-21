import SwiftUI

struct LandingScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Header()
                Spacer()
                ButtonContainer()
                Spacer()
            }
        }
    }
}

private struct Header: View {
    var body: some View {
        VStack{
            Text("Välkommen till").font(.title).bold()
            Text("PhotoConnect").font(.title).bold()
        }
    }
}

private struct ButtonContainer: View {
    @State private var isNavigating = false
    
    var body: some View {
        VStack {
            Button(action: {
                isNavigating = true
            }, label: {
                Rectangle()
                    .foregroundStyle(.blue)
                    .frame(width: 225, height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        Text("Skapa dina minnen").foregroundStyle(.white)
                    }
            })
        }
        .navigationDestination(isPresented: $isNavigating) {
            CreateAccScreen()
        }
    }
}

#Preview {
    LandingScreen()
}
