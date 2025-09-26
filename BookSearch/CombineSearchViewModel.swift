//
//  CombineSearchViewModel.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//
import Foundation
import Combine

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
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .removeDuplicates()
      .handleEvents(receiveOutput: { [weak self] data in
        self?.isLoading = true
        self?.errorMessage = ""
      })
      .flatMap { [weak self] searchTerm -> AnyPublisher<[Book], Never> in
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
    var components = URLComponents(string: "http://127.0.0.1:5001/est-ios04/us-central1/search")
    components?.queryItems = [
      URLQueryItem(name: "q", value: searchTerm)
    ]

    guard let url = components?.url else {
      print("Invalid URL with searchTerm: \(searchTerm)")
      return Just([]).eraseToAnyPublisher()
    }

    print("searchBooks URL: \(url.absoluteString)")

    let decoder = SearchResultDecoder()

    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: SearchResult.self, decoder: decoder)
      .map(\.results)
      .catch { [weak self] error -> AnyPublisher<[Book], Never> in
        DispatchQueue.main.async {
          self?.errorMessage = "요청/디코딩 오류: \(error.localizedDescription)"
        }
        return Just([]).eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}
