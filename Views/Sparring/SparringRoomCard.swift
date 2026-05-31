//
//  SparringRoomCard.swift
//  YukDebatCuyy
//

import SwiftUI

/// Represents a visually distinct card displaying details of an individual sparring room.
/// Extracted into sub-components to prevent SwiftUI compiler type-check timeouts.
struct SparringRoomCard: View {
    
    // MARK: - Properties
    
    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel
    
    @State private var showManageSheet = false
    @State private var showJoinOptions = false
    @State private var showLeaveAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            contentSection
            Divider()
            footerSection
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        .sheet(isPresented: $showManageSheet) {
            ManageSparringRoomView(room: room, viewModel: viewModel)
        }
        .confirmationDialog("Join Sparring Room", isPresented: $showJoinOptions, titleVisibility: .visible) {
            // FIX: Using .openingGovt instead of the non-existent .none
            Button("Join as Solo") {
                viewModel.requestJoin(roomId: room.id, role: .openingGovt, isTeam: false)
            }
            Button("Join as Team (2 Persons)") {
                viewModel.requestJoin(roomId: room.id, role: .openingGovt, isTeam: true)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("How would you like to register for this session?")
        }
        .alert("Leave Room", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                // TODO: Ensure leaveRoom method is implemented in SparringViewModel
                // viewModel.leaveRoom(roomId: room.id)
            }
        } message: {
            Text("Are you sure you want to leave this sparring session?")
        }
    }
    
    // MARK: - UI Sub-Components
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(room.state == .ongoing ? Color.red : Color.btnPositive)
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
            
            Text(room.scheduledTime.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(room.motionCategory)
                    .font(.headline)
                    .foregroundStyle(Color.textCharcoal)
                
                if room.accessType == .privateAccess {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(Color.btnNegative)
                }
            }
            
            Text(room.specialNotes)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
    
    private var footerSection: some View {
        HStack {
            HStack(spacing: -8) {
                ForEach(0..<min(room.participants.count, 3), id: \.self) { _ in
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
            
            actionButton
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        if viewModel.isUserHost(room: room) {
            Button("Manage") {
                showManageSheet = true
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentWalnut)
            .clipShape(Capsule())
        } else if viewModel.isUserInRoom(room: room) {
            Button("Leave") {
                showLeaveAlert = true
            }
            .font(.subheadline.bold())
            .foregroundStyle(Color.btnNegative)
        } else if viewModel.isUserPending(room: room) {
            Text("Pending")
                .font(.subheadline.bold())
                .foregroundStyle(.orange)
        } else {
            Button(room.accessType == .privateAccess ? "Request" : "Join") {
                showJoinOptions = true
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

// MARK: - Preview

#Preview {
    SparringRoomCard(
        room: SparringRoomModel(
            id: "room_public_1", hostId: "user_mario_123", scheduledTime: Date().addingTimeInterval(7200),
            motionCategory: "Education", specialNotes: "Standard BP practice.",
            meetingLink: "https://zoom.us/j/dummy", accessType: .publicAccess, state: .preparing,
            participants: [], isAdjudicatorNeeded: true
        ),
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
    .padding()
    .background(Color.bgCream)
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
