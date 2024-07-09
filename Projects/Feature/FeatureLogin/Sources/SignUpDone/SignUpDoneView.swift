//
//  SignUpDoneView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

import DSKit

public struct SignUpDoneView: View {
    /// - Properties
    private let store: StoreOf<SignUpDoneFeature>
    /// - Initializer
    public init(store: StoreOf<SignUpDoneFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SignUpDoneView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Spacer()
                
                Group {
                    logo
                    
                    title
                        .padding(.top, 28)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                PokitBottomButton("시작하기", state: .filled(.primary)) {
                    store.send(.startButtonTapped)
                }
            }
            .background(.pokit(.bg(.base)))
            .pokitNavigationBar(title: "")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PokitToolbarButton(.icon(.arrowLeft)) {
                        store.send(.backButtonTapped)
                    }
                }
            }
        }
    }
}
//MARK: - Configure View
extension SignUpDoneView {
    private var logo: some View {
        HStack {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 70))
            
            Spacer()
        }
    }
    
    private var title: some View {
        VStack(spacing: 12) {
            Text("회원가입이 완료되었습니다!")
                .pokitFont(.title1)
                .foregroundStyle(.pokit(.text(.primary)))
            
            Text("POKIT을 통해 많은 링크를\n간편하게 관리하세요~!")
                .pokitFont(.title3)
                .foregroundStyle(.pokit(.text(.secondary)))
                .multilineTextAlignment(.center)
        }
    }
}
//MARK: - Preview
#Preview {
    SignUpDoneView(
        store: Store(
            initialState: .init(),
            reducer: { SignUpDoneFeature() }
        )
    )
}


