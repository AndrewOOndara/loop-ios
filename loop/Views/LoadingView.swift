//
//  LoadingView.swift
//  loop
//
//  Created by Andrew Ondara on 7/18/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()

            VStack(spacing: BrandSpacing.lg) {

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: BrandColor.orange))
                    .scaleEffect(1.5)

                Text("Loading...")
                    .font(BrandFont.headline)
                    .foregroundColor(BrandColor.lightBrown)
            }
        }
    }
}

#Preview {
    LoadingView()
}


