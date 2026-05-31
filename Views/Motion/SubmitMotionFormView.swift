//
//  SubmitMotionFormView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A form for Debaters to submit custom debate motions for Admin approval.
struct SubmitMotionFormView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: MotionArchiveViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var category: String = "General"

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    Section(
                        header: Text("Motion Suggestion Details").font(
                            .caption.bold()
                        )
                    ) {
                        TextField(
                            "Enter your custom motion title...",
                            text: $title,
                            axis: .vertical
                        )
                        .lineLimit(3...6)

                        Picker("Category", selection: $category) {
                            Text("General").tag("General")
                            Text("Law & Constitution").tag("Law & Constitution")
                            Text("Education").tag("Education")
                            Text("Economy & Business").tag("Economy & Business")
                            Text("Politics & Social").tag("Politics & Social")
                        }
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Suggest Motion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.btnNegative)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        viewModel.submitCustomMotion(
                            title: title,
                            category: category
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(
                        isFormValid ? Color.btnPositive : Color.gray
                    )
                    .disabled(!isFormValid || viewModel.isLoading)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SubmitMotionFormView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
}
