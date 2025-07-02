struct PasswordChangeRequest: Codable {
    let password: String
    let confirmPassword: String
}