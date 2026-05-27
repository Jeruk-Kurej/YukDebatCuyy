//
//  ModetarionDashboardView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

import SwiftUI

struct ModerationDashboardView: View {
    @StateObject private var viewModel: ModerationDashboardViewModel
    
    init(viewModel: ModerationDashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Pending Competitions") {
                    ForEach(viewModel.pendingCompetitions) { comp in
                        HStack {
                            Text(comp.name)
                            Spacer()
                            Button("Approve") {
                                viewModel.approveContent(docId: comp.id)
                            }
                            .foregroundStyle(Color.btnPositive)
                        }
                    }
                }
            }
            .navigationTitle("Admin Moderation")
            .onAppear { viewModel.fetchPendingData() }
        }
    }
}

#Preview {
    ModerationDashboardView(viewModel: ModerationDashboardViewModel(
        dbService: MockFirestoreService(),
        storageService: MockCloudStorage()
    ))
}
