//
//  UploadFormCompetition.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

// MARK: - Form Upload
struct UploadCompetitionForm: View {
    @ObservedObject var viewModel: CompetitionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedImageData: Data? = nil  // Anggap ini sudah terisi dari ImagePicker

    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Lomba") {
                    TextField("Nama Kompetisi", text: $viewModel.name)
                    TextField(
                        "Deskripsi",
                        text: $viewModel.desc,
                        axis: .vertical
                    )
                    .frame(minHeight: 100)
                }

                Section("Poster") {
                    Button(action: { /* Logika ImagePicker nanti di sini */  })
                    {
                        Label(
                            selectedImageData == nil
                                ? "Pilih Poster (Max 2MB)" : "Poster Terpilih",
                            systemImage: "photo.badge.plus"
                        )
                    }
                }
            }
            .navigationTitle("Tambah Kompetisi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .foregroundStyle(Color.btnNegative)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        // LOGIKA END-TO-END: Menggunakan data dari ViewModel
                        // Jika tidak ada gambar, pakai data dummy untuk tes
                        let finalData = selectedImageData ?? Data()
                        viewModel.submitCompetitionData(imageData: finalData)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(viewModel.name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    UploadCompetitionForm(
        viewModel: CompetitionViewModel(
            dbService: MockFirestoreService(),
            storageService: MockCloudStorage()
        )
    )
}
