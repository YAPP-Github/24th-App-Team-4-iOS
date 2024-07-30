//
//  RemindFeature.swift
//  Feature
//
//  Created by 김도형 on 7/12/24.

import ComposableArchitecture
import Util
import DSKit

@Reducer
public struct RemindFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var recommendedLinks = LinkMock.recommendedMock
        var unreadLinks = LinkMock.unreadMock
        var favoriteLinks = LinkMock.favoriteMock
        /// sheet item
        var bottomSheetItem: LinkMock? = nil
        var alertItem: LinkMock? = nil
    }
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            /// - Button Tapped
            case bellButtonTapped
            case searchButtonTapped
            case linkCardTapped(link: LinkMock)
            case kebabButtonTapped(link: LinkMock)
            case unreadNavigationLinkTapped
            case favoriteNavigationLinkTapped
            case bottomSheetButtonTapped(
                delegate: PokitBottomSheet.Delegate,
                link: LinkMock
            )
            case deleteAlertConfirmTapped(link: LinkMock)
        }
        public enum InnerAction: Equatable {
            case dismissBottomSheet
        }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable {
            case bottomSheet(
                delegate: PokitBottomSheet.Delegate,
                link: LinkMock
            )
        }
        public enum DelegateAction: Equatable {
            case showLinkDetailView(link: LinkMock)
            case pushAddLinkView(link: LinkMock)
            case bellButtonTapped
            case searchButtonTapped
            case 링크수정(link: LinkMock)
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
private extension RemindFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .bellButtonTapped:
            return .run { send in await send(.delegate(.bellButtonTapped)) }
        case .searchButtonTapped:
            return .run { send in await send(.delegate(.searchButtonTapped)) }
        case .favoriteNavigationLinkTapped:
            return .none
        case .unreadNavigationLinkTapped:
            return .none
        case .kebabButtonTapped(let link):
            state.bottomSheetItem = link
            return .none
        case .linkCardTapped(let link):
            return .send(.delegate(.pushAddLinkView(link: link)))
        case .bottomSheetButtonTapped(let delegate, let link):
            return .run { send in
                await send(.inner(.dismissBottomSheet))
                await send(.scope(.bottomSheet(delegate: delegate, link: link)))
            }
        case .deleteAlertConfirmTapped:
            state.alertItem = nil
            return .none
        case .binding:
            return .none
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dismissBottomSheet:
            state.bottomSheetItem = nil
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        /// - 링크에 대한 `공유` /  `수정` / `삭제` delegate
        switch action {
        case .bottomSheet(let delegate, let link):
            switch delegate {
            case .deleteCellButtonTapped:
                state.alertItem = link
                return .none
            case .editCellButtonTapped:
                return .send(.delegate(.링크수정(link: link)))
            case .favoriteCellButtonTapped:
                return .none
            case .shareCellButtonTapped:
                return .none
            }
        }
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
