//
//  NickNameSettingView.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: NickNameSettingFeature.self)
public struct NickNameSettingView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<NickNameSettingFeature>
    @FocusState private var isFocused: Bool
    
    /// - Initializer
    public init(store: StoreOf<NickNameSettingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension NickNameSettingView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                PokitTextInput(
                    text: $store.text,
                    errorMessage: "사용중인 닉네임입니다.",
                    info: "한글, 영어, 숫자로만 입력이 가능합니다.",
                    focusState: $isFocused,
                    equals: true
                )
                Spacer()
                PokitBottomButton(
                    "저장",
                    state: store.buttonState,
                    action: { send(.saveButtonTapped) }
                )
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden()
            .pokitNavigationBar(title: "설정")
            .toolbar { navigationBar }
        }
    }
}
//MARK: - Configure View
private extension NickNameSettingView {
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.dismiss) }
            )
        }
    }
    
}
//MARK: - Preview
#Preview {
    NavigationStack {
        NickNameSettingView(
            store: Store(
                initialState: .init(),
                reducer: { NickNameSettingFeature() }
            )
        )
    }
}


