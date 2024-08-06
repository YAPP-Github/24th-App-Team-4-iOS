//
//  App.stencil.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/16/24.
//

import SwiftUI

import FeatureLinkList

@main
struct FeatureLinkListDemoApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: 루트 뷰 추가
            LinkListView(store: .init(
                initialState: .init(linkType: .unread),
                reducer: { LinkListFeature() }
            ))
        }
    }
}
