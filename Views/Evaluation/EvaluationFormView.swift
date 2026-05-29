//
//  EvaluationFormView.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import SwiftUI

struct EvaluationFormView: View {
    @ObservedObject var motionViewModel: MotionArchiveViewModel
    let noteToEvaluate: CaseBuildingNoteModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var matterScore: Double = 75
    @State private var mannerScore: Double = 75
    @State private var methodScore: Double = 75
    @State private var feedbackText: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        Form {
            Section(header: Text("Argumen Debater").font(.caption.bold())) {
                Text(noteToEvaluate.argumentsRichText)
                    .font(.system(.body, design: .serif))
                    .padding(.vertical, 8)
            }
            .listRowBackground(Color.white)
            
            Section(header: Text("Rubrik Penilaian (1-100)").font(.caption.bold())) {
                VStack(alignment: .leading) {
                    Text("Matter (Isi & Logika): \(Int(matterScore))").font(.subheadline.bold())
                    Slider(value: $matterScore, in: 60...90, step: 1).tint(Color.btnPositive)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Manner (Gaya & Penyampaian): \(Int(mannerScore))").font(.subheadline.bold())
                    Slider(value: $mannerScore, in: 60...90, step: 1).tint(Color.accentWalnut)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Method (Struktur & Respons): \(Int(methodScore))").font(.subheadline.bold())
                    Slider(value: $methodScore, in: 60...90, step: 1).tint(Color.btnNeutral)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.white)
            
            Section(header: Text("Komentar Juri").font(.caption.bold())) {
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 120)
            }
            .listRowBackground(Color.white)
            
            Button(action: submitEvaluation) {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Kirim Hasil Evaluasi").fontWeight(.bold)
                    }
                    Spacer()
                }
                .foregroundStyle(.white)
            }
            .listRowBackground(feedbackText.isEmpty ? Color.gray : Color.btnPositive)
            .disabled(feedbackText.isEmpty || isSubmitting)
        }
        .scrollContentBackground(.hidden)
        .background(Color.bgCream)
        .navigationTitle("Evaluasi Kasus")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func submitEvaluation() {
        isSubmitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let index = motionViewModel.savedNotes.firstIndex(where: { $0.id == noteToEvaluate.id }) {
                motionViewModel.savedNotes[index].isFeedbackRequested = false
            }
            isSubmitting = false
            dismiss()
        }
    }
}
