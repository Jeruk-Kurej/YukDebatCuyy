//
//  ManageSparringRoomView.swift
//  YukDebatCuyy
//

import SwiftUI

/// A dedicated dashboard for the Host to manage a sparring room.
/// Facilitates accepting or rejecting pending join requests.
struct ManageSparringRoomView: View {

    // MARK: - Properties

    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                List {
                    Section(header: Text("Room Status").font(.caption.bold())) {
                        HStack {
                            Text("Current State")
                            Spacer()
                            Text(room.state.rawValue)
                                .font(.subheadline.bold())
                                .foregroundStyle(
                                    room.state == .ongoing
                                        ? Color.red : Color.btnPositive
                                )
                        }

                        if room.state == .preparing {
                            Button(action: {
                                viewModel.triggerStart(roomId: room.id)
                                dismiss()
                            }) {
                                Text("Start Sparring Session")
                                    .font(.headline)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .center
                                    )
                                    .foregroundStyle(
                                        room.participants.isEmpty
                                            ? Color.gray : Color.btnPositive
                                    )
                            }
                            .disabled(room.participants.isEmpty)
                        }
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Pending Requests").font(.caption.bold())
                    ) {
                        let pendingList =
                            viewModel.pendingRequests[room.id] ?? []

                        if pendingList.isEmpty {
                            Text("No pending requests.")
                                .foregroundStyle(.secondary)
                                .italic()
                        } else {
                            ForEach(pendingList) { participant in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("User ID: \(participant.userId)")
                                            .font(.subheadline.bold())
                                        Text(
                                            "Role: \(participant.roleSlot.rawValue) (\(participant.regMode.rawValue))"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button(action: {
                                        viewModel.rejectRequest(
                                            roomId: room.id,
                                            participantId: participant.userId
                                        )
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.btnNegative)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Button(action: {
                                        viewModel.acceptRequest(
                                            roomId: room.id,
                                            participantId: participant.userId
                                        )
                                    }) {
                                        Image(
                                            systemName: "checkmark.circle.fill"
                                        )
                                        .font(.title2)
                                        .foregroundStyle(Color.btnPositive)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.leading, 8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text(
                            "Active Participants (\(room.participants.count)/8)"
                        ).font(.caption.bold())
                    ) {
                        if room.participants.isEmpty {
                            Text("No one has joined yet.")
                                .foregroundStyle(.secondary)
                                .italic()
                        } else {
                            ForEach(room.participants) { participant in
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color.accentWalnut)
                                    Text(participant.userId)
                                    Spacer()
                                    Text(participant.roleSlot.rawValue)
                                        .font(.caption.bold())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Manage Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.textCharcoal)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ManageSparringRoomView(
        room: SparringRoomModel(
            id: "1",
            hostId: "u1",
            scheduledTime: Date(),
            motionCategory: "Test",
            specialNotes: "",
            meetingLink: "",
            accessType: .privateAccess,
            state: .preparing,
            participants: [],
            isAdjudicatorNeeded: false
        ),
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
