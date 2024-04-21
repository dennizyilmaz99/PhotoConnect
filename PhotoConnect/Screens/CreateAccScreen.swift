import SwiftUI

struct CreateAccScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Header()
                Spacer()
                TextFieldContainer()
                ButtonContainer()
                Spacer()
            }
        }
    }
}

private struct TextFieldContainer: View {
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            TextField("E-post", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            SecureField("Lösenord", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
        }.offset(y: -100)
    }
}

private struct Header: View {
    var body: some View {
        Text("Skapa konto").font(.title).bold()
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
                        Text("Skapa konto").foregroundStyle(.white)
                    }
            })
        }
        .navigationDestination(isPresented: $isNavigating) {
            LoginScreen()
        }
    }
}

#Preview {
    CreateAccScreen()
}
