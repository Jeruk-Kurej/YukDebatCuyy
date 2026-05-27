//
//  CompetitionView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct CompetitionView: View {
    @StateObject private var viewModel = CompetitionViewModel(
        dbService: MockFirestoreService(),
        storageService: MockCloudStorage()
    )
    @State private var isShowingUploadForm = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.competitions) { comp in
                            CompetitionCard(comp: comp)
                        }
                    }
                    .padding(24)
                }
                
                // FAB untuk akses Upload bagi Promotor
                Button(action: { isShowingUploadForm = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.btnPositive)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(24)
            }
            .navigationTitle("Competition Board")
            .sheet(isPresented: $isShowingUploadForm) {
                UploadCompetitionForm(viewModel: viewModel)
            }
            .onAppear { viewModel.fetchCompetitions() }
        }
    }
}

struct CompetitionCard: View {
    let comp: CompetitionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(comp.name)
                .font(.system(.title3, design: .serif, weight: .bold))
            
            Text(comp.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Link("Daftar Sekarang", destination: URL(string: comp.registrationUrl) ?? URL(string: "https://google.com")!)
                .font(.subheadline.bold())
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.btnPositive)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Form Upload
struct UploadCompetitionForm: View {
    @ObservedObject var viewModel: CompetitionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedImageData: Data? = nil // Anggap ini sudah terisi dari ImagePicker
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Lomba") {
                    TextField("Nama Kompetisi", text: $viewModel.name)
                    TextField("Deskripsi", text: $viewModel.desc, axis: .vertical)
                        .frame(minHeight: 100)
                }
                
                Section("Poster") {
                    Button(action: { /* Logika ImagePicker nanti di sini */ }) {
                        Label(selectedImageData == nil ? "Pilih Poster (Max 2MB)" : "Poster Terpilih",
                              systemImage: "photo.badge.plus")
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
    CompetitionView()
}
