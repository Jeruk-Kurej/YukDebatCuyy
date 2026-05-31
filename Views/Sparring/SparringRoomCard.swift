//
//  SparringRoomCard.swift
//  YukDebatCuyy
//

import SwiftUI

/// Represents a visually distinct card displaying details of an individual sparring room.
struct SparringRoomCard: View {

    // MARK: - Properties

    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Section
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(
                            room.state == .ongoing
                                ? Color.red : Color.btnPositive
                        )
                        .frame(width: 8, height: 8)

                    Text(room.state.rawValue)
                        .font(.caption2.bold())
                        .foregroundStyle(Color.textCharcoal)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())

                Spacer()

                Text(
                    room.scheduledTime.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            // Content Section
            VStack(alignment: .leading, spacing: 4) {
                Text(room.motionCategory)
                    .font(.headline)
                    .foregroundStyle(Color.textCharcoal)

                Text(room.specialNotes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Divider()

            // Footer Section
            HStack {
                HStack(spacing: -8) {
                    ForEach(0..<min(room.participants.count, 3), id: \.self) {
                        _ in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }

                    if room.participants.count > 3 {
                        Circle()
                            .fill(Color.accentWalnut)
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .overlay(
                                Text("+\(room.participants.count - 3)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                }

                Text("\(room.participants.count)/8 Joined")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)

                Spacer()

                if viewModel.isUserInRoom(room: room) {
                    Text("Joined")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.btnPositive)
                } else if viewModel.isUserPending(room: room) {
                    Text("Pending")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                } else {
                    Button("Join") {
                        viewModel.requestJoin(
                            roomId: room.id,
                            role: .openingGovt,
                            isTeam: false
                        )
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.btnPositive)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
    }
}

// MARK: - Preview

#Preview {
    SparringRoomCard(
        room: SparringRoomModel(
            id: "room_public_1",
            hostId: "user_mario_123",
            scheduledTime: Date().addingTimeInterval(7200),
            motionCategory: "Education",
            specialNotes: "Standard BP practice.",
            meetingLink: "https://zoom.us/j/dummy",
            accessType: .publicAccess,
            state: .preparing,
            participants: [],
            isAdjudicatorNeeded: true
        ),
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
    .padding()
    .background(Color.bgCream)
}
