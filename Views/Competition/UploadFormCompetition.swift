import PhotosUI
import SwiftUI
import UIKit

struct UploadFormCompetition: View {
    @ObservedObject var viewModel: CompetitionViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            // PERBAIKAN STYLE: Background Cream Khas YukDebat
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    Section(
                        header: Text("Competition Poster").font(.caption.bold())
                    ) {
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
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 40))
                                        Text("Select Poster").font(.headline)
                                    }
                                    .foregroundStyle(Color.accentWalnut).frame(
                                        maxWidth: .infinity
                                    ).frame(height: 150)
                                    .background(Color.accentWalnut.opacity(0.1))
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
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
                    .listRowBackground(Color.white)  // PERBAIKAN STYLE

                    Section(
                        header: Text("Competition Details").font(
                            .caption.bold()
                        )
                    ) {
                        TextField("Competition Name", text: $viewModel.name)
                        TextField(
                            "Description / Registration Info",
                            text: $viewModel.desc,
                            axis: .vertical
                        )
                        .frame(minHeight: 80)
                    }
                    .listRowBackground(Color.white)  // PERBAIKAN STYLE
                }
                .scrollContentBackground(.hidden)  // Menghilangkan background abu-abu default
                .padding(.top, -20)  // PERBAIKAN UX: Menarik form ke atas agar jarak title tidak terlalu jauh
            }
            .navigationTitle("Add Competition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        viewModel.submitCompetitionData()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(Color.btnPositive)
                    .disabled(
                        viewModel.name.isEmpty || viewModel.desc.isEmpty
                            || viewModel.selectedImageData == nil
                            || viewModel.isLoading
                    )
                }
            }
        }
    }
}
