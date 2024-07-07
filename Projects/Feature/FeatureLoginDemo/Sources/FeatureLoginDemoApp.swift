//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI
import FeatureLogin

@main
struct FeatureLoginDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            SignUpRootView(store: .init(initialState: .init(), reducer: {
                SignUpRootFeature()
            }))
        }
    }
}

#Preview {
    SignUpRootView(store: .init(initialState: .init(), reducer: {
        SignUpRootFeature()
    }))
}
