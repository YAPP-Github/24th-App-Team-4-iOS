//
//  IntroFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import ComposableArchitecture
import CoreKit
import FeatureLogin

@Reducer
public struct IntroFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public enum State {
        case splash(SplashFeature.State = .init())
        case login(LoginRootFeature.State = .init())
        public init() { self = .splash() }
    }
    /// - Action
    public enum Action {
        case _sceneChange(State)
        case splash(SplashFeature.Action)
        case login(LoginRootFeature.Action)
        case delegate(Delegate)
        
        public enum Delegate {
            case moveToTab
        }
    }
    /// initiallizer
    public init() {}
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let ._sceneChange(newState):
            state = newState
            return .none
        case .splash(let splashAction):
            return splashDelegate(splashAction, state: &state)
        case .login(.scope(.signUpDone(.dismissLoginRootView))):
            return .run { send in await send(.delegate(.moveToTab)) }
        case .delegate, .login:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifCaseLet(\.splash, action: \.splash) { SplashFeature() }
            .ifCaseLet(\.login, action: \.login) { LoginRootFeature() }
    }
}
//MARK: - FeatureAction Effect
private extension IntroFeature {
    /// - Splash Action Delegate
    func splashDelegate(_ action: SplashFeature.Action, state: inout State) -> Effect<Action> {
        switch action {
        case .delegate(.autoLoginSuccess):
            return .run { send in
                await send(.delegate(.moveToTab), animation: .spring)
            }
            
        case .delegate(.loginNeeded):
            return .run { send in
                /// Todo: 원하는 애니메이션 넣어줘~
                await send(._sceneChange(.login()), animation: .spring)
            }
        default: return .none
        }
    }
}