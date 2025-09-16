//
//  Country.swift
//  Ranked
//
//  Created by Nikhil Nigade on 15/09/25.
//

import Foundation

// MARK: - Country
struct Country: Codable, Identifiable, Hashable {
  var id: Int {
    return storeFrontID
  }
  
  let name: String
  let shortCode: String
  let storeFrontID: Int
}

// MARK: Equatable
extension Country: Equatable {
  static func ==(_ lhs: Country, _ rhs: Country) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: Comparable
extension Country: Comparable {
  static func < (lhs: Country, rhs: Country) -> Bool {
    let comparison = lhs.name.localizedStandardCompare(rhs.name)
    if comparison == .orderedSame {
      return lhs.id < rhs.id
    }
    
    return comparison == .orderedAscending
  }
}

// MARK: - CountryFlagError
enum CountryFlagError: Error {
  case invalidCountryCodeLength
}

func countryFlagEmoji(shortCode: String) throws -> String {
  // Validate that the country code is exactly 2 characters
  guard shortCode.count == 2 else {
    throw CountryFlagError.invalidCountryCodeLength
  }
  
  // Base Unicode value calculation: Regional Indicator Symbol Letter A (🇦) - ASCII 'A'
  let base = 0x1F1E6 - 0x41
  
  // Ensure uppercase for consistent mapping
  let uppercased = shortCode.uppercased()
  
  // Convert each character to its corresponding Regional Indicator Symbol
  let scalars = uppercased.unicodeScalars.map { scalar -> UInt32 in
    return UInt32(base) + scalar.value
  }
  
  // Create the flag emoji string from the Unicode scalars
  return String(String.UnicodeScalarView(scalars.compactMap { UnicodeScalar($0) }))
}
