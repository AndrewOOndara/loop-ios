//
//  MemoryCardView.swift
//  loop
//
//  Created by Andrew Ondara on 7/20/25.
//

import SwiftUI

enum MediaType {
    case video, photo, audio
}

struct MemoryCardView: View {
    var mediaType: MediaType
    var userName: String
    var caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(userName)
                .fontWeight(.semibold)

            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 300)
                .overlay(
                    Group {
                        if mediaType == .video {
                            Image(systemName: "play.circle.fill")
                        } else if mediaType == .photo {
                            Image(systemName: "photo")
                        } else if mediaType == .audio {
                            Image(systemName: "waveform")
                        }
                    }
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )

            Text(caption)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
