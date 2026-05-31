//
//  CreateSparringFormView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A form view that allows users to create and schedule a new sparring room.
struct CreateSparringFormView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: SparringViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                Form {
                    Section(
                        header: Text("Motion & Schedule Details").font(
                            .caption.bold()
                        )
                    ) {
                        Picker(
                            "Topic Category *",
                            selection: $viewModel.formMotionCategory
                        ) {
                            Text("Law & Constitution").tag("Law & Constitution")
                            Text("Education").tag("Education")
                            Text("Economy & Business").tag("Economy & Business")
                            Text("Politics & Social").tag("Politics & Social")
                        }

                        DatePicker(
                            "Scheduled Time *",
                            selection: $viewModel.formScheduledTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "id_ID"))
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Meeting Information").font(
                            .caption.bold()
                        )
                    ) {
                        TextField(
                            "Zoom/Google Meet Link *",
                            text: $viewModel.formMeetingLink
                        )
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)

                        TextField(
                            "Additional Notes (Optional)",
                            text: $viewModel.formSpecialNotes
                        )

                        Toggle(
                            "Make Room Private",
                            isOn: $viewModel.formIsPrivate
                        )
                        .tint(Color.btnPositive)
                    }
                    .listRowBackground(Color.white)

                    Button(action: {
                        viewModel.submitRoomForm()
                        dismiss()
                    }) {
                        Text("Create Sparring Room")
                            .font(.headline)
                            .foregroundStyle(
                                viewModel.formMeetingLink.isEmpty
                                    ? Color.gray : .white
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(viewModel.formMeetingLink.isEmpty)
                    .listRowBackground(
                        viewModel.formMeetingLink.isEmpty
                            ? Color.gray.opacity(0.15) : Color.btnPositive
                    )
                }
                .scrollContentBackground(.hidden)
                .padding(.top, -20)
            }
            .navigationTitle("Create New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.btnNegative)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CreateSparringFormView(
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
