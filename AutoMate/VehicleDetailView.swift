import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(vehicle.brand.name) \(vehicle.model.name)")
                .font(.largeTitle)
                .bold()
            Text("Rejestracja: \(vehicle.registrationPlate)")
            Text("Paliwo: \(vehicle.fuelType)")
            Text("Rok produkcji: \(vehicle.year)")
        }
        .padding()
        .navigationTitle("Szczegóły pojazdu")
    }
}