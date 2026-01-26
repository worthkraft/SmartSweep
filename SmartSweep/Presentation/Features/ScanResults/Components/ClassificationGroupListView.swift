//
//  ClassificationGroupListView.swift
//  SmartSweep
//

import SwiftUI

struct ClassificationGroupListView: View {
    let groups: [ClassificationGroup]
    let classificationType: ImageClassificationType

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]

    var body: some View {
        if groups.isEmpty {
            emptyView
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(groups) { group in
                        ClassificationGroupCard(group: group)
                    }
                }
                .padding(16)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: classificationType.icon)
                .font(.system(size: 40))
                .foregroundColor(classificationType.color.opacity(0.5))

            Text("Tidak ada \(classificationType.displayName.lowercased())")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ClassificationGroupListView(
        groups: [],
        classificationType: .duplicate
    )
}
