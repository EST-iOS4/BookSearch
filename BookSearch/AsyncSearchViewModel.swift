//
//  CombineSearchViewModel.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//
import Foundation
import Combine

@MainActor
class AsyncSearchViewModel: ObservableObject {
  @Published var searchTerm = ""
  @Published private(set) var books: [Book] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage = ""

  private var searchTask: Task<Void, Never>?

  func executeSearch() async {
    searchTask?.cancel()

    let currentTerm = searchTerm.trimmingCharacters(in: .whitespaces)

    guard !currentTerm.isEmpty else {
      books = []
      return
    }

    searchTask = Task {
      isLoading = true
      errorMessage = ""

      do {
        try await Task.sleep(nanoseconds: 500_000_000)

        if !Task.isCancelled {
          let searchResults = try await searchBooks(searchTerm: currentTerm)
          books = searchResults
        }
      } catch {
        if !Task.isCancelled {
          errorMessage = "검색 실패: \(error.localizedDescription)"
        }
      }

      if !Task.isCancelled {
        isLoading = false
      }
    }

  }

  private func searchBooks(searchTerm: String) async throws -> [Book] {
    var components = URLComponents(string: "http://127.0.0.1:5001/est-ios04/us-central1/search")
    components?.queryItems = [
      URLQueryItem(name: "q", value: searchTerm)
    ]

    guard let url = components?.url else {
      print("Invalid URL with searchTerm: \(searchTerm)")
      return []
    }

    print("searchBooks URL: \(url.absoluteString)")

    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = SearchResultDecoder()

    let searchResult = try decoder.decode(SearchResult.self, from: data)

    return searchResult.results
  }
}
