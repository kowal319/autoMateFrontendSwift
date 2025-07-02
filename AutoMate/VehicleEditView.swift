import SwiftUI

struct VehicleEditView: View {
    @Environment(\.dismiss) var dismiss
    let vehicle: VehicleDTO

    @State private var brandName: String
    @State private var modelName: String
    @State private var registrationPlate: String
    @State private var vin: String
    @State private var year: String
    @State private var engineCapacity: String
    @State private var fuelType: String
    @State private var description: String

    init(vehicle: VehicleDTO) {
        self.vehicle = vehicle
        _brandName = State(initialValue: vehicle.brandName)
        _modelName = State(initialValue: vehicle.modelName)
        _registrationPlate = State(initialValue: vehicle.registrationPlate)
        _vin = State(initialValue: vehicle.vin)
        _year = State(initialValue: "\(vehicle.year)")
        _engineCapacity = State(initialValue: "\(vehicle.engineCapacity)")
        _fuelType = State(initialValue: vehicle.fuelType)
        _description = State(initialValue: vehicle.description ?? "")
    }

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Brand", text: $brandName)
                TextField("Model", text: $modelName)
                TextField("Registration Plate", text: $registrationPlate)
                TextField("VIN", text: $vin)
                TextField("Year", text: $year)
                    .keyboardType(.numberPad)
                TextField("Engine Capacity (cm³)", text: $engineCapacity)
                    .keyboardType(.decimalPad)
                TextField("Fuel Type", text: $fuelType)
            }

            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(height: 100)
            }

            Button(action: updateVehicle) {
                Label("Save", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(12)
        }
        .navigationTitle("Edit Vehicle")
    }

    func updateVehicle() {
        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/vehicles/\(vehicle.id)") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let updatedVehicle: [String: Any] = [
            "brandName": brandName,
            "modelName": modelName,
            "registrationPlate": registrationPlate,
            "vin": vin,
            "year": Int(year) ?? 0,
            "engineCapacity": Int(engineCapacity) ?? 0,
            "fuelType": fuelType,
            "description": description
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updatedVehicle)
        } catch {
            print("❌ JSON encode error: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Update error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Vehicle updated")
                    dismiss()
                } else {
                    print("❌ Update failed")
                }
            }
        }.resume()
    }
}