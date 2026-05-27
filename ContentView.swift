////
////  ContentView.swift
////  YukDebatCuyy
////
////  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    // Standardized Colors YukDebat
//    let bgCream = Color(red: 244 / 255, green: 241 / 255, blue: 234 / 255)
//    let textCharcoal = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
//    let btnPositive = Color(red: 58 / 255, green: 90 / 255, blue: 64 / 255)
//    let btnNeutral = Color(red: 43 / 255, green: 58 / 255, blue: 74 / 255)
//    let btnNegative = Color(red: 169 / 255, green: 74 / 255, blue: 74 / 255)
//    
//    // Elemen Estetika Tambahan: Sahabat Alami Latar Krem
//    let accentWalnut = Color(red: 92 / 255, green: 64 / 255, blue: 51 / 255)
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                bgCream.ignoresSafeArea()
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 32) {
//
//                        // SECTION 1: TYPOGRAPHY
//                        VStack(alignment: .leading, spacing: 16) {
//                            DesignHeader(title: "1. Typography Hierarchy")
//
//                            Group {
//                                TextSample(
//                                    label: "Large Title (34pt)",
//                                    sub: "New York Serif • Bold",
//                                    font: .system(
//                                        .largeTitle,
//                                        design: .serif,
//                                        weight: .bold
//                                    )
//                                )
//                                TextSample(
//                                    label: "Headline (17pt)",
//                                    sub: "SF Pro Sans • Semibold",
//                                    font: .headline
//                                )
//                                TextSample(
//                                    label: "Body Text (17pt)",
//                                    sub: "New York Serif • Regular",
//                                    font: .system(.body, design: .serif)
//                                )
//                                TextSample(
//                                    label: "Timer Monospaced",
//                                    sub: "SF Pro • Monospaced Digits",
//                                    font: .system(.title, design: .default)
//                                        .monospacedDigit()
//                                )
//                            }
//                        }
//
//                        // SECTION 2: COLOR PALETTE
//                        VStack(alignment: .leading, spacing: 16) {
//                            DesignHeader(title: "2. Color Palette")
//                            
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 12) {
//                                    ColorCircle(
//                                        color: bgCream,
//                                        name: "Background",
//                                        hex: "#F4F1EA"
//                                    )
//                                    ColorCircle(
//                                        color: btnPositive,
//                                        name: "Positive",
//                                        hex: "#3A5A40"
//                                    )
//                                    ColorCircle(
//                                        color: btnNeutral,
//                                        name: "Neutral",
//                                        hex: "#2B3A4A"
//                                    )
//                                    ColorCircle(
//                                        color: btnNegative,
//                                        name: "Negative",
//                                        hex: "#A94A4A"
//                                    )
//                                    ColorCircle(
//                                        color: accentWalnut,
//                                        name: "Walnut",
//                                        hex: "#5C4033"
//                                    )
//                                }
//                            }
//                        }
//
//                        // SECTION 3: INTERACTIVE COMPONENTS
//                        VStack(alignment: .leading, spacing: 16) {
//                            DesignHeader(title: "3. Button Standards")
//
//                            VStack(spacing: 12) {
//                                AppButton(
//                                    title: "Join Sparring Session",
//                                    color: btnPositive,
//                                    icon: "person.2.fill"
//                                )
//                                AppButton(
//                                    title: "Explore Motion Database",
//                                    color: btnNeutral,
//                                    icon: "magnifyingglass"
//                                )
//                                AppButton(
//                                    title: "Discard Draft",
//                                    color: btnNegative,
//                                    icon: "trash.fill"
//                                )
//                            }
//                        }
//                        
//                        // SECTION 4: SECONDARY ACCENT SHOWCASE
//                        VStack(alignment: .leading, spacing: 16) {
//                            DesignHeader(title: "4. Secondary Accent Usage")
//                            
//                            // Demonstrasi Elemen Walnut Brown yang Sangat Mewah
//                            HStack(spacing: 10) {
//                                Image(systemName: "building.columns.fill")
//                                    .foregroundStyle(accentWalnut)
//                                
//                                Text("Kategori: Hukum & Konstitusi")
//                                    .font(.caption.bold())
//                                    .foregroundStyle(accentWalnut)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.right")
//                                    .font(.caption.bold())
//                                    .foregroundStyle(accentWalnut.opacity(0.5))
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 12)
//                            .background(accentWalnut.opacity(0.08))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(accentWalnut.opacity(0.2), lineWidth: 1)
//                            )
//                        }
//                    }
//                    .padding(24)
//                }
//            }
//            .navigationTitle("YukDebat Design System")
//        }
//    }
//}
//
//// Sub-components for Gallery
//struct DesignHeader: View {
//    let title: String
//    var body: some View {
//        Text(title)
//            .font(.caption.bold())
//            .foregroundStyle(.secondary)
//            .textCase(.uppercase)
//    }
//}
//
//struct TextSample: View {
//    let label: String
//    let sub: String
//    let font: Font
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(label).font(font)
//            Text(sub).font(.caption2).foregroundStyle(.secondary)
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//struct ColorCircle: View {
//    let color: Color
//    let name: String
//    let hex: String
//    var body: some View {
//        VStack {
//            Circle()
//                .fill(color)
//                .frame(width: 60, height: 60)
//                .overlay(
//                    Circle().stroke(Color.black.opacity(0.1))
//                )
//            Text(name).font(.system(size: 10, weight: .bold))
//            Text(hex).font(.system(size: 8)).foregroundStyle(.secondary)
//        }
//    }
//}
//
//struct AppButton: View {
//    let title: String
//    let color: Color
//    let icon: String
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//            Text(title)
//        }
//        .font(.headline)
//        .foregroundStyle(.white)
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(color)
//        .clipShape(RoundedRectangle(cornerRadius: 14))
//    }
//}
//
//#Preview {
//    ContentView()
//}
