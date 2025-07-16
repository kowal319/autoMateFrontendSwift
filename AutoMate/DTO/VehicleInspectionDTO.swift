//
//  InspectionDTO.swift
//  AutoMate
//
//  Created by Bartlomiej Kowalczyk on 15/07/2025.
//


struct VehicleInspectionDTO: Identifiable, Decodable {
    let id: Int
    let insuranceNumber: String
    let startDate: String
    let endDate: String
    let insuranceCompany: String
    let additionalInfo: String?
}
