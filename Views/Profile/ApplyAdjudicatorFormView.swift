//
//  ApplyAdjudicatorFormView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import PhotosUI
import SwiftUI

struct ApplyAdjudicatorFormView: View {
    @ObservedObject var viewModel: AdjudicatorRequestViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sertifikat / Bukti Kompetensi")) {
                    HStack {
                        Spacer()
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images
                        ) {
                            if let imageData = viewModel.selectedImageData,
                                let uiImage = UIImage(data: imageData)
                            {
                                Image(uiImage: uiImage).resizable()
                                    .scaledToFill()
                                    .frame(height: 200).clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.badge.plus").font(
                                        .system(size: 40)
                                    )
                                    Text("Upload Sertifikat").font(.headline)
                                }
                                .foregroundStyle(Color.accentWalnut).frame(
                                    maxWidth: .infinity
                                ).frame(height: 150)
                                .background(Color.accentWalnut.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        Color.accentWalnut,
                                        style: StrokeStyle(
                                            lineWidth: 2,
                                            dash: [5]
                                        )
                                    )
                                )
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?
                                    .loadTransferable(type: Data.self)
                                {
                                    viewModel.selectedImageData = data
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Pengalaman Debat/Penjurian")) {
                    TextField(
                        "Ceritakan pengalaman Anda...",
                        text: $viewModel.experience,
                        axis: .vertical
                    )
                    .frame(minHeight: 100)
                }
            }
            .navigationTitle("Daftar Menjadi Juri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        if let name = authVM.currentUser?.name,
                            let email = authVM.currentUser?.email
                        {
                            viewModel.submitRequest(
                                userName: name,
                                userEmail: email
                            )
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                    .disabled(
                        viewModel.experience.isEmpty
                            || viewModel.selectedImageData == nil
                            || viewModel.isLoading
                    )
                }
            }
        }
    }
}
