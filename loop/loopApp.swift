//
//  loopApp.swift
//  loop
//
//  Created by Andrew Ondara on 7/16/25.
//

import SwiftUI

@main
struct loopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task {
                        try await supabase.auth.session(from: url)
                    }
                }
        }
    }
}
