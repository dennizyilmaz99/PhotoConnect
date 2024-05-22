import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MinimalistTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal, 20).padding(.bottom, 10)
    }
}

struct CreateAccScreen: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("Skapa konto").font(.largeTitle).bold()
            Spacer()
            TextFieldContainer(email: $email, password: $password, name: $name)
            ButtonContainer(email: $email, password: $password, name: $name)
            Spacer()
            Spacer()
            Footer()
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
    @Binding var name: String
    
    var body: some View {
        VStack {
            TextField("Namn", text: $name)
                .textFieldStyle(MinimalistTextFieldStyle())
            TextField("E-post", text: $email)
                .textFieldStyle(MinimalistTextFieldStyle())
            SecureField("Lösenord", text: $password)
                .textFieldStyle(MinimalistTextFieldStyle())
        }.offset(y: -50)
    }
}

private struct ButtonContainer: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var name: String
    @State private var isNavigating = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Button(action: {
                if email.isEmpty || password.isEmpty || name.isEmpty {
                    alertMessage = "Alla fält måste vara ifyllda."
                    showAlert = true
                } else {
                    createUser(email: email, password: password, name: name)
                }
            }, label: {
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 225, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .gray, radius: 20, x: 0, y: 10).opacity(0.2)
                    .overlay {
                        Text("Skapa konto").foregroundStyle(.black).fontWeight(.medium)
                    }
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Fel"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isNavigating) {
                HomeScreen()
            }
        }.navigationBarBackButtonHidden()
    }
    
    func createUser(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Fel vid skapande av konto: \(error.localizedDescription)"
                showAlert = true
            } else if let authResult = authResult {
                print("User created successfully, UID: \(authResult.user.uid)")
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
                alertMessage = "Fel vid lagring av användarinformation: \(error.localizedDescription)"
                showAlert = true
            } else {
                print("Document successfully written!")
            }
        }
    }
}

#Preview {
    CreateAccScreen()
}
