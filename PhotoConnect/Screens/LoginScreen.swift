import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Logga in").font(.largeTitle).bold()
                Spacer()
                TextFieldContainer(email: $email, password: $password)
                ButtonContainer(email: $email, password: $password)
                Spacer()
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
                .textFieldStyle(MinimalistTextFieldStyle())
            SecureField("Lösenord", text: $password)
                .textFieldStyle(MinimalistTextFieldStyle())
        }.offset(y: -50)
    }
}

private struct ButtonContainer: View {
    @Binding var email: String
    @Binding var password: String
    @State private var isNavigating = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Button(action: {
                if email.isEmpty || password.isEmpty {
                    alertMessage = "Både e-post och lösenord måste anges."
                    showAlert = true
                } else {
                    login(email: email, password: password)
                }
            }, label: {
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 225, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .gray, radius: 20, x: 0, y: 10).opacity(0.2)
                    .overlay {
                        Text("Logga in").foregroundStyle(.black).fontWeight(.medium)
                    }
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Fel"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isNavigating) {
                HomeScreen()
            }
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Fel vid inloggning: \(error.localizedDescription)"
                showAlert = true
            } else {
                print("User logged in successfully")
                isNavigating = true
            }
        }
    }
}

#Preview {
    LoginScreen()
}
