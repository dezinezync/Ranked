//
//  AppsGridView.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import SwiftUI

struct AppsGridView: View {
  @Environment(\.apps) private var apps
  @Environment(\.tunesManager) private var tunesManager
  
  var body: some View {
    ScrollView(content: {
      GeometryReader { reader in
        let columns = columnsForGrid(for: reader)
        
        LazyVGrid(columns: columns, spacing: 8) {
          ForEach(apps.apps) { app in
            NavigationLink {
              AppDetailView(app: app)
            } label: {
              AppGridView(app: app)
            }
            .contextMenu {
              Button("Delete", systemImage: "trash", role: .destructive) {
                // @TODO: Confirm
                apps.remove(app: app)
              }
            }
          }
        }
      }
    })
    .scenePadding(.horizontal)
    .toolbar {
      ToolbarSpacer(.flexible)
      
      ToolbarItem(placement: .bottomBar) {
        NavigationLink {
          SearchAppView { app in
            apps.add(app: app)
          }
        } label: {
          Button("New App", systemImage: "plus") {
            
          }
        }
      }
    }
  }
  
  /// Compute the number of columns to be displayed in the grid based on the view port's width
  /// - Parameter reader: the reader for fetching size
  private func columnsForGrid(for reader: GeometryProxy) -> [GridItem] {
    let (idealSize, numberOfColumns): (CGFloat, Int) = {
      let width = reader.size.width
      
      guard width > 0 else {
        return (120, 3)
      }
      
      if (420...500).contains(width) {
        return (floor(width / 4) - (16 * 2), 4)
      }
      else if (280...420).contains(width) {
        return (floor(width / 3) - (16 * 1.5), 3)
      }
      return (floor(width / 6) - (16 * 3), 6)
    }()
    
    return Array(
      repeating: GridItem(.flexible(minimum: idealSize, maximum: 320)),
      count: numberOfColumns
    )
  }
}

private struct AppGridView: View {
  let app: RKApp
  
  var body: some View {
    VStack {
      AppIconView(iconURL: app.artwork)
      
      Text(app.name)
        .font(.headline)
        .foregroundStyle(.primary)
        .lineLimit(1)
      
      Text(app.developer)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
      .fill(.background.secondary)
    )
  }
}

#Preview {
  NavigationStack {
    AppsGridView()
  }
}
