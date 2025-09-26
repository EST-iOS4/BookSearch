//
//  BookSearchApp.swift
//  BookSearch
//
//  Created by Jungman Bae on 9/26/25.
//

import SwiftUI

@main
struct BookSearchApp: App {
    var body: some Scene {
        WindowGroup {
//            CombineSearchView()
          AsyncSearchView()
        }
    }
}
