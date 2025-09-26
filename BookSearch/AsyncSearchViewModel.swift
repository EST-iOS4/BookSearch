//
//  CombineSearchViewModel.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//
import Foundation
import Combine

class AsyncSearchViewModel: ObservableObject {
  @Published var searchTerm = ""
  @Published private(set) var books: [Book] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage = ""

  private func searchBooks(searchTerm: String) -> [Book] {
    return []
  }
}
