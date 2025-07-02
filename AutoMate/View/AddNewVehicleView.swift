import SwiftUI

struct AddNewVehicleView: View {
    @Environment(\.dismiss) var dismiss

    @State private var brands: [BrandDTO] = []
    @State private var models: [ModelDTO] = []
    
    @State private var selectedBrandId: Int?
    @State private var selectedModelId: Int?
    @State private var registrationPlate = ""
    @State private var fuelType = ""
    @State private var vin = ""
    @State private var engineCapacity = ""
    @State private var year = ""
    @State private var description = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let engineSizes: [String] = stride(from: 0.6, through: 7.0, by: 0.1).map {
        String(format: "%.1f", $0)
    }
    let fuelTypes = ["PETROL", "DIESEL", "ELECTRIC", "HYBRID", "LPG"]
    
    let productionYears: [String] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (1980...currentYear).reversed().map { String($0) }
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Add New Vehicle")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                // MARK: - Brand Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brand")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Menu {
                        ForEach(brands) { brand in
                            Button(brand.name) {
                                selectedBrandId = brand.id
                                fetchModels(for: brand.id)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedBrandId.flatMap { id in brands.first(where: { $0.id == id })?.name } ?? "Choose...")
                                .foregroundColor(selectedBrandId == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

                // MARK: - Model Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Model")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Menu {
                        ForEach(models) { model in
                            Button(model.name) {
                                selectedModelId = model.id
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedModelId.flatMap { id in models.first(where: { $0.id == id })?.name } ?? "Choose...")
                                .foregroundColor(selectedModelId == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

                // MARK: - Text Fields
                CustomTextField(title: "Registration Plate", text: $registrationPlate)
                CustomTextField(title: "VIN", text: $vin)
                PickerField(label: "Year", selection: $year, options: productionYears)
                PickerField(label: "Engine Capacity (L)", selection: $engineCapacity, options: engineSizes)
                PickerField(label: "Fuel Type", selection: $fuelType, options: fuelTypes)
                CustomTextField(title: "Description", text: $description)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top)
                }

                Button(action: createVehicle) {
                    Text(isSaving ? "Saving..." : "Add Vehicle")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isSaving || selectedBrandId == nil || selectedModelId == nil)

                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.top, 8)

            }
            .padding()
        }
        .onAppear(perform: fetchBrands)
    }

    // MARK: - Helper Views

    struct CustomTextField: View {
        let title: String
        @Binding var text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField(title, text: $text)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }

    struct PickerField: View {
        let label: String
        @Binding var selection: String
        let options: [String]

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            selection = option
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.isEmpty ? "Choose..." : selection)
                            .foregroundColor(selection.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - API Calls

    func fetchBrands() {
//        guard let url = URL(string: "http://192.168.0.54:8080/api/brands") else {
            guard let url = URL(string: "http://192.168.0.54:8080/api/brands") else {
            print("❌ Invalid brand URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if year.isEmpty {
            year = String(Calendar.current.component(.year, from: Date()))
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([BrandDTO].self, from: data)
                    DispatchQueue.main.async {
                        self.brands = decoded
                    }
                } catch {
                    print("❌ Decode error:", error)
                }
            } else if let error = error {
                print("❌ Network error:", error.localizedDescription)
            }
        }.resume()
    }

    func fetchModels(for brandId: Int) {
//        guard let url = URL(string: "http://192.168.0.54:8080/api/brands/\(brandId)/models") else { return }
         guard let url = URL(string: "http://192.168.0.54:8080/api/brands/\(brandId)/models") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([ModelDTO].self, from: data) {
                    DispatchQueue.main.async {
                        self.models = decoded
                    }
                }
            }
        }.resume()
    }

    func createVehicle() {
        guard !registrationPlate.isEmpty,
              !vin.isEmpty,
              !fuelType.isEmpty,
              !description.isEmpty else {
            errorMessage = "All fields must be filled."
            return
        }

        guard let brandId = selectedBrandId,
              let modelId = selectedModelId,
              let yearInt = Int(year),
              let engine = Double(engineCapacity) else {
            errorMessage = "Please complete all fields correctly."
            return
        }

        guard let url = URL(string: "http://192.168.0.54:8080/api/customer/vehicles") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let vehicleToSend: [String: Any] = [
            "brandId": brandId,
            "modelId": modelId,
            "registrationPlate": registrationPlate,
            "year": yearInt,
            "vin": vin,
            "engineCapacity": engine,
            "fuelType": fuelType,
            "description": description
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: vehicleToSend)
        } catch {
            errorMessage = "JSON encoding error."
            return
        }

        isSaving = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSaving = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        dismiss()
                    } else {
                        if let data = data {
                            print("❌ Error response:", String(data: data, encoding: .utf8) ?? "")
                        }
                        self.errorMessage = "Failed to add vehicle (code \(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
}
