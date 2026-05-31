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
                        )
                        .tint(Color.btnPositive)
                    }
                    .listRowBackground(Color.white)

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
                .padding(.top, -20)  // PERBAIKAN UX: Jarak Navigation Title yang lebih compact
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
