//
//  SearchView.swift
//  Feature
//
//  Created by 김도형 on 7/26/24.

import ComposableArchitecture
import SwiftUI

@ViewAction(for: SearchFeature.self)
public struct SearchView: View {
    /// - Properties
    public var store: StoreOf<SearchFeature>
    
    /// - Initializer
    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SearchView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Hello World!")
            }
        }
    }
}
//MARK: - Configure View
private extension SearchView {
    
}
//MARK: - Preview
#Preview {
    SearchView(
        store: Store(
            initialState: .init(),
            reducer: { SearchFeature() }
        )
    )
}


