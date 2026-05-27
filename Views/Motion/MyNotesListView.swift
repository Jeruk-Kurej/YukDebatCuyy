import SwiftUI

struct MyNotesListView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @State private var noteToEdit: CaseBuildingNoteModel?

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredNotes) { note in
                    // Card yang bentuknya sama persis dengan Explore
                    Button(action: { noteToEdit = note }) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(
                                        systemName: note.visibility
                                            == .privateAccess
                                            ? "lock.fill" : "globe"
                                    )
                                    Text(
                                        note.visibility == .privateAccess
                                            ? "PRIVAT" : "PUBLIK"
                                    )
                                }
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(
                                    note.visibility == .privateAccess
                                        ? Color.btnNegative : Color.btnPositive
                                )
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(
                                    note.visibility == .privateAccess
                                        ? Color.btnNegative.opacity(0.08)
                                        : Color.btnPositive.opacity(0.08)
                                )
                                .clipShape(Capsule())

                                Spacer()

                                Text(
                                    note.updatedAt.formatted(
                                        date: .numeric,
                                        time: .omitted
                                    )
                                )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }

                            Text(note.motionTitle)
                                .font(
                                    .system(
                                        .headline,
                                        design: .serif,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(Color.textCharcoal)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14).stroke(
                                Color.black.opacity(0.04),
                                lineWidth: 1
                            )
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
        }
        .sheet(item: $noteToEdit) { note in
            NavigationStack {
                NoteEditorView(viewModel: viewModel, draftNote: note)
            }
        }
    }
}
