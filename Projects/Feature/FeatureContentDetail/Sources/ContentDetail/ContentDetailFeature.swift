//
//  LinkDetailFeature.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import UIKit

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct ContentDetailFeature {
    /// - Dependency
    @Dependency(\.linkPresentation)
    private var linkPresentation
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.contentClient)
    private var contentClient
    @Dependency(\.categoryClient)
    private var categoryClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(contentId: Int) {
            self.domain = .init(contentId: contentId)
        }
        fileprivate var domain: ContentDetail
        var content: BaseContentDetail? {
            get { domain.content }
        }
        var category: BaseCategory? {
            get { domain.category }
        }
        var linkTitle: String? = nil
        var linkImage: UIImage? = nil
        var showAlert: Bool = false
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
            /// - View OnAppeared
            case contentDetailViewOnAppeared
            /// - Button Tapped
            case sharedButtonTapped
            case editButtonTapped
            case deleteButtonTapped
            case deleteAlertConfirmTapped
            case favoriteButtonTapped
        }
        
        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, image: UIImage?)
            case parsingURL
            case dismissAlert
            case 컨텐츠_상세_조회(content: BaseContentDetail)
            case 즐겨찾기_갱신(Bool)
            case 카테고리_갱신(BaseCategory)
        }
        
        public enum AsyncAction: Equatable {
            case 컨텐츠_상세_조회(id: Int)
            case 즐겨찾기(id: Int)
            case 즐겨찾기_취소(id: Int)
            case 카테고리_상세_조회(id: Int)
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case editButtonTapped(contentId: Int)
        }
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
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension ContentDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .contentDetailViewOnAppeared:
            return .run { [id = state.domain.contentId] send in
                await send(.async(.컨텐츠_상세_조회(id: id)))
            }
        case .sharedButtonTapped:
            return .none
        case .editButtonTapped:
            guard let content = state.domain.content else { return .none }
            return .run { [content] send in
//                await dismiss()
                await send(.delegate(.editButtonTapped(contentId: content.id)))
            }
        case .deleteButtonTapped:
            state.showAlert = true
            return .none
        case .deleteAlertConfirmTapped:
            return .run { send in
                //TODO: 링크 삭제
                await send(.inner(.dismissAlert))
                await dismiss()
            }
        case .binding:
            return .none
        case .favoriteButtonTapped:
            guard let content = state.domain.content else {
                return .none
            }
            return .run { [content] send in
                if content.favorites {
                    await send(.async(.즐겨찾기_취소(id: content.id)))
                } else {
                    await send(.async(.즐겨찾기(id: content.id)))
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                /// - 링크에 대한 메타데이터의 제목 및 썸네일 항목 파싱
                let (title, item) = await linkPresentation.provideMetadata(url)
                /// - 썸네일을 `UIImage`로 변환
                let image = linkPresentation.convertImage(item)
                await send(
                    .inner(.parsingInfo(title: title, image: image)),
                    animation: .smooth
                )
            }
        case .parsingInfo(title: let title, image: let image):
            state.linkTitle = title
            state.linkImage = image
            return .none
        case .parsingURL:
            guard let urlString = state.domain.content?.data,
                  let url = URL(string: urlString) else {
                /// 🚨 Error Case [1]: 올바른 링크가 아닐 때
                state.linkTitle = nil
                state.linkImage = nil
                return .none
            }
            return .send(.inner(.fetchMetadata(url: url)), animation: .smooth)
        case .dismissAlert:
            state.showAlert = false
            return .none
        case .컨텐츠_상세_조회(content: let content):
            state.domain.content = content
            return .send(.inner(.parsingURL))
        case .즐겨찾기_갱신(let favorite):
            state.domain.content?.favorites = favorite
            return .none
        case .카테고리_갱신(let category):
            state.domain.category = category
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .컨텐츠_상세_조회(id: let id):
            return .run { [id] send in
                let contentResponse = try await contentClient.컨텐츠_상세_조회("\(id)").toDomain()
                await send(.inner(.컨텐츠_상세_조회(content: contentResponse)))
                await send(.async(.카테고리_상세_조회(id: contentResponse.categoryId)))
            }
        case .즐겨찾기(id: let id):
            return .run { [id] send in
                let _ = try await contentClient.즐겨찾기("\(id)")
                await send(.inner(.즐겨찾기_갱신(true)))
            }
        case .즐겨찾기_취소(id: let id):
            return .run { [id] send in
                let _ = try await contentClient.즐겨찾기_취소("\(id)")
                await send(.inner(.즐겨찾기_갱신(false)))
            }
        case .카테고리_상세_조회(id: let id):
            return .run { [id] send in
                let category = try await categoryClient.카테고리_상세_조회("\(id)").toDomain()
                await send(.inner(.카테고리_갱신(category)))
            }
        }
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
