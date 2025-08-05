//
//  ScanResultsView.swift
//  SmartSweep
//
//  Created by Smart Gallery Cleaner Team
//  Indonesian Smart Photo Organizer
//

import SwiftUI
import Photos
import SmartSweepCore
import SmartSweepDomain

struct ScanResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var scanResult: ScanResult?
    
    @State private var selectedTab = 0
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                
                if let scanResult = scanResult {
                    if scanResult.duplicateGroups.isEmpty && scanResult.temporaryImages.isEmpty {
                        cleanGalleryView
                    } else {
                        resultTabsView(scanResult: scanResult)
                    }
                } else {
                    emptyStateView
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Hasil Scan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Placeholder for balance
                Color.clear
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if let scanResult = scanResult {
                summaryView(scanResult: scanResult)
            }
        }
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
    }
    
    private func summaryView(scanResult: ScanResult) -> some View {
        HStack(spacing: 20) {
            summaryItem(
                count: "\(duplicateCount(scanResult))",
                label: "Duplikat",
                color: .red
            )
            
            summaryItem(
                count: "\(scanResult.temporaryImages.count)",
                label: "Temporary",
                color: .orange
            )
            
            summaryItem(
                count: "\(estimatedSpaceMB(scanResult)) MB",
                label: "Dapat Dibersihkan",
                color: .green
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func summaryItem(count: String, label: String, color: Color) -> some View {
        VStack {
            Text(count)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func resultTabsView(scanResult: ScanResult) -> some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                tabButton(
                    title: "Duplikat (\(duplicateCount(scanResult)))",
                    isSelected: selectedTab == 0,
                    tag: 0
                )
                
                tabButton(
                    title: "Temporary (\(scanResult.temporaryImages.count))",
                    isSelected: selectedTab == 1,
                    tag: 1
                )
            }
            .padding(.horizontal, 20)
            
            // Content
            TabView(selection: $selectedTab) {
                duplicatesGridView(scanResult: scanResult)
                    .tag(0)
                
                temporaryImagesGridView(scanResult: scanResult)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    private func tabButton(title: String, isSelected: Bool, tag: Int) -> some View {
        Button {
            selectedTab = tag
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? Color.blue : Color.clear)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func duplicatesGridView(scanResult: ScanResult) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(scanResult.duplicateGroups.indices, id: \.self) { groupIndex in
                    let group = scanResult.duplicateGroups[groupIndex]
                    DuplicateGroupCard(group: group)
                }
            }
            .padding(16)
        }
    }
    
    private func temporaryImagesGridView(scanResult: ScanResult) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(scanResult.temporaryImages.indices, id: \.self) { imageIndex in
                    let image = scanResult.temporaryImages[imageIndex]
                    TemporaryImageCard(image: image)
                }
            }
            .padding(16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Tidak ada hasil scan")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Lakukan scan untuk melihat duplikat dan file temporary")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var cleanGalleryView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Galeri Bersih!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Tidak ada duplikat atau file temporary yang ditemukan")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    VStack {
                        Image(systemName: "doc.on.doc")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("0 Duplikat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("0 Temporary")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Galeri Optimal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func duplicateCount(_ scanResult: ScanResult) -> Int {
        return scanResult.duplicateGroups.reduce(0) { total, group in
            total + group.images.count
        }
    }
    
    private func estimatedSpaceMB(_ scanResult: ScanResult) -> Int {
        let duplicatesSpace = scanResult.duplicateGroups.reduce(0) { total, group in
            total + group.images.reduce(0) { sum, image in
                sum + image.fileSize
            }
        }
        
        let temporarySpace = scanResult.temporaryImages.reduce(0) { total, image in
            total + image.fileSize
        }
        
        return Int((duplicatesSpace + temporarySpace) / 1024 / 1024)
    }
}

struct DuplicateGroupCard: View {
    let group: DuplicateGroup
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        VStack(spacing: 8) {
            thumbnailView
            
            VStack(spacing: 2) {
                Text("Grup Duplikat")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(group.images.count) file")
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
                            .fill(Color.red)
                            .frame(width: 24, height: 24)
                        
                        Text("\(group.images.count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(8)
        }
    }
    
    private func loadThumbnail() {
        guard !group.images.isEmpty else { return }
        
        let firstImage = group.images[0]
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
}

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

#Preview {
    ScanResultsView(scanResult: .constant(nil))
}
