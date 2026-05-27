import SwiftUI

/// Renders the Sparring Lobby UI (UC02).
/// Displays dynamic match options and clean contextual separation for accessibility states.
struct SparringView: View {

    @ObservedObject var viewModel: SparringViewModel

    init(viewModel: SparringViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                // HAPUS BLOK if let error = viewModel.errorMessage YANG LAMA DI SINI

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        if viewModel.lobbyRooms.isEmpty {
                            Text("Belum ada ruang sparring.")
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(
                                    Color.textCharcoal.opacity(0.6)
                                )
                                .multilineTextAlignment(.center)
                                .padding(.top, 60)
                        }

                        ForEach(viewModel.lobbyRooms) { room in
                            SparringRoomCard(room: room, viewModel: viewModel)
                        }
                    }
                    .padding(24)
                }

                // Floating Action Button (FAB)
                Button(action: { viewModel.isShowingCreateRoom = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.btnPositive)
                        .clipShape(Circle())
                        .shadow(
                            color: Color.btnPositive.opacity(0.4),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
                .padding(24)
            }
            .navigationTitle("Sparring Lobby")
            .onAppear { viewModel.listenToRoom(roomId: "default_room") }
            .sheet(isPresented: $viewModel.isShowingCreateRoom) {
                CreateSparringFormView(viewModel: viewModel)
            }
            // PASANG TOAST DI SINI (Memantau ViewModel secara reaktif)
            .modernToast(message: $viewModel.errorMessage, isError: true)
            .modernToast(message: $viewModel.alertMessage, isError: false)
        }
    }
}

struct SparringRoomCard: View {
    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel
    
    var body: some View {
        let isHost = viewModel.isUserHost(room: room)
        let isJoined = viewModel.isUserInRoom(room: room)
        let isPending = viewModel.isUserPending(room: room)
        let isFull = room.participants.count >= 8
        
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                HStack(spacing: 6) { Image(systemName: "building.columns.fill"); Text(room.motionCategory.uppercased()) }
                .font(.system(size: 11, weight: .bold)).foregroundStyle(Color.accentWalnut).padding(8).background(Color.accentWalnut.opacity(0.08)).clipShape(Capsule())
                
                HStack(spacing: 4) { Image(systemName: room.accessType == .privateAccess ? "lock.fill" : "globe"); Text(room.accessType == .privateAccess ? "PRIVAT" : "PUBLIK") }
                .font(.system(size: 10, weight: .black)).foregroundStyle(room.accessType == .privateAccess ? Color.btnNegative : Color.btnPositive).padding(8).background(room.accessType == .privateAccess ? Color.btnNegative.opacity(0.08) : Color.btnPositive.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 6))
                
                Spacer()
                Text(room.state == .ongoing ? "• BERLANGSUNG" : "\(room.participants.count)/8 Slot").font(.system(size: 11, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isHost ? "Anda (Host)" : "Host: \(room.hostId)").font(.system(.title3, design: .serif, weight: .bold))
                HStack(spacing: 6) { Image(systemName: "calendar.badge.clock"); Text(room.scheduledTime.formatted(date: .abbreviated, time: .shortened)) }.font(.subheadline.bold()).foregroundStyle(Color.btnPositive)
            }
            
            if room.state == .ongoing {
                Link("Masuk Ruang Virtual", destination: URL(string: room.meetingLink) ?? URL(string: "https://zoom.us")!).font(.subheadline.bold()).foregroundStyle(.white).frame(maxWidth: .infinity).padding(12).background(Color.btnPositive).clipShape(RoundedRectangle(cornerRadius: 11))
            } else if isHost {
                Button("Mulai Sesi Sparring") { viewModel.triggerStart(roomId: room.id) }.font(.subheadline.bold()).foregroundStyle(.white).frame(maxWidth: .infinity).padding(12).background(Color.btnPositive).clipShape(RoundedRectangle(cornerRadius: 11))
            } else if isJoined {
                VStack(spacing: 8) {
                    Text("Sudah Bergabung").font(.subheadline.bold()).foregroundStyle(Color.btnPositive).frame(maxWidth: .infinity).padding(12).background(Color.btnPositive.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 11))
                    Button("Keluar dari Ruangan") { viewModel.leaveRoom(roomId: room.id) }.font(.caption.bold()).foregroundStyle(Color.btnNegative)
                }
            } else if isPending {
                Text("Menunggu Persetujuan Host...").font(.subheadline.bold()).foregroundStyle(Color.accentWalnut).frame(maxWidth: .infinity).padding(12).background(Color.accentWalnut.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 11))
            } else {
                HStack(spacing: 12) {
                    Button("Join as Solo") { viewModel.requestJoin(roomId: room.id, role: .openingGovt, isTeam: false) }.font(.subheadline.bold()).foregroundStyle(.white).frame(maxWidth: .infinity).padding(12).background(Color.btnNeutral).clipShape(RoundedRectangle(cornerRadius: 11))
                    Button("Join as Team") { viewModel.requestJoin(roomId: room.id, role: .openingGovt, isTeam: true) }.font(.subheadline.bold()).foregroundStyle(Color.btnNeutral).frame(maxWidth: .infinity).padding(12).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 11)).overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.btnNeutral, lineWidth: 1))
                }
            }
        }.padding(20).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.04), lineWidth: 1)).shadow(radius: 5)
    }
}

// MARK: - Subcomponent: Modal Form Create Room (Tetap Sama)
struct CreateSparringFormView: View {
    @ObservedObject var viewModel: SparringViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                Form {
                    Section(
                        header: Text("Detail Mosi & Jadwal").font(
                            .caption.bold()
                        )
                    ) {
                        Picker(
                            "Kategori Topik",
                            selection: $viewModel.formMotionCategory
                        ) {
                            Text("Hukum & Konstitusi").tag("Hukum & Konstitusi")
                            Text("Pendidikan").tag("Pendidikan")
                            Text("Ekonomi & Bisnis").tag("Ekonomi & Bisnis")
                            Text("Politik & Sosial").tag("Politik & Sosial")
                        }
                        DatePicker(
                            "Waktu Pelaksanaan",
                            selection: $viewModel.formScheduledTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Informasi Pertemuan").font(
                            .caption.bold()
                        )
                    ) {
                        TextField(
                            "Tautan Zoom/Google Meet",
                            text: $viewModel.formMeetingLink
                        )
                        .keyboardType(.URL).textInputAutocapitalization(.never)
                        TextField(
                            "Catatan Tambahan (Khusus)",
                            text: $viewModel.formSpecialNotes
                        )
                        Toggle(
                            "Buat Ruangan Privat",
                            isOn: $viewModel.formIsPrivate
                        ).tint(Color.btnPositive)
                    }
                    .listRowBackground(Color.white)

                    Button(action: { viewModel.submitRoomForm() }) {
                        Text("Buat Ruang Sparring").font(.headline)
                            .foregroundStyle(.white).frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                    }
                    .listRowBackground(Color.btnPositive)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Buat Ruang Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { viewModel.isShowingCreateRoom = false }
                        .foregroundStyle(Color.btnNegative)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SparringView(
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
