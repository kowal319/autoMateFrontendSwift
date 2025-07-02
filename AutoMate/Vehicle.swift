import Foundation

struct Vehicle: Identifiable, Decodable {
    let id: Int
    let registrationPlate: String
    let fuelType: String
    let year: Int
    let brand: Brand
    let model: Model
}

struct Brand: Decodable {
    let name: String
}

struct Model: Decodable {
    let name: String
}