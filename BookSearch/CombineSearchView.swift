//
//  ContentView.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//

import SwiftUI

struct CombineSearchView: View {
  @StateObject private var viewModel = CombineSearchViewModel()

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
      .navigationTitle("도서 검색 (Combine)")
    }
  }
}

#Preview {
  CombineSearchView()
}
