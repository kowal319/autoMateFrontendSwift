//
//  VehicleDetailViewModel.swift
//  AutoMate
//
//  Created by Bartlomiej Kowalczyk on 02/07/2025.
//

import Foundation
import Combine

class VehicleDetailViewModel: ObservableObject {
    @Published var insurances: [VehicleInsuranceDTO] = []
    @Published var isLoadingInsurances = false
    
    func fetchInsurances(vehicleId: Int) {
        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/vehicle/\(vehicleId)/insurances") else {
            print("❌ Zły URL ubezpieczeń")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        DispatchQueue.main.async {
            self.isLoadingInsurances = true
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoadingInsurances = false
                
                if let error = error {
                    print("❌ Błąd pobierania ubezpieczeń:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("❌ Brak danych ubezpieczeń")
                    return
                }
                
                do {
                    self.insurances = try JSONDecoder().decode([VehicleInsuranceDTO].self, from: data)
                } catch {
                    print("❌ Błąd dekodowania ubezpieczeń:", error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func deleteVehicle(vehicleId: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/vehicles/\(vehicleId)") else {
            print("❌ Zły URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Błąd usuwania:", error.localizedDescription)
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Pojazd usunięty")
                    completion(true)
                } else {
                    print("❌ Nie udało się usunąć pojazdu")
                    completion(false)
                }
            }
        }.resume()
    }
}
