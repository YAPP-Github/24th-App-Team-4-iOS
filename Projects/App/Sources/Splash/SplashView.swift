//
//  SplashView.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import SwiftUI

import ComposableArchitecture

public struct SplashView: View {
    /// - Properties
    private let store: StoreOf<SplashFeature>
    /// - Initializer
    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SplashView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Splash")
                    .font(.largeTitle)
            }
            .onAppear { store.send(.onAppear) }
        }
    }
}
//MARK: - Configure View
extension SplashView {
    
}
//MARK: - Preview
#Preview {
    SplashView(
        store: Store(
            initialState: .init(),
            reducer: { SplashFeature() }
        )
    )
}


