import SwiftUI
import PhotosUI
import UIKit

struct UploadFormCompetition: View {
    @ObservedObject var viewModel: CompetitionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Competition Poster")) {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus").font(.system(size: 40))
                                    Text("Select Poster").font(.headline)
                                }
                                .foregroundStyle(Color.accentWalnut)
                                .frame(maxWidth: .infinity).frame(height: 150)
                                .background(Color.accentWalnut.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.accentWalnut, style: StrokeStyle(lineWidth: 2, dash: [5])))
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    viewModel.selectedImageData = data
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Competition Details")) {
                    TextField("Competition Name", text: $viewModel.name)
                    TextField("Description / Registration Info", text: $viewModel.desc, axis: .vertical)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Competition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        // 1. Panggil fungsi upload di background
                        viewModel.submitCompetitionData()
                        // 2. Langsung tutup form tanpa menunggu (UX yang mulus)
                        dismiss()
                    }) {
                        Text("Submit").fontWeight(.bold)
                    }
                    // Proteksi ganda agar user tidak menekan Submit jika belum lengkap
                    .disabled(viewModel.name.isEmpty || viewModel.selectedImageData == nil || viewModel.isLoading)
                }
            }
        }
    }
}
