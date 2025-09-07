//
//  HomeHeaderView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI
import Foundation

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            Text(AppConstants.Strings.appName)
                .font(AppConstants.Typography.titleBold)
                .foregroundColor(AppConstants.Colors.textPrimaryDark)
            
            Spacer()
            
            NavigationLink(value: NavigationDestination.settings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.textSecondaryDark)
            }
        }
        .padding(.horizontal, 40)
    }
}
