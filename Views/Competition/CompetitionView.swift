//
//  CompetitionView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct CompetitionView: View {
    @StateObject private var viewModel = CompetitionViewModel()
    @State private var isShowingUploadForm = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.competitions) { comp in
                            CompetitionCard(comp: comp)
                        }
                    }
                    .padding(24)
                }

                // FAB untuk akses Upload bagi Promotor
                Button(action: { isShowingUploadForm = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.btnPositive)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(24)
            }
            .navigationTitle("Competition Board")
            .sheet(isPresented: $isShowingUploadForm) {
                UploadCompetitionForm(viewModel: viewModel)
            }
            .onAppear { viewModel.fetchCompetitions() }
        }
    }
}

#Preview {
    CompetitionView()
}
