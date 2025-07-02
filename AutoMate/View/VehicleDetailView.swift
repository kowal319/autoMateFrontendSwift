import SwiftUI

struct VehicleDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var vehicle: VehicleDTO
    @StateObject private var viewModel = VehicleDetailViewModel()
    @State private var showingAddInsuranceSheet = false

    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Nagłówek
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.white)
                        Text("Vehicle Information")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        NavigationLink(destination: EditVehicleView(vehicle: vehicle, onSave: { updatedPlate, updatedDescription in
                            vehicle.registrationPlate = updatedPlate
                            vehicle.description = updatedDescription
                        })) {
                            Image(systemName: "pencil")
                                .padding(8)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                        }

                        Button(action: {
                            viewModel.deleteVehicle(vehicleId: vehicle.id) { success in
                                if success {
                                    dismiss()
                                }
                            }
                        }) {
                            Image(systemName: "trash")
                                .padding(8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Color.black)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Karta z informacjami o pojeździe
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        infoRow(title: "Brand", value: vehicle.brandName)
                        infoRow(title: "Model", value: vehicle.modelName)
                        infoRow(title: "Registration Plate", value: vehicle.registrationPlate)
                        infoRow(title: "VIN", value: vehicle.vin)
                        infoRow(title: "Year", value: "\(vehicle.year)")
                        infoRow(title: "Engine Capacity", value: "\(vehicle.engineCapacity) cm³")
                        infoRow(title: "Fuel Type", value: vehicle.fuelType)
                        infoRow(title: "Description", value: vehicle.description ?? "-")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                }
                
                // Ubezpieczenia
                VStack(alignment: .leading, spacing: 16) {
                    Text("Insurances")
                        .font(.title3)
                        .fontWeight(.bold)

                    if viewModel.isLoadingInsurances {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if viewModel.insurances.isEmpty {
                        Text("No insurances found")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.insurances) { insurance in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Insurance Number: \(insurance.insuranceNumber)")
                                    .fontWeight(.semibold)
                                Text("Company: \(insurance.insuranceCompany)")
                                Text("Start Date: \(insurance.startDate)")
                                Text("End Date: \(insurance.endDate)")
                                if let info = insurance.additionalInfo, !info.isEmpty {
                                    Text("Additional Info: \(info)")
                                }
                            }
                            
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                   RoundedRectangle(cornerRadius: 12)
                                       .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                               )
                        }
                    }

                    // 👇 Przycisk dodawania ubezpieczenia (teraz w dobrym miejscu)
                    NavigationLink(destination: AddInsuranceView(vehicleId: vehicle.id)) {
                        Label("Add Insurance", systemImage: "plus")
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                .padding(.horizontal)
                
            }
            .padding(.top)
        } 
        .onAppear {
            viewModel.fetchInsurances(vehicleId: vehicle.id)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    func deleteInsurance(insuranceId: Int) {
        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/vehicle/\(vehicle.id)/insurance/\(insuranceId)") else {
            print("❌ Zły URL do usuwania ubezpieczenia")
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
                    print("❌ Błąd usuwania ubezpieczenia:", error.localizedDescription)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Ubezpieczenie usunięte")
                    viewModel.fetchInsurances(vehicleId: vehicle.id) // odśwież listę
                } else {
                    print("❌ Nie udało się usunąć ubezpieczenia")
                }
            }
        }.resume()
    }
}
