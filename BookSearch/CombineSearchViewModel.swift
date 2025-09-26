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

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // ISO8601(밀리초 포함) 우선, 실패 시 일반 ISO8601로 재시도
    decoder.dateDecodingStrategy = .custom { decoder in
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
