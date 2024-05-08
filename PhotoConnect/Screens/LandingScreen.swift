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
        HStack {
            VStack(alignment: .leading) {
                Text("Photo").font(.system(size: 84)).fontWeight(.thin)
                Text("Connect").font(.system(size: 84)).bold()
            }
            Spacer()
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
                    .foregroundStyle(.white)
                    .frame(width: 225, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .gray, radius: 20, x: 0, y: 10).opacity(0.2)
                    .overlay {
                        Text("Skapa dina minnen").foregroundStyle(.black).fontWeight(.medium)
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
