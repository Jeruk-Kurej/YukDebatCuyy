//
//  CreateSparringFormView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 27/05/26.
//

import SwiftUI

struct CreateSparringFormView: View {
    @ObservedObject var viewModel: SparringViewModel
    @Environment(\.dismiss) var dismiss

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
                            "Kategori Topik *",
                            selection: $viewModel.formMotionCategory
                        ) {
                            Text("Hukum & Konstitusi").tag("Hukum & Konstitusi")
                            Text("Pendidikan").tag("Pendidikan")
                            Text("Ekonomi & Bisnis").tag("Ekonomi & Bisnis")
                            Text("Politik & Sosial").tag("Politik & Sosial")
                        }

                        // REVISI 5: Menggunakan style kalender compact yang lebih estetik dan tidak aneh
                        DatePicker(
                            "Waktu Pelaksanaan *",
                            selection: $viewModel.formScheduledTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "id_ID"))
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Informasi Pertemuan").font(
                            .caption.bold()
                        )
                    ) {
                        // REVISI 11: Memberi tanda bintang (*)
                        TextField(
                            "Tautan Zoom/Google Meet *",
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

                    // REVISI 4: Button menjadi abu-abu dan tidak bisa diklik sampai Link diisi
                    Button(action: {
                        viewModel.submitRoomForm()
                        dismiss()
                    }) {
                        Text("Buat Ruang Sparring")
                            .font(.headline)
                            .foregroundStyle(
                                viewModel.formMeetingLink.isEmpty
                                    ? Color.gray : .white
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(viewModel.formMeetingLink.isEmpty)
                    .listRowBackground(
                        viewModel.formMeetingLink.isEmpty
                            ? Color.gray.opacity(0.15) : Color.btnPositive
                    )
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Buat Ruang Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
                }
            }
        }
    }
}

#Preview {
    CreateSparringFormView(
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
