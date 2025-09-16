//
//  RankedApp.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import SwiftUI

@main
struct RankedApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        AppsGridView()
          .navigationTitle("Ranked")
          .environment(\.apps, Apps.shared)
          .environment(\.tunesManager, TunesManager.shared)
      }
    }
  }
}
