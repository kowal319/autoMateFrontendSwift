import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 👋 Welcome Header
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("👋 Welcome \(viewModel.username)")
//                                              .font(.largeTitle)
//                                              .fontWeight(.bold)
//                                              .padding(.horizontal)
//                    }
                    
                    Text("👋 Welcome, \(viewModel.username)!")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)

                                    // Karta z cytatem i tipem
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("“Take care of your car, and it will take care of you.” 🚗")
                                            .font(.headline)
                                            .italic()
                                            .foregroundColor(.secondary)
                                        
                                        Text("Tip: Always add new info about your vehicles to keep your records fresh!")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                    .padding(.horizontal)

                    // Action Buttons
                    HStack(spacing: 12) {
                        NavigationLink(destination: EditProfileView(customer: viewModel.customer)) {
                            Text("Edit Profile")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        NavigationLink(destination: ChangePasswordView()) {                            Text("Change Password")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)

        
                        NavigationLink(destination: AddNewVehicleView()) {
                            Text("Add Vehicle")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    
                    .padding(.horizontal)
                    
                    // Vehicles Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🚗 My Garage")
                            .font(.headline)
                            .padding(.horizontal)

                        if !viewModel.vehicles.isEmpty {
                            ForEach(viewModel.vehicles, id: \.id) { vehicle in
                                NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                                    VehicleCardView(vehicle: vehicle)
                                }
                            }
                        } else {
                            Text("You have no vehicles yet.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }

                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchUserData()
            }
        }
    }
}


