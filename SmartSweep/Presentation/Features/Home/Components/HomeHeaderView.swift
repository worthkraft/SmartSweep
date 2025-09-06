//
//  HomeHeaderView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

struct HomeHeaderView: View {
    let onSettingsTapped: () -> Void
    
    var body: some View {
        HStack {
            Text(AppConstants.Strings.appName)
                .font(AppConstants.Typography.titleBold)
                .foregroundColor(AppConstants.Colors.textPrimaryDark)
            
            Spacer()
            
            Button(action: onSettingsTapped) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.textSecondaryDark)
            }
        }
        .padding(.horizontal, 40)
    }
}
