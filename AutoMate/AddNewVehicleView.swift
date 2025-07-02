//
//  AddNewVehicle.swift
//  AutoMate
//
//  Created by Bartlomiej Kowalczyk on 23/06/2025.
//
import SwiftUI

struct AddNewVehicleView: View {
    @Environment(\.dismiss) var dismiss

    @State var customer: CustomerDTO
    @State private var isSaving = false
    @State private var errorMessage: String?
}
