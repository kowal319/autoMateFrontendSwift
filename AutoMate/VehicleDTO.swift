struct VehicleDTO: Decodable {
    let id: Int
    let brandId: Int
    let modelId: Int
    let registrationPlate: String
    let year: Int
    let vin: String
    let engineCapacity: Double
    let fuelType: String
    let description: String?
    let customerId: Int
}