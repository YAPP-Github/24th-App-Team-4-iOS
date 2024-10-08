//
//  BaseResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

public struct ErrorResponse: Error, Decodable {
    public let message: String
    public let code: String
    static let base = ErrorResponse(message: "기본에러입니다", code: "CODE")
}
