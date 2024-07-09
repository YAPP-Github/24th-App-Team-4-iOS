//
//  Target+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도형 on 6/18/24.
//

import ProjectDescription

public extension Target {
    static var settings: Settings {
        let base = SettingsDictionary().otherLinkerFlags(["-ObjC"])
        
        return .settings(base: base, configurations: [.debug(name: .debug), .release(name: .release)])
    }
    
    static func makeTarget(
        name: String,
        product: Product,
        bundleName: String, 
        dependencies: [TargetDependency]
    ) -> Target {
        return .target(
            name: name,
            destinations: .appDestinations,
            product: product,
            bundleId: .moduleBundleId(name: bundleName),
            deploymentTargets: .appMinimunTarget,
            sources: ["\(name)/Sources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }
    
    static func makeChildTarget(
        name: String,
        product: Product,
        bundleName: String,
        dependencies: [TargetDependency]
    ) -> Target {
        return .target(
            name: "\(name)",
            destinations: .appDestinations,
            product: product,
            bundleId: .moduleBundleId(name: bundleName),
            deploymentTargets: .appMinimunTarget,
            sources: ["Sources/\(name)/Sources/**"],
            dependencies: dependencies
        )
    }
}
