//
//  File.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//

import Foundation

struct SearchResult: Codable {
  let query: String
  let results: [Book]
  let count: Int
}

struct Book: Codable, Identifiable {
  let id: Int
  let title: String
  let author: String
  let publishedDate: Date
  let createdAt: Date
}
