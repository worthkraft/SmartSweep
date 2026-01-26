//
//  CleanGalleryView.swift
//  SmartSweep
//

import SwiftUI

struct CleanGalleryView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)

                Text("Galeri Bersih!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Tidak ada duplikat atau file yang perlu dibersihkan")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            CleanGalleryStatsView()

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Stats view showing classification summary when gallery is clean
struct CleanGalleryStatsView: View {
    var body: some View {
        HStack(spacing: 16) {
            statItem(
                icon: "doc.on.doc",
                count: "0",
                label: "Duplikat",
                color: .blue
            )

            statItem(
                icon: "clock",
                count: "0",
                label: "Temporary",
                color: .orange
            )

            statItem(
                icon: "leaf.fill",
                count: "",
                label: "Galeri Optimal",
                color: .green
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func statItem(icon: String, count: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            if !count.isEmpty {
                Text(count)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

/// Summary item for a classification type
struct ClassificationSummaryItem: View {
    let type: ImageClassificationType
    let count: Int
    let savableSpace: Int64

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(type.color)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(type.color)

            Text(type.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview("Clean Gallery") {
    CleanGalleryView()
}

#Preview("Summary Item") {
    HStack(spacing: 20) {
        ClassificationSummaryItem(type: .duplicate, count: 5, savableSpace: 1024 * 1024 * 10)
        ClassificationSummaryItem(type: .temporary, count: 3, savableSpace: 1024 * 1024 * 5)
    }
    .padding()
}
