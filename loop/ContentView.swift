//
//  ContentView.swift
//  loop
//
//  Created by Andrew Ondara on 7/16/25.
//

import SwiftUI

struct ContentView: View {
    @State var isAuthenticated = false
    var body: some View {
      Group {
        let _ = print(isAuthenticated)
        if isAuthenticated {
          ProfileView()
        } else {
          AuthView()
        }
      }
      .task {
        for await state in supabase.auth.authStateChanges {
          if [.initialSession, .signedIn, .signedOut].contains(state.event) {
            isAuthenticated = state.session != nil
          }
        }
      }
    }
  }

#Preview {
    ContentView()
}
