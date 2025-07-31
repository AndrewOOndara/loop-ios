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
            Color.green.ignoresSafeArea()

            VStack(spacing: 24) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)

                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    LoadingView()
}


