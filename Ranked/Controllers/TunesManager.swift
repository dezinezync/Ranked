//
//  TunesManager.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//


import Foundation
import UIKit
import SwiftUI

/**
 This class provides a shared interface to handle all the iTunes API Networking.
 All methods return a URLSessionTask which is started by default.
 */
final class TunesManager {
  
  // MARK: - Singleton
  
  static let shared = TunesManager()
  
  // MARK: - Public Properties
  
  /// Ordered collection of available countries for iTunes searches
  private(set) var countries: [Country] = []
  
  /// Image cache for storing downloaded app icons and images
  let imageCache = ImageCache()
  
  /// Concurrent queue for internal operations and thread safety
  private(set) var queue: DispatchQueue
  
  // MARK: - Private Properties
  
  private let session: URLSession
  
  // MARK: - Constants
  
  private static let timeoutInterval: TimeInterval = 60
  
  // MARK: - Initialization
  
  private init() {
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = false
    config.requestCachePolicy = .useProtocolCachePolicy
    config.timeoutIntervalForRequest = 30
    config.allowsCellularAccess = true
    config.httpShouldSetCookies = true
    config.httpMaximumConnectionsPerHost = 10
    config.urlCache = URLCache.shared
    
    self.session = URLSession(configuration: config)
    self.session.sessionDescription = "Ranked's base networking session used by its TunesManager class."
    self.queue = DispatchQueue(label: "com.ranked.tunesManager", attributes: .concurrent)
    self.imageCache.name = "com.ranked.cache.imageCache"
    
    loadCountries()
  }
  
  // MARK: - Private Methods
  
  /// Loads countries from the bundled countries.json file
  private func loadCountries() {
    guard let filepath = Bundle.main.path(forResource: "countries", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filepath)),
          let list = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String: Any]] else {
      countries = []
      return
    }
    
    var members: [Country] = []
    for (key, obj) in list {
      if let name = obj["name"] as? String,
         let idString = obj["storeFrontID"] as? String,
         let id = Int(idString) {
        let instance = Country.init(name: name, shortCode: key, storeFrontID: id)
        members.append(instance)
      }
    }
    
    countries = members.sorted()
  }
  
  // MARK: - Public Methods
  
  /**
   Returns a Country object for the given 2-character country code.
   
   - Parameter shortCode: The 2-character country code
   - Returns: Country object if found, nil otherwise
   */
  func country(forCode shortCode: String) -> Country? {
    guard shortCode.count == 2 else {
      #if DEBUG
      fatalError("shortCode should be of 2 characters")
      #else
      return nil
      #endif
    }
    
    if countries.isEmpty {
      loadCountries()
    }
    
    return countries.first { $0.shortCode == shortCode }
  }
  
  func country(for storeFrontID: Int) -> Country? {
    countries.first { $0.storeFrontID == storeFrontID }
  }
  
  // MARK: - Search
  func searchApp(query: String) async throws -> [RKApp] {
    let encodedTitle = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? query
    let path = "https://itunes.apple.com/search?term=\(encodedTitle)&country=US&entity=software,iPadSoftware&limit=25"
    guard let url = URL(string: path) else {
      throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
    }
    
    let (jsonData, response) = try await session.data(from: url)
    
    guard let httpRes = response as? HTTPURLResponse,
          httpRes.statusCode < 399,
          let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
      return []
    }
    
    guard let results = json["results"] as? [[String: Any]] else {
      return []
    }
    
    return results.compactMap {
      RKApp.instance(from: $0)
    }
  }
  
  func ranks(for app: RKApp, progress: (@MainActor (String, Double) -> Void)? = nil) async throws -> [String: Int] {
    let countries = app.countries
    
    var totalProgress: Double = 0
    
    var completed: Int = 0
    let total: Int = app.countries.count
    
    func updateProgress() {
      let format = NSLocalizedString("Loaded %d of %d", comment: "")
      let text = String(format: format, completed, total)
      totalProgress = Double(completed) / Double(total)
      progress?(text, totalProgress)
    }
    
    let result = try await withThrowingTaskGroup(of: [String: Int].self, returning: [[String: Int]].self) { group in
      countries.forEach { countryCode in
        group.addTask(priority: .userInitiated) { [weak self] in
          defer {
            completed += 1
            Task { @MainActor in
              updateProgress()
            }
          }
          
          guard let self else {
            return [countryCode: 0]
          }
          
          do {
            let rank = try await self.rank(for: app, countryCode: countryCode)
            return [countryCode: rank]
          }
          catch {
            return [countryCode: 0]
          }
        }
      }
      
      return try await group.reduce(into: [[String: Int]]()) { partialResult, result in
        partialResult.append(result)
      }
    }
    
    var ranks: [String: Int] = [:]
    result.forEach { item in
      for key in item.keys {
        ranks[key] = item[key]
      }
    }
    
    return ranks
  }
  
  private func rank(for app: RKApp, countryCode: String) async throws -> Int {
    let appClass = app.isPaid ? "toppaidapplications" : "topfreeapplications"
    let path = "https://itunes.apple.com/\(countryCode.lowercased())/rss/\(appClass)/limit=200/genre=\(app.genre)/json"
    
    #if DEBUG
    print("Requesting JSON at URL: \(path)")
    #endif
    
    let appID = "\(app.appID)"
    guard let url = URL(string: path) else {
      throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
    }
    
    let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: Self.timeoutInterval)
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpRes = response as? HTTPURLResponse,
          httpRes.statusCode < 399,
          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      return 0
    }
    
    var entries: [[String: Any]] = []
    
    if let feed = json["feed"] as? [String: Any],
       let feedEntries = feed["entry"] as? [[String: Any]] {
      entries = feedEntries
    }
    
    var rank: Int = 0
    for (index, entry) in entries.enumerated() {
      if let entryId = entry["id"] as? [String: Any],
         let attributes = entryId["attributes"] as? [String: Any],
         let identifier = attributes["im:id"] as? String,
         identifier == appID {
        rank = index + 1
        break
      }
    }
    
    return rank
  }
  
  /**
   Searches for apps matching the given title.
   
   - Parameters:
   - title: The app title to search for
   - success: Success completion handler with array of App objects
   - error: Error completion handler
   - Returns: URLSessionTask that has been started
   */
//  @discardableResult
//  func searchForApp(
//    title: String,
//    success: (([App]) -> Void)? = nil,
//    error: ((Error) -> Void)? = nil
//  ) -> URLSessionTask? {
//    
//    let task: URLSessionTask? = queue.sync {
//      guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
//        let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
//        error?(errorObj)
//        return nil
//      }
//      
//      let path = "https://itunes.apple.com/search?term=\(encodedTitle)&country=US&entity=software,iPadSoftware&limit=25"
//      guard let url = URL(string: path) else {
//        let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
//        error?(errorObj)
//        return nil
//      }
//      
//      var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: Self.timeoutInterval)
//      
//      let task = session.dataTask(with: request) { data, response, taskError in
//        if let taskError = taskError {
//          error?(taskError)
//          return
//        }
//        
//        guard success != nil else { return }
//        
//        guard let data = data else {
//          let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorZeroByteResource, userInfo: nil)
//          error?(errorObj)
//          return
//        }
//        
//        do {
//          guard let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//            let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, userInfo: nil)
//            error?(errorObj)
//            return
//          }
//          
//          guard let resultCount = responseObject["resultCount"] as? Int, resultCount > 0 else {
//            // TODO: handle empty state
//            return
//          }
//          
//          guard let results = responseObject["results"] as? [[String: Any]] else {
//            let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, userInfo: nil)
//            error?(errorObj)
//            return
//          }
//          
//          let apps = results.compactMap { App.instance(from: $0) }
//          
//          DispatchQueue.main.async {
//            success?(apps)
//          }
//          
//        } catch let jsonError {
//          error?(jsonError)
//        }
//      }
//      
//      task.resume()
//      return task
//    }
//  }
//  
//  // MARK: - Rankings
//  
//  /**
//   Fetches rankings for the given app across multiple countries.
//   This data is not app specific and is valid for all apps.
//   Only the country short codes are used for making the requests.
//   The App's reference is used to update rankings directly for that app.
//   
//   - Parameters:
//   - app: The App object to get rankings for
//   - progress: Progress callback with country code and rank
//   - success: Success callback with dictionary of country codes and ranks
//   - error: Error callback
//   */
//  func ranks(
//    for app: App,
//    progress: ((String, NSNumber) -> Void)? = nil,
//    success: (([String: NSNumber]) -> Void)? = nil,
//    error: ((Error) -> Void)? = nil
//  ) {
//    let countries = app.countries
//    guard countries.count > 0 else {
//      success?([:])
//      return
//    }
//    
//    let globalQueue = DispatchQueue.global(qos: .default)
//    globalQueue.async {
//      let semaphore = DispatchSemaphore(value: 0)
//      var taskResponses: [String: NSNumber] = [:]
//      var tasks: [URLSessionTask] = []
//      
//      for countryCode in countries {
//        let task = self.rank(for: app, countryCode: countryCode, success: { rank in
//          taskResponses[countryCode] = rank
//          if let progress = progress {
//            DispatchQueue.main.async {
//              progress(countryCode, rank)
//            }
//          }
//          semaphore.signal()
//        }, error: { taskError in
//          error?(taskError)
//          semaphore.signal()
//        })
//        
//        task.resume()
//        tasks.append(task)
//        semaphore.wait()
//      }
//      
//      // All tasks have completed
//      if let success = success {
//        DispatchQueue.main.async {
//          success(taskResponses)
//        }
//      }
//    }
//  }
//  
//  /**
//   Gets the rank for a specific app in a specific country.
//   
//   - Parameters:
//   - app: The App object
//   - countryCode: The country code to check rankings in
//   - success: Success callback with the rank as NSNumber
//   - error: Error callback
//   - Returns: URLSessionTask that has been started
//   */
//  @discardableResult
//  func rank(
//    for app: App,
//    countryCode code: String,
//    success: @escaping (NSNumber) -> Void,
//    error: @escaping (Error) -> Void
//  ) -> URLSessionTask {
//    
//    let appClass = app.isPaid ? "toppaidapplications" : "topfreeapplications"
//    let path = "https://itunes.apple.com/\(code.lowercased())/rss/\(appClass)/limit=200/genre=\(app.genre)/json"
//    
//#if DEBUG
//    print("Requesting JSON at URL: \(path)")
//#endif
//    
//    guard let url = URL(string: path) else {
//      let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
//      error(errorObj)
//      return URLSessionTask() // Return dummy task
//    }
//    
//    let appID = app.appID.stringValue
//    var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: Self.timeoutInterval)
//    
//    let task = session.dataTask(with: request) { data, response, taskError in
//      if let taskError = taskError {
//        error(taskError)
//        return
//      }
//      
//      guard let data = data else {
//        let errorObj = NSError(domain: NSURLErrorDomain, code: NSURLErrorZeroByteResource, userInfo: nil)
//        error(errorObj)
//        return
//      }
//      
//      do {
//        let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
//        
//        var entries: [[String: Any]] = []
//        
//        if let responseDict = responseObject as? [String: Any],
//           let feed = responseDict["feed"] as? [String: Any],
//           let feedEntries = feed["entry"] as? [[String: Any]] {
//          entries = feedEntries
//        }
//        
//        var rank = 0
//        for (index, entry) in entries.enumerated() {
//          if let entryId = entry["id"] as? [String: Any],
//             let attributes = entryId["attributes"] as? [String: Any],
//             let identifier = attributes["im:id"] as? String,
//             identifier == appID {
//            rank = index + 1
//            break
//          }
//        }
//        
//        success(NSNumber(value: rank))
//        
//      } catch let jsonError {
//        error(jsonError)
//      }
//    }
//    
//    task.resume()
//    return task
//  }
//  
//  // MARK: - Images
//  
//  /**
//   Downloads and caches an image from the given URL.
//   If the size of the original image is smaller than the size parameter, it is not resized.
//   
//   - Parameters:
//   - url: The URL of the image to download
//   - size: The desired size for the image
//   - success: Success callback with the UIImage (may be nil)
//   - error: Error callback
//   - Returns: URLSessionTask if download is needed, nil if served from cache
//   */
//  @discardableResult
//  func image(
//    for url: URL?,
//    size: CGSize,
//    success: ((UIImage?) -> Void)? = nil,
//    error: ((Error) -> Void)? = nil
//  ) -> URLSessionTask? {
//    guard let url = url else {
//      let errorObj = NSError(domain: NSURLErrorDomain, code: 500, userInfo: [NSURLErrorFailingURLErrorKey: "\(String(describing: url))"])
//      error?(errorObj)
//      return nil
//    }
//    
//    let semaphore = DispatchSemaphore(value: 0)
//    var cachedImage: UIImage?
//    
//    imageCache.object(forKey: url.absoluteString) { image in
//      cachedImage = image
//      semaphore.signal()
//    }
//    
//    semaphore.wait()
//    
//    if let cachedImage = cachedImage {
//      DispatchQueue.main.async {
//        success?(cachedImage)
//      }
//      return nil
//    }
//    
//    let task = session.dataTask(with: url) { data, response, taskError in
//      if let taskError = taskError {
//        error?(taskError)
//        return
//      }
//      
//      guard success != nil else { return }
//      
//      DispatchQueue.main.async {
//        guard let data = data, data.count > 4 else {
//          success?(nil)
//          return
//        }
//        
//        let image = UIImage(data: data, scale: UIScreen.main.scale)
//        if let image = image {
//          self.imageCache.setObject(image,  data, forKey: url.absoluteString)
//        }
//        success?(image)
//      }
//    }
//    
//    task.resume()
//    return task
//  }
}

private struct TunesManagerEnvKey: EnvironmentKey {
  static let defaultValue = TunesManager.shared
}

extension EnvironmentValues {
  var tunesManager: TunesManager {
    get { self[TunesManagerEnvKey.self] }
    set { self[TunesManagerEnvKey.self] = newValue }
  }
}
