//
//  SearchFeature.swift
//  Feature
//
//  Created by 김도형 on 7/26/24.

import Foundation

import ComposableArchitecture
import Util

@Reducer
public struct SearchFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {
            self.resultMock = .init()
            SearchMock.resultMock.forEach{ resultMock.append($0) }
        }
        
        var searchText: String = ""
        var recentSearchTexts: [String] = [
            "샤프 노트북",
            "아이패드",
            "맥북",
            "LG 그램",
            "LG 그램1",
            "LG 그램2",
            "LG 그램3",
            "LG 그램4",
            "LG 그램5",
            "LG 그램6",
            "LG 그램7"
        ]
        var isAutoSaveSearch: Bool = false
        var isSearching: Bool = false
        var resultMock: IdentifiedArrayOf<SearchMock>
        var isFiltered: Bool = false
        var pokitFilter: String? = nil
        var linkTypeFilter: [String] = []
        var startDateFilter: Date? = nil
        var endDateFilter: Date? = nil
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
            case autoSaveButtonTapped
            case searchTextInputIconTapped
            case searchTextChipButtonTapped(text: String)
            /// - TextInput OnSubmitted
            case searchTextInputOnSubmitted
        }
        
        public enum InnerAction: Equatable {
            case enableIsSearching
            case disableIsSearching
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable { case doNothing }
    }
    
    /// - Initiallizer
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
private extension SearchFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.searchText):
            guard !state.searchText.isEmpty else {
                /// 🚨 Error Case [1]: 빈 문자열 일 때
                return .send(.inner(.disableIsSearching), animation: .pokitSpring)
            }
            return .none
        case .binding:
            return .none
        case .autoSaveButtonTapped:
            state.isAutoSaveSearch.toggle()
            return .none
        case .searchTextInputOnSubmitted:
            return .run { send in
                // - TODO: 검색 조회
                await send(.inner(.enableIsSearching), animation: .pokitSpring)
            }
        case .searchTextInputIconTapped:
            /// - 검색 중일 경우 `문자열 지우기 버튼 동작`
            if state.isSearching {
                state.searchText = ""
                return .send(.inner(.disableIsSearching), animation: .pokitSpring)
            } else {
                return .run { send in
                    // - TODO: 검색 조회
                    await send(.inner(.enableIsSearching), animation: .pokitSpring)
                }
            }
        case .searchTextChipButtonTapped(text: let text):
            state.searchText = text
            return .run { send in
                // - TODO: 검색 조회
                await send(.inner(.enableIsSearching), animation: .pokitSpring)
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .enableIsSearching:
            state.isSearching = true
            return .none
        case .disableIsSearching:
            state.isSearching = false
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
