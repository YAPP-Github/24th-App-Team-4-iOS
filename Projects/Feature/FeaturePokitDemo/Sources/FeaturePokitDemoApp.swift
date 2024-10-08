//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import ComposableArchitecture
import FeaturePokit

@main
struct FeaturePokitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            PokitRootView(
                store: Store(
                    initialState: .init(),
                    reducer: { PokitRootFeature() }
                )
            )
        }
    }
}
