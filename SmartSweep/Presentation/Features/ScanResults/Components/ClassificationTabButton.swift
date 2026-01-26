//
//  ClassificationTabButton.swift
//  SmartSweep
//

import SwiftUI

struct ClassificationTabButton: View {
    let type: ImageClassificationType
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: type.icon)
                        .font(.caption)
                        .foregroundColor(isSelected ? type.color : .secondary)

                    Text("\(type.displayName) (\(count))")
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? type.color : .secondary)
                }

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? type.color : Color.clear)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HStack {
        ClassificationTabButton(
            type: .duplicate,
            count: 5,
            isSelected: true,
            action: {}
        )
        ClassificationTabButton(
            type: .temporary,
            count: 3,
            isSelected: false,
            action: {}
        )
    }
    .padding()
}
