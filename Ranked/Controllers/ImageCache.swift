//
//  ImageCache.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import Foundation
import UIKit
import CommonCrypto

/**
 ImageCache extends NSCache to provide both in-memory and disk-based caching for UIImage objects.
 Uses MD5 hashing for cache keys and provides thread-safe operations.
 */
final class ImageCache: NSCache<NSString, UIImage> {
  
  // MARK: - Properties
  
  /// Path to the disk cache directory
  private let cachePath: String
  
  /// Serial queue for writing files to prevent corruption
  private let writeQueue: DispatchQueue
  
  /// Concurrent queue for reading files to allow multiple simultaneous reads
  private let readQueue: DispatchQueue
  
  /// File manager for disk operations
  private let fileManager: FileManager
  
  // MARK: - Initialization
  
  override init() {
    // Get the caches directory and append our cache folder
    let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
    self.cachePath = (paths[0] as NSString).appendingPathComponent("imageDiskCache")
    
    // Create serial write queue to prevent memory corruption when writing multiple files
    self.writeQueue = DispatchQueue(label: "com.ranked.imageCache.writeQueue")
    
    // Create concurrent read queue to allow multiple simultaneous reads
    self.readQueue = DispatchQueue(label: "com.ranked.PDC.readQueue", attributes: .concurrent)
    
    self.fileManager = FileManager.default
    
    super.init()
    
    // Create the local cache folder on initialization
    writeQueue.sync {
      createLocalFolder()
    }
  }
  
  // MARK: - Private Methods
  
  /// Creates the local disk cache folder if it doesn't exist
  private func createLocalFolder() {
    if !fileManager.fileExists(atPath: cachePath) {
      try? fileManager.createDirectory(
        atPath: cachePath,
        withIntermediateDirectories: true,
        attributes: nil
      )
    }
  }
  
  // MARK: - Public Methods
  
  /**
   Retrieves an image for the given key, checking memory cache first, then disk cache.
   
   - Parameters:
   - key: The cache key for the image
   - callback: Completion handler called with the UIImage or nil if not found
   */
  func object(forKey key: String, callback: (@MainActor (UIImage?) -> Void)?) {
    guard let callback else { return }
    
    let hashedKey = key.sha256()
    
    // Check memory cache first
    if let cachedImage = object(forKey: hashedKey as NSString) {
      callback(cachedImage)
    }
    else {
      // Check disk cache
      objectForKeyOnDisk(hashedKey, callback: callback)
    }
  }
  
  /**
   Stores an image in both memory and disk cache.
   
   - Parameters:
   - obj: The UIImage to cache
   -  Optional image data. If nil, PNG representation will be used
   - key: The cache key for the image
   */
  func setObject(_ obj: UIImage, data: Data?, forKey key: String) {
    // Calculate cost based on image dimensions and scale
    let cost = Int(obj.size.height * obj.size.width * obj.scale * obj.scale)
    
    setObject(obj, data: data, forKey: key, cost: cost)
  }
  
  /**
   Stores an image in both memory and disk cache with specified cost.
   
   - Parameters:
   - obj: The UIImage to cache
   - data:  Optional image data. If nil, PNG representation will be used
   - key: The cache key for the image
   - cost: The cost for memory cache management
   */
  func setObject(_ obj: UIImage, data: Data?, forKey key: String, cost: Int) {
    let hashedKey = key.sha256()
    
    // Store in memory cache with cost
    setObject(obj, forKey: hashedKey as NSString, cost: cost)
    
    var imageData = data
    
    if imageData == nil {
      imageData = obj.pngData()
    }
    
    if let imageData {
      setObjectToDisk(imageData, forKey: hashedKey)
    }
  }
  
  /**
   Removes an object from both memory and disk cache.
   
   - Parameter key: The cache key to remove
   */
  func removeObject(forKey key: String) {
    let hashedKey = key.sha256()
    removeObject(forKey: hashedKey as NSString)
    // Note: Disk removal could be added here if needed
  }
  
  // MARK: - Disk Cache Operations
  
  /// Stores data to disk cache asynchronously
  private func setObjectToDisk(_ data: Data, forKey key: String) {
    writeQueue.async { [weak self] in
      guard let self else { return }
      
      let path = (self.cachePath as NSString).appendingPathComponent(key)
      
      if !self.fileManager.fileExists(atPath: path) {
        self.fileManager.createFile(
          atPath: path,
          contents: data,
          attributes: [:]
        )
        
        var url = URL(fileURLWithPath: path)
        var res = URLResourceValues()
        res.isExcludedFromBackup = true
        try? url.setResourceValues(res)
      }
    }
  }
  
  /// Retrieves an image from disk cache asynchronously
  private func objectForKeyOnDisk(_ key: String, callback: @escaping @MainActor (UIImage?) -> Void) {
    readQueue.async { [weak self] in
      guard let self else {
        DispatchQueue.main.async {
          callback(nil)
        }
        return
      }
      
      let path = (self.cachePath as NSString).appendingPathComponent(key)
      
      guard self.fileManager.fileExists(atPath: path) else {
        DispatchQueue.main.async {
          callback(nil)
        }
        return
      }
      
      guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let image = UIImage(data: data) else {
        DispatchQueue.main.async {
          callback(nil)
        }
        return
      }
      
      // Store in memory cache for future access
      self.setObject(image, forKey: key as NSString)
      
      DispatchQueue.main.async {
        callback(image)
      }
    }
  }
}

// MARK: - String MD5 Extension

public extension String {
  /**
   Returns the SHA256 hash of the string as a hexadecimal string.
   
   - Returns: SHA256 hash as a lowercase hexadecimal string
   */
  func sha256() -> String {
    guard let messageData = self.data(using: .utf8) else { return self }
    var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
    
    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
      messageData.withUnsafeBytes { messageBytes -> UInt8 in
        if let messageBytesBaseAddress = messageBytes.baseAddress,
           let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
          let messageLength = CC_LONG(messageData.count)
          CC_SHA256(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
        }
        return 0
      }
    }
    
    return digestData.map { String(format: "%02hhx", $0) }.joined()
  }
}
