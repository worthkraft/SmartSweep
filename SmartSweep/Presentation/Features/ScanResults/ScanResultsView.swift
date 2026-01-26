//
//  ScanResultsView.swift
//  SmartSweep
//
//  Created by Smart Gallery Cleaner Team
//  Indonesian Smart Photo Organizer
//

import SwiftUI
import Photos

struct ScanResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var scanResult: ScanResult?

    @State private var selectedTab: ImageClassificationType?

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]

    // MARK: - Computed Properties

    /// Available classification types from scan result
    private var availableTypes: [ImageClassificationType] {
        guard let scanResult = scanResult else { return [] }
        return scanResult.availableClassificationTypes
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView

                if let scanResult = scanResult {
                    if !scanResult.hasCleanableItems {
                        CleanGalleryView()
                    } else {
                        dynamicResultTabsView(scanResult: scanResult)
                    }
                } else {
                    emptyStateView
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Select first available tab if none selected
                if selectedTab == nil, let first = availableTypes.first {
                    selectedTab = first
                }
            }
        }
    }

    // MARK: - Header View

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
                dynamicSummaryView(scanResult: scanResult)
            }
        }
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
    }

    // MARK: - Dynamic Summary View

    private func dynamicSummaryView(scanResult: ScanResult) -> some View {
        HStack(spacing: 20) {
            ForEach(availableTypes, id: \.self) { type in
                ClassificationSummaryItem(
                    type: type,
                    count: scanResult.imageCount(for: type),
                    savableSpace: scanResult.classificationResult.savableSpace(for: type)
                )
            }

            // Total savable space
            VStack {
                Text("\(estimatedSpaceMB(scanResult)) MB")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("Dapat Dibersihkan")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Dynamic Tabs View

    private func dynamicResultTabsView(scanResult: ScanResult) -> some View {
        VStack(spacing: 0) {
            // Dynamic tab selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(availableTypes, id: \.self) { type in
                        ClassificationTabButton(
                            type: type,
                            count: scanResult.count(for: type),
                            isSelected: selectedTab == type,
                            action: { selectedTab = type }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            // Dynamic content based on selected tab
            if let selectedType = selectedTab {
                let groups = scanResult.groups(for: selectedType)
                ClassificationGroupListView(
                    groups: groups,
                    classificationType: selectedType
                )
            } else {
                emptyStateView
            }
        }
    }

    // MARK: - Legacy Views (Backward Compatibility)

    private func resultTabsView(scanResult: ScanResult) -> some View {
        dynamicResultTabsView(scanResult: scanResult)
    }

    private func summaryView(scanResult: ScanResult) -> some View {
        dynamicSummaryView(scanResult: scanResult)
    }

    // MARK: - Empty State

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

    // MARK: - Helpers

    private func estimatedSpaceMB(_ scanResult: ScanResult) -> Int {
        let totalBytes = scanResult.classificationResult.totalSavableSpace
        return Int(totalBytes / 1024 / 1024)
    }
}

// MARK: - Legacy Card (Backward Compatibility)

struct DuplicateGroupCard: View {
    let group: DuplicateGroup
    @State private var thumbnailImage: UIImage?

    var body: some View {
        // Convert to ClassificationGroup and use new card
        let classificationGroup = ClassificationGroup.fromDuplicateGroup(group)
        ClassificationGroupCard(group: classificationGroup)
    }
}

#Preview {
    ScanResultsView(scanResult: .constant(nil))
}
