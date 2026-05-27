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

// MARK: - Preview
#Preview {
    SparringView(
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
