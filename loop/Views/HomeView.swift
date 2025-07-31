//
//  HomeView.swift
//  loop
//
//  Created by Andrew Ondara on 7/20/25.
//


import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation with post button
            HStack {
                Spacer()
                Button(action: {
                    // Handle post action
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Loop section
                    LoopSection()
                    
                    // Weekend Crew section
                    WeekendCrewSection()
                    
                    // Beach Trip section
                    BeachTripSection()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
    }
}

struct LoopSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Loop")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Weekend Crew")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Yesterday")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Collage grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                CollageItem(type: .photo, image: "person1")
                CollageItem(type: .photo, image: "dog")
                CollageItem(type: .photo, image: "couple")
                CollageItem(type: .audio, duration: "0:12")
                CollageItem(type: .photo, image: "person2")
                CollageItem(type: .photo, image: "person3")
                CollageItem(type: .photo, image: "person4")
                CollageItem(type: .photo, image: "person5")
            }
            
            // Navigation to Brunch Trip
            NavigationLink(destination: Text("Brunch Trip")) {
                HStack {
                    Text("Brunch Trip")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
    }
}

struct WeekendCrewSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekend Crew")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Main collage grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                CollageItem(type: .photo, image: "person1")
                CollageItem(type: .emoji)
                CollageItem(type: .photo, image: "couple")
                CollageItem(type: .audio, duration: "0:12")
                CollageItem(type: .photo, image: "person2")
                CollageItem(type: .text, text: "Let's go to the beach!")
                CollageItem(type: .photo, image: "shoes")
                EmptyCollageItem()
            }
        }
    }
}

struct BeachTripSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Beach Trip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Image(systemName: "water.waves")
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Text("Thursday")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Beach trip preview
            HStack(spacing: 8) {
                CollageItem(type: .photo, image: "person4")
                CollageItem(type: .photo, image: "person5")
            }
        }
    }
}

struct CollageItem: View {
    enum ItemType {
        case photo
        case video
        case audio
        case text
        case emoji
    }
    
    let type: ItemType
    var image: String = ""
    var duration: String = ""
    var text: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .aspectRatio(1, contentMode: .fit)
            
            switch type {
            case .photo:
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundColor(.white)
                
            case .video:
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(6)
                
            case .audio:
                VStack {
                    Image(systemName: "waveform")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(duration)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
            case .text:
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(8)
                
            case .emoji:
                Text("🙂")
                    .font(.system(size: 40))
            }
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .photo:
            return Color.gray.opacity(0.3)
        case .video:
            return Color.orange.opacity(0.8)
        case .audio:
            return Color.orange.opacity(0.2)
        case .text:
            return Color.yellow.opacity(0.7)
        case .emoji:
            return Color.blue.opacity(0.2)
        }
    }
}

struct EmptyCollageItem: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.clear)
            .aspectRatio(1, contentMode: .fit)
    }
}


struct TabItem: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .primary : .secondary)
        }
    }
}


#Preview {
    HomeView()
}
