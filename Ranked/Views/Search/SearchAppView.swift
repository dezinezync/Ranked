//
//  SearchAppView.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import SwiftUI
import DebouncedOnChange

struct SearchAppView: View {
  @Environment(\.tunesManager) private var tunesManager
  @Environment(\.dismiss) private var dismiss
  
  @State private var searchText: String = ""
  @State private var lookupApps: [RKApp] = []
  @State private var selectedApp: RKApp? = nil
  @State private var isSearchPresented: Bool = true
  
  var onSelect: @MainActor (_ app: RKApp) -> Void
  
  var body: some View {
    List(lookupApps, selection: $selectedApp, rowContent: { app in
      SearchResultCell(app: app)
        .tag(app)
    })
    .searchable(
      text: $searchText,
      isPresented: $isSearchPresented,
      placement: .automatic,
      prompt: Text("App Name")
    )
    .onChange(of: searchText, debounceTime: .milliseconds(150), { oldValue, newValue in
      if oldValue != newValue,
         newValue.trimmingCharacters(in: .whitespaces).count >= 3 {
        Task {
          do {
            let apps = try await tunesManager.searchApp(query: newValue.trimmingCharacters(in: .whitespaces))
            self.lookupApps = apps
          }
          catch {
            print(error)
          }
        }
      }
    })
    .onChange(of: selectedApp) { oldValue, newValue in
      if let newValue {
        isSearchPresented = false
        onSelect(newValue)
        dismiss.callAsFunction()
      }
    }
  }
}

private struct SearchResultCell: View {
  let app: RKApp
  
  var body: some View {
    HStack {
      AppIconView(iconURL: app.artwork)
      
      Text(app.name)
    }
  }
}

public struct AppIconView: View {
  public let iconURL: URL
  public let size: CGFloat
  private let cornerRadii: CGFloat
  
  init(iconURL: URL, size: CGFloat = 32) {
    self.iconURL = iconURL
    self.size = size
    self.cornerRadii = floor(size / 3.85)
  }
  
  public var body: some View {
    AsyncImage(url: iconURL) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
    } placeholder: {
      RoundedRectangle(cornerRadius: cornerRadii, style: .continuous)
        .fill(Color.gray.tertiary)
    }
    .frame(width: size, height: size)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadii, style: .continuous))
  }
}

#Preview {
  NavigationStack {
    SearchAppView(onSelect: { _ in })
  }
}
