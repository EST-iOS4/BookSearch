//
//  CombineSearchViewModel.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//
import Foundation
import Combine

struct SearchResult: Codable {
  let query: String
  let results: [Book]
}

struct Book: Codable {
  let title: String
  let author: String
  let publishedDate: Date
  let createdAt: Date
}

class CombineSearchViewModel: ObservableObject {
  @Published var searchTerm = ""

  @Published private(set) var books: [Book] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage = ""

  private var cancellables = Set<AnyCancellable>()

  init() {
    setupSearchPipeline()
  }

  private func setupSearchPipeline() {
    $searchTerm
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      .removeDuplicates()
      .handleEvents(receiveOutput: { [weak self] _ in
        self?.isLoading = true
        self?.errorMessage = ""
      })
      .flatMap { [weak self] searchTerm -> AnyPublisher<[Book],Never> in
        guard !searchTerm.isEmpty else {
          return Just([]).eraseToAnyPublisher()
        }

        return self?.searchBooks(searchTerm: searchTerm) ?? Just([]).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] books in
        self?.books = books
        self?.isLoading = false
      }
      .store(in: &cancellables)
  }

  private func searchBooks(searchTerm: String) -> AnyPublisher<[Book], Never> {
    guard let url = URL(string: "http://127.0.0.1:5001/est-ios04/us-central1/search?q=\(searchTerm)") else {
      return Just([]).eraseToAnyPublisher()
    }

    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: SearchResult.self, decoder: JSONDecoder())
      .map(\.results)
      .replaceError(with: [])
      .eraseToAnyPublisher()
  }
}
