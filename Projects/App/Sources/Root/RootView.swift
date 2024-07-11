//
//  RootView.swift
//  App
//
//  Created by 김민호 on 7/5/24.
//

import SwiftUI

import ComposableArchitecture

public struct RootView: View {
    /// - Properties
    private let store: StoreOf<RootFeature>
    /// - Initalizer
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
}
//MARK: - View
extension RootView {
    public var body: some View {
        WithPerceptionTracking {
            Group {
                if let store = store.scope(state: \.intro, action: \.intro) {
                    IntroView(store: store)
                }
                
                if let store = store.scope(state: \.mainTab, action: \.mainTab) {
                    MainTabView(store: store)
                }
            }
        }
    }
}
//MARK: - Configure View
extension RootView {}
//MARK: - Preview
#Preview {
    RootView(
        store: Store(
            initialState: .init(),
            reducer: { RootFeature() }
        )
    )
}