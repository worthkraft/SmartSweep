//
//  ClassificationGroupCard.swift
//  SmartSweep
//

import SwiftUI
import Photos

struct ClassificationGroupCard: View {
    let group: ClassificationGroup
    @State private var thumbnailImage: UIImage?

    var body: some View {
        VStack(spacing: 8) {
            thumbnailView

            VStack(spacing: 2) {
                Text(cardTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(cardSubtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    // MARK: - Computed Properties

    private var cardTitle: String {
        if group.classificationType.isGrouped {
            return "Grup \(group.classificationType.displayName)"
        } else {
            return group.classificationType.displayName
        }
    }

    private var cardSubtitle: String {
        if group.classificationType.isGrouped {
            return "\(group.count) file"
        } else {
            return formatFileSize(group.totalSize)
        }
    }

    // MARK: - Thumbnail View

    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .aspectRatio(1, contentMode: .fit)

            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }

            // Badge overlay
            badgeOverlay
        }
    }

    private var badgeOverlay: some View {
        VStack {
            HStack {
                Spacer()

                ZStack {
                    Circle()
                        .fill(group.classificationType.color)
                        .frame(width: badgeSize, height: badgeSize)

                    if group.classificationType.isGrouped {
                        Text("\(group.count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: group.classificationType.icon)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                }
            }
            Spacer()
        }
        .padding(8)
    }

    private var badgeSize: CGFloat {
        group.classificationType.isGrouped ? 24 : 20
    }

    // MARK: - Helpers

    private func loadThumbnail() {
        guard let firstImage = group.thumbnailImage else { return }

        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        manager.requestImage(
            for: firstImage.asset,
            targetSize: CGSize(width: 100, height: 100),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.thumbnailImage = image
            }
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

#Preview {
    ClassificationGroupCard(
        group: ClassificationGroup(
            classificationType: .duplicate,
            images: []
        )
    )
}
