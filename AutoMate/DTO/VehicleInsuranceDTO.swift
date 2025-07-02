//
//  VehicleInsuranceDTO.swift
//  AutoMate
//
//  Created by Bartlomiej Kowalczyk on 02/07/2025.
//

struct VehicleInsuranceDTO: Identifiable, Decodable {
    let id: Int
    let insuranceNumber: String
    let startDate: String 
    let endDate: String
    let insuranceCompany: String
    let additionalInfo: String?
}
