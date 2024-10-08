//
//  SocialLoginClient.swift
//  CoreKit
//
//  Created by 김민호 on 6/25/24.
//

import Foundation
import Dependencies

public struct SocialLoginClient {
    public var appleLogin: @Sendable () async throws -> SocialLoginInfo
    public var googleLogin: @Sendable () async throws -> SocialLoginInfo
    public var getClientSceret: @Sendable () -> String
}

extension SocialLoginClient: DependencyKey {
    public static let liveValue: Self = {
        let appleLoginController = AppleLoginController()
        let googleLoginController = GoogleLoginController()

        return Self(
            appleLogin: {
                try await appleLoginController.login()
            },
            googleLogin: {
                try await googleLoginController.login()
            },
            getClientSceret: {
                return appleLoginController.makeJWT()
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            appleLogin: { .appleMock },
            googleLogin: { .googleMock },
            getClientSceret: { "" }
        )
    }()
}

extension DependencyValues {
    public var socialLogin: SocialLoginClient {
        get { self[SocialLoginClient.self] }
        set { self[SocialLoginClient.self] = newValue }
    }
}
