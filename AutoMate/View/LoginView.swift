import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Zaloguj się")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $username)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Hasło", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Zaloguj") {
                AuthService.shared.login(username: username, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let token):
                            // Zapisz token i przejdź dalej
                            UserDefaults.standard.set(token, forKey: "jwtToken")
                            isLoggedIn = true
                        case .failure(let error):
                            errorMessage = "Błąd logowania: \(error.localizedDescription)"
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            ProfileView() // widok po zalogowaniu
        }
    }
}
