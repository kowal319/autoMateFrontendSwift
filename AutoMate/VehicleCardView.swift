import SwiftUI

struct VehicleCardView: View {
    let vehicle: VehicleDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "car.fill")
                    .resizable()
                    .frame(width: 50, height: 30)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("\(vehicle.brandName) \(vehicle.modelName)")
                        .font(.headline)
                    Text("📍 \(vehicle.registrationPlate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}