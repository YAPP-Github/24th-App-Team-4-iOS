//
//  AgreeToTermsFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import Foundation

import ComposableArchitecture
import Util

@Reducer
public struct AgreeToTermsFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var isAgreeAllTerms: Bool = false
        var isPersonalAndUsageArgee: Bool = false
        var isServiceAgree: Bool = false
        var isMarketingAgree: Bool = false
        
        var isWebViewPresented: Bool = false
        var webViewURL: URL? = nil
    }
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case nextButtonTapped
            case backButtonTapped
            case 개인정보_동의_버튼_클릭
            case 서비스_이용약관_버튼_클릭
            case 마케팅_정보_수신_버튼_클릭
        }
        public enum InnerAction: Equatable {
            case checkAgreements
            case personalAndUsageAgreeSelected
            case serviceAgreeSelected
            case marketingAgreeSelected
            case allAgreementSelected
        }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case pushRegisterNicknameView
        }
    }
    /// initiallizer
    public init() {}
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            /// - View
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
            /// - Inner
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
            /// - Async
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
            /// - Scope
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
            /// - Delegate
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension AgreeToTermsFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .nextButtonTapped:
            return .send(.delegate(.pushRegisterNicknameView))
        case .backButtonTapped:
            return .run { _ in await self.dismiss() }
        case .binding(\.isAgreeAllTerms):
            return .send(.inner(.allAgreementSelected))
        case .binding(\.isPersonalAndUsageArgee):
            return .send(.inner(.personalAndUsageAgreeSelected))
        case .binding(\.isServiceAgree):
            return .send(.inner(.serviceAgreeSelected))
        case .binding(\.isMarketingAgree):
            return .send(.inner(.marketingAgreeSelected))
        case .binding:
            return .none
        case .개인정보_동의_버튼_클릭:
            state.webViewURL = Constants.개인정보_처리방침_주소
            state.isWebViewPresented = true
            return .none
        case .서비스_이용약관_버튼_클릭:
            state.webViewURL = Constants.서비스_이용약관_주소
            state.isWebViewPresented = true
            return .none
        case .마케팅_정보_수신_버튼_클릭:
            state.webViewURL = Constants.마케팅_정보_수신_주소
            state.isWebViewPresented = true
            return .none
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - 개별 동의 체크 박스를 확인 하여 전체 동의 체크 여부 결정
        case .checkAgreements:
            let isAgreeAllterm = state.isPersonalAndUsageArgee
            && state.isServiceAgree
            && state.isMarketingAgree
            state.isAgreeAllTerms = isAgreeAllterm
            return .none
        /// - 각각의 개별 동의 체크박스가 선택 되었을 때
        case .personalAndUsageAgreeSelected,
                .serviceAgreeSelected,
                .marketingAgreeSelected:
            return .send(.inner(.checkAgreements))
        /// - 전체 동의 체크박으가 선택 되었을 때
        case .allAgreementSelected:
            state.isPersonalAndUsageArgee = state.isAgreeAllTerms
            state.isServiceAgree          = state.isAgreeAllTerms
            state.isMarketingAgree        = state.isAgreeAllTerms
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
