//
//  App.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import Foundation
import Observation

// MARK: - App
@Observable
final class RKApp: Codable {
  let appID: Int
  let developerID: Int
  let developer: String

  let artwork: URL
  
  let genre: Int
  let genreName: String
  
  let name: String
  let url: URL
  
  let isPaid: Bool
  
  /// List of country codes for which the app tracks it's rankings.
  /// 
  /// This allows for different apps to have different trackings.
  var countries: [String]
  var rankings: [String: Int]?
  
  /// This is not persisted to the disk. It's only avilable during the lifecycle of the app.
  /// When rankings are reloaded, the value from rankings is assigned to this list
  var oldRankings: [String: Int]?
  
  init(appID: Int, developerID: Int, developer: String, artwork: URL, genre: Int, genreName: String, name: String, url: URL, isPaid: Bool, countries: [String], rankings: [String : Int]? = nil, oldRankings: [String : Int]? = nil) {
    self.appID = appID
    self.developerID = developerID
    self.developer = developer
    self.artwork = artwork
    self.genre = genre
    self.genreName = genreName
    self.name = name
    self.url = url
    self.isPaid = isPaid
    self.countries = countries
    self.rankings = rankings
    self.oldRankings = oldRankings
  }
  
  // MARK: Codable
  private enum CodingKeys: String, CodingKey, CaseIterable {
    case appID
    case developerID
    case developer
    case artwork
    case genre
    case genreName
    case name
    case url
    case isPaid
    case countries
    case rankings
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    // Decode all the let properties
    self.appID = try container.decode(Int.self, forKey: .appID)
    self.developerID = try container.decode(Int.self, forKey: .developerID)
    self.developer = try container.decode(String.self, forKey: .developer)
    self.artwork = try container.decode(URL.self, forKey: .artwork)
    self.genre = try container.decode(Int.self, forKey: .genre)
    self.genreName = try container.decode(String.self, forKey: .genreName)
    self.name = try container.decode(String.self, forKey: .name)
    self.url = try container.decode(URL.self, forKey: .url)
    self.isPaid = try container.decode(Bool.self, forKey: .isPaid)
    
    // Decode @ObservationTracked properties
    self.countries = try container.decode([String].self, forKey: .countries)
    self.rankings = try container.decodeIfPresent([String: Int].self, forKey: .rankings)
    
    // oldRankings is not persisted, so initialize as nil
    self.oldRankings = nil
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    // Encode all the let properties
    try container.encode(self.appID, forKey: .appID)
    try container.encode(self.developerID, forKey: .developerID)
    try container.encode(self.developer, forKey: .developer)
    try container.encode(self.artwork, forKey: .artwork)
    try container.encode(self.genre, forKey: .genre)
    try container.encode(self.genreName, forKey: .genreName)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.url, forKey: .url)
    try container.encode(self.isPaid, forKey: .isPaid)
    
    // Encode @ObservationTracked properties
    try container.encode(self.countries, forKey: .countries)
    try container.encodeIfPresent(self.rankings, forKey: .rankings)
    
    // oldRankings is intentionally NOT encoded as it's transient
  }
}

// MARK: Identifiable
extension RKApp: Identifiable {
  var id: Int {
    appID
  }
}

// MARK: Hashable
extension RKApp: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(appID)
  }
}

// MARK: Equatable
extension RKApp: Equatable {
  static func ==(_ lhs: RKApp, _ rhs: RKApp) -> Bool {
    lhs.appID == rhs.appID &&
    lhs.developerID == rhs.developerID
  }
}

// MARK: Comparable
extension RKApp: Comparable {
  static func < (lhs: RKApp, rhs: RKApp) -> Bool {
    let comparison = lhs.name.localizedStandardCompare(rhs.name)
    if comparison == .orderedSame {
      return lhs.appID < rhs.appID
    }
    
    return comparison == .orderedAscending
  }
}

// MARK: Dictionary Support
extension RKApp {
  static func instance(from dict: [String: Any]) -> RKApp? {
    guard let appID = dict["trackId"] as? Int,
          let developerID = dict["artistId"] as? Int,
          let developer = dict["sellerName"] as? String,
          let genre = dict["primaryGenreId"] as? Int,
          let genreName = dict["primaryGenreName"] as? String,
          let name = dict["trackName"] as? String,
          let artwork = dict["artworkUrl512"] as? String ?? dict["artworkUrl100"] as? String,
          let artworkURL = URL(string: artwork),
          let trackURL = dict["trackViewUrl"] as? String,
          let url = URL(string: trackURL)
    else {
      return nil
    }
    
    var isPaid: Bool = false
    if let price = dict["price"] as? Double,
       price > .zero {
      isPaid = true
    }
    
    return RKApp(
      appID: appID,
      developerID: developerID,
      developer: developer,
      artwork: artworkURL,
      genre: genre,
      genreName: genreName,
      name: name,
      url: url,
      isPaid: isPaid,
      countries: ["AU", "AT", "CA", "CN", "FR", "DE", "GB", "HK", "IN", "IT", "JP", "MX", "NL", "SG", "US"]
    )
  }
}
