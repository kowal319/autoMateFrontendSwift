import Foundation
import Alamofire

class ProfileViewModel: ObservableObject {
    @Published var username: String = "User"
    @Published var errorMessage: String?
    @Published var vehicles: [Vehicle] = []

    func fetchUserData() {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            self.errorMessage = "Brak tokenu JWT"
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        print("🔐 Token:", token)

        // Fetch user profile
        AF.request("http://192.168.0.54:8080/api/customer/profile", headers: headers)
            .validate()
            .responseDecodable(of: CustomerDTO.self) { response in
                switch response.result {
                case .success(let customer):
                    DispatchQueue.main.async {
                        self.username = customer.name
                        self.fetchVehicles(token: token)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = "Błąd profilu: \(error.localizedDescription)"
                    }
                }
            }
    }

    func fetchVehicles(token: String) {
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request("http://192.168.0.54:8080/api/customer/vehicles", headers: headers)
            .validate()
            .responseDecodable(of: [Vehicle].self) { response in
                switch response.result {
                case .success(let vehicles):
                    DispatchQueue.main.async {
                        self.vehicles = vehicles
                        print("✅ Pobrano \(vehicles.count) pojazdów")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = "Błąd pobierania pojazdów: \(error.localizedDescription)"
                    }
                }
            }
    }
}