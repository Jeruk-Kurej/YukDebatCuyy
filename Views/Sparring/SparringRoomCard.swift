//
//  SparringRoomCard.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct SparringRoomCard: View {
    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel

    // State khusus untuk menahan aksi accidental (Revisi 1 & 7)
    @State private var showLeaveAlert = false
    @State private var showStartAlert = false

    var body: some View {
        let isHost = viewModel.isUserHost(room: room)
        let isJoined = viewModel.isUserInRoom(room: room)
        let isPending = viewModel.isUserPending(room: room)

        VStack(alignment: .leading, spacing: 0) {  // Spacing 0 agar pita warna menempel di atas

            // REVISI 3: Pita warna di atas kartu untuk membedakan Privasi secara cepat
            Rectangle()
                .fill(
                    room.accessType == .privateAccess
                        ? Color.btnNegative : Color.btnPositive
                )
                .frame(height: 6)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "building.columns.fill")
                        Text(room.motionCategory.uppercased())
                    }
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(
                        Color.accentWalnut
                    ).padding(8).background(Color.accentWalnut.opacity(0.08))
                    .clipShape(Capsule())

                    HStack(spacing: 4) {
                        Image(
                            systemName: room.accessType == .privateAccess
                                ? "lock.fill" : "globe"
                        )
                        Text(
                            room.accessType == .privateAccess
                                ? "PRIVAT" : "PUBLIK"
                        )
                    }
                    .font(.system(size: 10, weight: .black)).foregroundStyle(
                        room.accessType == .privateAccess
                            ? Color.btnNegative : Color.btnPositive
                    ).padding(8).background(
                        room.accessType == .privateAccess
                            ? Color.btnNegative.opacity(0.08)
                            : Color.btnPositive.opacity(0.08)
                    ).clipShape(RoundedRectangle(cornerRadius: 6))

                    Spacer()
                    // REVISI 2: Slot selalu ditampilkan meskipun user sudah bergabung
                    Text(
                        room.state == .ongoing
                            ? "• BERLANGSUNG"
                            : "\(room.participants.count)/8 Slot"
                    )
                    .font(.system(size: 11, weight: .bold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isHost ? "Anda (Host)" : "Host: \(room.hostId)").font(
                        .system(.title3, design: .serif, weight: .bold)
                    )
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                        Text(
                            room.scheduledTime.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                    }.font(.subheadline.bold()).foregroundStyle(
                        Color.btnPositive
                    )
                }

                if room.state == .ongoing {
                    Link(
                        "Masuk Ruang Virtual",
                        destination: URL(string: room.meetingLink) ?? URL(
                            string: "https://zoom.us"
                        )!
                    ).font(.subheadline.bold()).foregroundStyle(.white).frame(
                        maxWidth: .infinity
                    ).padding(12).background(Color.btnPositive).clipShape(
                        RoundedRectangle(cornerRadius: 11)
                    )
                } else if isHost {
                    // REVISI 7: Warning jika slot kurang dari 2
                    Button("Mulai Sesi Sparring") {
                        if room.participants.count < 2 {
                            showStartAlert = true
                        } else {
                            viewModel.triggerStart(roomId: room.id)
                        }
                    }
                    .font(.subheadline.bold()).foregroundStyle(.white).frame(
                        maxWidth: .infinity
                    ).padding(12).background(Color.btnPositive).clipShape(
                        RoundedRectangle(cornerRadius: 11)
                    )
                    .alert("Peserta Masih Kosong", isPresented: $showStartAlert)
                    {
                        Button("Tunggu Dulu", role: .cancel) {}
                        Button("Tetap Mulai", role: .destructive) {
                            viewModel.triggerStart(roomId: room.id)
                        }
                    } message: {
                        Text(
                            "Belum ada peserta yang bergabung. Yakin ingin memulai sesi sekarang?"
                        )
                    }

                } else if isJoined {
                    HStack(spacing: 12) {
                        Text("Sudah Bergabung").font(.subheadline.bold())
                            .foregroundStyle(Color.btnPositive).frame(
                                maxWidth: .infinity
                            ).padding(12).background(
                                Color.btnPositive.opacity(0.1)
                            ).clipShape(RoundedRectangle(cornerRadius: 11))

                        // REVISI 1: Tombol merah icon keluar + Alert Konfirmasi
                        Button(action: { showLeaveAlert = true }) {
                            Image(
                                systemName: "rectangle.portrait.and.arrow.right"
                            )
                            .font(.headline).foregroundStyle(.white).padding(12)
                            .background(Color.btnNegative).clipShape(
                                RoundedRectangle(cornerRadius: 11)
                            )
                        }
                        .alert("Keluar Ruangan", isPresented: $showLeaveAlert) {
                            Button("Batal", role: .cancel) {}
                            Button("Keluar", role: .destructive) {
                                viewModel.leaveRoom(roomId: room.id)
                            }
                        } message: {
                            Text(
                                "Apakah Anda yakin ingin membatalkan pendaftaran dan keluar dari ruang sparring ini?"
                            )
                        }
                    }
                } else if isPending {
                    Text("Menunggu Persetujuan Host...").font(
                        .subheadline.bold()
                    ).foregroundStyle(Color.accentWalnut).frame(
                        maxWidth: .infinity
                    ).padding(12).background(Color.accentWalnut.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                } else {
                    HStack(spacing: 12) {
                        Button("Join as Solo") {
                            viewModel.requestJoin(
                                roomId: room.id,
                                role: .openingGovt,
                                isTeam: false
                            )
                        }.font(.subheadline.bold()).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(12).background(
                                Color.btnNeutral
                            ).clipShape(RoundedRectangle(cornerRadius: 11))
                        Button("Join as Team") {
                            viewModel.requestJoin(
                                roomId: room.id,
                                role: .openingGovt,
                                isTeam: true
                            )
                        }.font(.subheadline.bold()).foregroundStyle(
                            Color.btnNeutral
                        ).frame(maxWidth: .infinity).padding(12).background(
                            Color.white
                        ).clipShape(RoundedRectangle(cornerRadius: 11)).overlay(
                            RoundedRectangle(cornerRadius: 11).stroke(
                                Color.btnNeutral,
                                lineWidth: 1
                            )
                        )
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18).stroke(
                Color.black.opacity(0.04),
                lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SparringRoomCard(
        room: SparringRoomModel(
            id: "1",
            hostId: "Mario",
            scheduledTime: Date(),
            motionCategory: "Pendidikan",
            specialNotes: "Latihan",
            needAdjudicator: true,
            meetingLink: "",
            accessType: .publicAccess,
            state: .preparing,
            participants: []
        ),
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
    .padding()
    .background(Color.bgCream)
}
