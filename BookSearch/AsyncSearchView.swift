//
//  ContentView.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//

import SwiftUI

struct AsyncSearchView: View {
  @StateObject private var viewModel = AsyncSearchViewModel()

  var body: some View {
    NavigationStack {
      VStack {
        SearchResultsView(
          books: viewModel.books,
          isLoading: viewModel.isLoading,
          errorMessage: viewModel.errorMessage
        )
      }
      .searchable(text: $viewModel.searchTerm)
      .onReceive(viewModel.$searchTerm) { _ in
        Task {
          await viewModel.executeSearch()
        }
      }
      .navigationTitle("도서 검색 (Combine)")
    }
  }
}

#Preview {
  CombineSearchView()
}
