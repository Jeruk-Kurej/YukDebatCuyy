import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // 1. HEADER & USER STATS
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Rangkuman Progres")
                                .font(.headline)
                                .foregroundStyle(Color.accentWalnut)
                            
                            HStack(spacing: 16) {
                                StatCard(icon: "trophy.fill", value: "72%", label: "Win Rate", color: Color.btnPositive)
                                StatCard(icon: "person.2.fill", value: "14", label: "Sparring", color: Color.accentWalnut)
                                StatCard(icon: "text.book.closed.fill", value: "28", label: "Catatan", color: Color.btnNeutral)
                            }
                        }
                        
                        // 2. QUICK ACTIONS
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Aksi Cepat")
                                .font(.headline)
                                .foregroundStyle(Color.accentWalnut)
                            
                            HStack(spacing: 16) {
                                QuickActionButton(icon: "plus.circle.fill", title: "Buat Ruang\nSparring", color: Color.btnPositive)
                                QuickActionButton(icon: "sparkles", title: "Generate\nMosi Acak", color: Color.btnNeutral)
                            }
                        }
                        
                        // 3. UPCOMING HIGHLIGHT
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Lomba Terdekat")
                                .font(.headline)
                                .foregroundStyle(Color.accentWalnut)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                    Text("Dalam 7 Hari")
                                        .font(.caption.bold())
                                }
                                .foregroundStyle(Color.btnNegative)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.btnNegative.opacity(0.1))
                                .clipShape(Capsule())
                                
                                Text("National Debate Open 2026")
                                    .font(.system(.title3, design: .serif, weight: .bold))
                                    .foregroundStyle(Color.textCharcoal)
                                
                                Text("Ajang kompetisi debat British Parliamentary tingkat nasional. Siapkan tim terbaikmu.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.04), lineWidth: 1))
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Selamat Datang!")
        }
    }
}

// MARK: - Subkomponen Visual
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.textCharcoal)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: { /* Logika navigasi nanti */ }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.textCharcoal)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.04), lineWidth: 1))
        }
    }
}

#Preview {
    HomeView()
}
