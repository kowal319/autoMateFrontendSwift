import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss

    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("New Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Section {
                Button("Save Changes") {
                    changePassword()
                }
                .disabled(isSaving)

                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .navigationTitle("Change Password")
    }

    func changePassword() {
        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/change-password") else { return }


        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // bo masz @PostMapping w backendzie
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = PasswordChangeRequest(password: password, confirmPassword: confirmPassword)

        do {
            let data = try JSONEncoder().encode(body)
            request.httpBody = data
        } catch {
            errorMessage = "Failed to encode request"
            return
        }

        isSaving = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSaving = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        dismiss()
                    } else if let data = data,
                              let msg = String(data: data, encoding: .utf8) {
                        errorMessage = msg
                    } else {
                        errorMessage = "Unknown error"
                    }
                }
            }
        }.resume()
    }
}
