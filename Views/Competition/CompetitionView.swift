import SwiftUI

struct CompetitionView: View {
    @StateObject private var viewModel = CompetitionViewModel()
    @State private var showUploadForm = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 1. LIST PENDING
                        if !viewModel.myPendingCompetitions.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Pending Admin Approval")
                                    .font(.headline)
                                    .foregroundStyle(Color.textCharcoal)
                                    .padding(.horizontal, 24)

                                ForEach(viewModel.myPendingCompetitions) {
                                    comp in
                                    CompetitionCard(comp: comp, isPending: true)
                                }
                            }
                        }

                        // 2. LIST ACTIVE
                        VStack(alignment: .leading) {
                            Text(
                                viewModel.activeCompetitions.isEmpty
                                    ? "No active competitions."
                                    : "Latest Competitions"
                            )
                            .font(.headline)
                            .foregroundStyle(Color.textCharcoal)
                            .padding(.horizontal, 24)

                            ForEach(viewModel.activeCompetitions) { comp in
                                CompetitionCard(comp: comp, isPending: false)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }

                // TOMBOL UPLOAD FLOATING
                Button(action: { showUploadForm = true }) {
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
            .navigationTitle("Competitions")
            .onAppear {
                viewModel.fetchCompetitions()
            }
            .sheet(isPresented: $showUploadForm) {
                UploadFormCompetition(viewModel: viewModel)
            }
            .modernToast(
                message: $viewModel.statusMsg,
                isError: viewModel.statusMsg?.contains("Failed") == true
                    || viewModel.statusMsg?.contains("Select") == true
            )
        }
    }
}
