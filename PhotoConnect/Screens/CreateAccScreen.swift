import SwiftUI
import FirebaseAuth

struct CreateAccScreen: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Header()
                Spacer()
                TextFieldContainer(email: $email, password: $password)
                ButtonContainer(email: $email, password: $password)
                Spacer()
                Footer()
            }
        }
    }
}

private struct Footer: View {
    
    @State private var isNavigating = false
    
    var body: some View {
        HStack{
            Text("Har du ett konto?")
            Button(action: {
                isNavigating = true
            }, label: {
                Text("Logga in")
            }).navigationDestination(isPresented: $isNavigating) {
                LoginScreen()
            }
        }
    }
}

private struct TextFieldContainer: View {
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack {
            TextField("E-post", text: $email)
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
    @Binding var email: String
    @Binding var password: String
    @State private var isNavigating = false

    var body: some View {
        VStack {
            Button(action: {
                createUser(email: email, password: password)
            }, label: {
                Text("Skapa konto")
                    .foregroundColor(.white)
                    .frame(width: 225, height: 55)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            })
            .navigationDestination(isPresented: $isNavigating) {
                LoginScreen()
            }
        }
    }

    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                print("User created successfully")
                isNavigating = true
            }
        }
    }
}

#Preview {
    CreateAccScreen()
}
