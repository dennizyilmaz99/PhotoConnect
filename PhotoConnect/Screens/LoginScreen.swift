import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
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
        Text("Logga in").font(.title).bold()
    }
}

private struct ButtonContainer: View {
    @Binding var email: String
    @Binding var password: String
    @State private var isNavigating = false

    var body: some View {
        VStack {
            Button(action: {
                login(email: email, password: password)
            }, label: {
                Text("Skapa konto")
                    .foregroundColor(.white)
                    .frame(width: 225, height: 55)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            })
            .navigationDestination(isPresented: $isNavigating) {
                HomeScreen()
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
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
    LoginScreen()
}
