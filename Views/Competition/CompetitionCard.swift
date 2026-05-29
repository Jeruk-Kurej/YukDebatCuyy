import SwiftUI

struct CompetitionCard: View {
    let comp: CompetitionModel
    let isPending: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // BAGIAN GAMBAR POSTER (Mendukung URL Dummy dan Base64 Teks)
            if !comp.posterStorageUrl.isEmpty {
                if comp.posterStorageUrl.starts(with: "http") {
                    AsyncImage(url: URL(string: comp.posterStorageUrl)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.2)).overlay(ProgressView())
                    }
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                // DECODER BASE64 (Mengubah Teks jadi Gambar)
                } else if let imageData = Data(base64Encoded: comp.posterStorageUrl, options: .ignoreUnknownCharacters),
                          let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
            }
            
            // BAGIAN TEKS INFORMASI
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(comp.name)
                        .font(.title3.bold())
                        .foregroundStyle(Color.textCharcoal)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // BADGE PENDING
                    if isPending {
                        Text("PENDING")
                            .font(.caption.bold())
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .foregroundStyle(Color.orange)
                            .clipShape(Capsule())
                    }
                }
                
                Text(comp.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .padding(.horizontal, 24)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
