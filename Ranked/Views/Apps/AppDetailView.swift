//
//  AppDetailView.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import SwiftUI

struct AppDetailView: View {
  @Environment(\.tunesManager) private var tunesManager
  @Environment(\.apps) private var apps
  
  @State var app: RKApp
  
  @State private var isLoadingRanks: Bool = false
  @State private var progressText: String = ""
  @State private var progress: Double = 0
  
  var body: some View {
    List {
      Section {
        ForEach(app.countries, id: \.self) { countryCode in
          AppCountryRow(
            app: app,
            countryCode: countryCode,
            rank: app.rankings?[countryCode],
            oldRank: app.oldRankings?[countryCode]
          )
        }
      }
    }
    .listStyle(.insetGrouped)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Button(
          "Open in AppStore",
          systemImage: "arrow.up.right",
          action: {
            #if os(iOS)
            UIApplication.shared.open(app.url)
            #endif
          }
        )
        
        NavigationLink {
          AppCountryPickerView(app: app)
        } label: {
          Button("Countries", systemImage: "globe") { }
        }
      }
      
      if isLoadingRanks {
        ToolbarItemGroup(placement: .bottomBar) {
          VStack {
            Text(progressText)
              .font(.caption)
              .foregroundStyle(.secondary)
            
            ProgressView(value: progress, total: 1)
              .progressViewStyle(.linear)
          }
          .padding()
          .frame(width: 180, alignment: .center)
        }
      }
    }
    .onAppear(perform: {
      Task {
        isLoadingRanks = true
        
        do {
          #if DEBUG
          print("Loading ranks")
          #endif
          let ranks = try await tunesManager.ranks(for: app) { text, progress in
            self.progressText = text
            self.progress = progress
          }
          #if DEBUG
          print("Loaded ranks")
          #endif
          if let old = app.rankings,
             old != ranks {
            app.oldRankings = old
          }
          
          if app.rankings != ranks {
            app.rankings = ranks
            apps.didUpdateApps()
          }
        }
        catch {
          // @TODO: Display Error
          print(error)
        }
        
        isLoadingRanks = false
      }
    })
    .navigationTitle(app.name)
    .navigationSubtitle(app.developer)
  }
}

// MARK: - AppCountryRow
private struct AppCountryRow: View {
  @Environment(\.tunesManager) private var tunesManager
  
  let app: RKApp
  /// Two-letter short code
  let countryCode: String
  
  let rank: Int?
  let oldRank: Int?
  
  var body: some View {
    if let country = tunesManager.country(forCode: countryCode) {
      HStack {
        if let emoji = try? countryFlagEmoji(shortCode: country.shortCode) {
          Text(emoji)
            .font(.body)
        }
        
        Text(country.name)
          .font(.headline)
        
        Spacer(minLength: 0)
        
        let rank = rank ?? 0
        
        Text(rank == 0 ? "-" : "\(rank)")
          .font(.body)
          .fontDesign(.monospaced)
          .multilineTextAlignment(.trailing)
        
        if let oldRank,
           oldRank != rank {
          let change = rank - oldRank
          
          if change == 0 {
            Text("")
          }
          else if change > 0 {
            Text("+\(change)")
              .font(.body)
              .fontDesign(.monospaced)
              .multilineTextAlignment(.trailing)
              .foregroundStyle(.green) // @TODO: zh-CN flip
          }
          else {
            Text("\(change)")
              .font(.body)
              .fontDesign(.monospaced)
              .multilineTextAlignment(.trailing)
              .foregroundStyle(.red) // @TODO: zh-CN flip
          }
        }
      }
    }
    else {
      Text("Invalid country code: \(countryCode)")
        .foregroundStyle(.red)
    }
  }
}

#if DEBUG
let DEBUG_APP = RKApp(
  appID: 1433266971,
  developerID: 1422296034,
  developer: "Nikhil Nigade",
  artwork: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/c7/58/60/c7586049-eb17-d10c-f908-60fd59b4959f/AppIcon-0-0-1x_U007epad-0-1-0-sRGB-85-220.png/512x512bb.jpg")!,
  genre: 6009,
  genreName: "News",
  name: "Elytra",
  url: URL(string: "https://apps.apple.com/us/app/elytra/id1433266971?uo=4")!,
  isPaid: false,
  countries: ["AU", "AT", "CA", "CN", "FR", "DE", "GB", "HK", "IN", "IT", "JP", "MX", "NL", "SG", "US"]
)

#Preview {
  NavigationStack {
    AppDetailView(app: DEBUG_APP)
  }
}
#endif
