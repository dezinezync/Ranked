//
//  Apps.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class Apps {
  private let appsKey = "com.dezinezync.Ranked.defaults.apps"
  
  static let shared = Apps()
  
  public var apps: [RKApp] = [] {
    didSet {
      if apps != oldValue {
        saveApps()
      }
    }
  }
  
  private init() {
    loadApps()
  }
  
  /// Notify when apps data changes like rankings
  public func didUpdateApps() {
    saveApps()
  }
  
  /// Add an app to the apps list, persisting it to disk
  /// - Parameter app: the app to add
  public func add(app: RKApp) {
    var apps = self.apps
    apps.append(app)
    self.apps = apps.sorted()
  }
  
  /// Remove an app from the apps list.
  ///
  /// Changes are persisted to disk.
  /// - Parameter app: app to remove (look up by `appID`)
  public func remove(app: RKApp) {
    var apps = self.apps
    apps.removeAll(where: {
      $0.id == app.id
    })
    
    self.apps = apps
  }
  
  /// Load apps persisted to User Defaults
  fileprivate func loadApps() {
    guard let data = UserDefaults.standard.data(forKey: appsKey),
          let apps = try? JSONDecoder().decode([RKApp].self, from: data) else {
      return
    }
    self.apps = apps
  }
  
  /// Persist apps data to User Defaults
  fileprivate func saveApps() {
    guard let data = try? JSONEncoder().encode(apps.sorted()) else {
      return
    }
    
    UserDefaults.standard.set(data, forKey: appsKey)
  }
}

private struct AppsEnvKey: EnvironmentKey {
  static let defaultValue = Apps.shared
}

extension EnvironmentValues {
  var apps: Apps {
    get { self[AppsEnvKey.self] }
    set { self[AppsEnvKey.self] = newValue }
  }
}
