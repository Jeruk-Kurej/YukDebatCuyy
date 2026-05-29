import SwiftUI

struct UploadCompetitionForm: View {
    @ObservedObject var viewModel: CompetitionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Lomba") {
                    TextField("Nama Kompetisi", text: $viewModel.name)
                    TextField("Deskripsi Lomba", text: $viewModel.desc, axis: .vertical)
                        .frame(minHeight: 100)
                }

                // Notifikasi Status
                if let msg = viewModel.statusMsg {
                    Section {
                        Text(msg)
                            .font(.subheadline.bold())
                            .foregroundStyle(viewModel.isUploadSuccess ? Color.green : Color.red)
                    }
                }
            }
            .navigationTitle("Tambah Kompetisi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        viewModel.submitCompetitionData()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Kirim Lomba").fontWeight(.bold)
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.isLoading)
                }
            }
            // Auto-dismiss jika upload sukses
            .onChange(of: viewModel.isUploadSuccess) { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel.statusMsg = nil // Reset pesan
                        dismiss()
                    }
                }
            }
        }
    }
}
