//
//  AppCountryPickerView.swift
//  Ranked
//
//  Created by Nikhil Nigade on 16/09/25.
//

import SwiftUI

struct AppCountryPickerView: View {
  @Environment(\.apps) private var apps
  @Environment(\.tunesManager) private var tunesManager
  
  let app: RKApp
  
  @State private var selected: Set<String> = []
  
  init(app: RKApp) {
    self.app = app
    self.selected = Set(app.countries)
  }
  
  var body: some View {
    List(tunesManager.countries) { country in
      CountryRow(
        country: country,
        isSelected: app.countries.contains(country.shortCode),
        onToggle: { country in
          if app.countries.contains(country.shortCode) {
            var countries = app.countries
            countries.removeAll(where: { $0 == country.shortCode })
            selected = Set(countries)
            updateCountriesListOnApp()
          }
          else {
            var countries = app.countries
            countries.append(country.shortCode)
            selected = Set(countries)
            updateCountriesListOnApp()
          }
        }
      )
      .selectionDisabled(false)
      .tag(country.shortCode)
    }
    .listStyle(.grouped)
    .navigationTitle("Select Regions")
  }
  
  private func updateCountriesListOnApp() {
    app.countries = selected.sorted()
    apps.didUpdateApps()
  }
}

private struct CountryRow: View {
  let country: Country
  let isSelected: Bool
  let onToggle: (_ country: Country) -> Void
  
  var body: some View {
    Button {
      onToggle(country)
    } label: {
      HStack {
        if let emoji = try? countryFlagEmoji(shortCode: country.shortCode) {
          Text(emoji)
            .font(.body)
        }
        
        Text(country.name)
          .font(.headline)
        
        Spacer(minLength: 0)
        
        if isSelected {
          Image(systemName: "checkmark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.tint)
            .frame(width: 20, height: 20)
        }
      }
    }
    .contentShape(Rectangle())
    .buttonStyle(.plain)
  }
}

#if DEBUG
#Preview {
  AppCountryPickerView(app: DEBUG_APP)
}
#endif
