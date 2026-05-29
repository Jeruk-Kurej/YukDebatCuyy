//
//  AdjudicatorDashboardView.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import SwiftUI

struct AdjudicatorDashboardView: View {
    @ObservedObject var motionViewModel: MotionArchiveViewModel
    
    var pendingEvaluations: [CaseBuildingNoteModel] {
        motionViewModel.savedNotes.filter { $0.visibility == .publicAccess && $0.isFeedbackRequested }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                if pendingEvaluations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.gray.opacity(0.3))
                        Text("Antrean Kosong")
                            .font(.headline)
                        Text("Belum ada Debater yang meminta evaluasi argumen saat ini.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                } else {
                    List {
                        ForEach(pendingEvaluations) { note in
                            NavigationLink(destination: EvaluationFormView(motionViewModel: motionViewModel, noteToEvaluate: note)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "exclamationmark.circle.fill")
                                        Text("MENUNGGU PENILAIAN")
                                    }
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(Color.accentWalnut)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.accentWalnut.opacity(0.1))
                                    .clipShape(Capsule())
                                    
                                    Text(note.motionTitle)
                                        .font(.system(.headline, design: .serif, weight: .bold))
                                        .lineLimit(2)
                                    
                                    Text("Dikirim pada: \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Dashboard Juri")
        }
    }
}
