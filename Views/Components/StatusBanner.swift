import SwiftUI

struct StatusBanner: View {
    let message: String
    let isError: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.icloud.fill")
                .foregroundStyle(isError ? Color.btnNegative : Color.accentWalnut)
            Text(message)
                .font(.caption.bold())
                .foregroundStyle(isError ? Color.btnNegative : Color.accentWalnut)
            Spacer()
        }
        .padding()
        .background(isError ? Color.btnNegative.opacity(0.1) : Color.accentWalnut.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isError ? Color.btnNegative.opacity(0.3) : Color.accentWalnut.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    StatusBanner(message: "invalid data", isError: true).padding()
}
