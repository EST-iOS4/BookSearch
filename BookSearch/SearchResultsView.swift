//
//  SearchResultView.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//

import SwiftUI

struct SearchResultsView: View {
  let books: [Book]
  let isLoading: Bool
  let errorMessage: String

  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()

  var body: some View {
    Group {
      if isLoading {
        ProgressView("검색 중...")
      } else if !errorMessage.isEmpty {
        Text(errorMessage)
          .font(.caption)
          .foregroundStyle(.red)
      } else {
        List(books) { book in
          HStack(alignment: .top) {
            VStack(alignment: .leading) {
              Text(book.title)
                .font(.headline)
              Text(book.author)
                .font(.subheadline)
            }
            Spacer()
            Text(formatter.string(from: book.publishedDate))
              .font(.caption2)
          }
        }
      }
    }
  }
}
