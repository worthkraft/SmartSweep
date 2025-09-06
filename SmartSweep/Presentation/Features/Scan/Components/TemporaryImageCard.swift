//
//  TemporaryImageCard.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 9/6/25.
//


import SwiftUI
import Photos

struct TemporaryImageCard: View {
    let image: SmartImage
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        VStack(spacing: 8) {
            thumbnailView
            
            VStack(spacing: 2) {
                Text("Temporary")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(formatFileSize(image.fileSize))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
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
            
            VStack {
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(8)
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(
            for: image.asset,
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
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}