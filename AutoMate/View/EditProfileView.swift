import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss

    @State var customer: CustomerDTO
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Edit Information")) {
                TextField("Name", text: $customer.name)
                TextField("Email", text: .constant(customer.email)) // readonly
                    .disabled(true)
                    .foregroundColor(.gray)

            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Section {
                Button("Save Changes") {
                    updateProfile()
                }
                .disabled(isSaving)

                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Profile")
    }

    func updateProfile() {
        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/profile") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
              request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          }

        do {
            let data = try JSONEncoder().encode(customer)
            request.httpBody = data
        } catch {
            errorMessage = "Failed to encode data"
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

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    dismiss()
                } else {
                    errorMessage = "Something went wrong."
                }
            }
        }.resume()
    }
}
