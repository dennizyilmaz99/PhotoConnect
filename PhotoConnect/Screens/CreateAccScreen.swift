import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccScreen: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""

    var body: some View {
            VStack {
                Spacer()
                TextFieldContainer(email: $email, password: $password, name: $name)
                ButtonContainer(email: $email, password: $password, name: $name)
                Spacer()
                Footer()
            }.navigationTitle("Skapa konto")
            .navigationBarTitleDisplayMode(.large)
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
    @Binding var name: String

    var body: some View {
        VStack {
            TextField("Namn", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            TextField("E-post", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            SecureField("Lösenord", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
        }.offset(y: -100)
    }
}

private struct ButtonContainer: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var name: String
    @State private var isNavigating = false

    var body: some View {
            VStack {
                Button(action: {
                    createUser(email: email, password: password, name: name)
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
            }.navigationBarBackButtonHidden()
    }

    func createUser(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else if let authResult = authResult {
                print("User created successfully, UID: \(authResult.user.uid)")
                // Spara användarinformation i Firestore med UID som dokument-ID
                self.addUserToFirestore(email: email, name: name, password: password, uid: authResult.user.uid)
                isNavigating = true
            }
        }
    }

    func addUserToFirestore(email: String, name: String, password: String, uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "uid": uid,
            "email": email,
            "name": name,
            "password": password
        ]) { error in
            if let error = error {
                print("Error writing document: \(error.localizedDescription)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}

#Preview {
    CreateAccScreen()
}
