//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI
import ComposableArchitecture

import FeatureRemind

@main
struct FeatureRemindDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            NavigationStack {
                RemindView(
                    store: .init(
                        initialState: .init(),
                        reducer: { RemindFeature() }
                    )
                )
            }
        }
    }
}

#Preview {
    RemindView(
        store: .init(
            initialState: .init(),
            reducer: { RemindFeature() }
        )
    )
}
