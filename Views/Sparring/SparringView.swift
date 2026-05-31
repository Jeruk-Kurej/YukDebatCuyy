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
                    // PERBAIKAN HIG: Jarak atas compact, dan jarak bawah aman dari Tab Bar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }

                // Floating Action Button (FAB)
                Button(action: { viewModel.isShowingCreateRoom = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.btnPositive)
                        .clipShape(Circle())
                        // PERBAIKAN STYLE: Shadow konsisten dan elegan
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                // PERBAIKAN PLACEMENT: Konsisten di semua page
                .padding(.trailing, 24)
                .padding(.bottom, 110)
            }
            .navigationTitle("Sparring Lobby")
            .onAppear { viewModel.listenToRoom(roomId: "default_room") }
            .sheet(isPresented: $viewModel.isShowingCreateRoom) {
                CreateSparringFormView(viewModel: viewModel)
            }
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
