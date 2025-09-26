//
//  SearchResultDecoder.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//

import Foundation

class SearchResultDecoder: JSONDecoder, @unchecked Sendable {
  nonisolated override init() {
    super.init()
    keyDecodingStrategy = .convertFromSnakeCase

    // ISO8601(밀리초 포함) 우선, 실패 시 일반 ISO8601로 재시도
    dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)

      // with fractional seconds
      let isoWithFractional = ISO8601DateFormatter()
      isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      if let date = isoWithFractional.date(from: dateString) {
        return date
      }

      // fallback without fractional seconds
      let iso = ISO8601DateFormatter()
      iso.formatOptions = [.withInternetDateTime]
      if let date = iso.date(from: dateString) {
        return date
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid ISO8601 date: \(dateString)"
      )
    }
  }
}
