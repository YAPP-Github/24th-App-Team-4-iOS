//
//  PokitScrollTransitionModifier.swift
//  DSKit
//
//  Created by 김도형 on 7/26/24.
//

import SwiftUI

struct PokitScrollTransitionModifier: ViewModifier {
    private let axes: Axis.Set
    
    init(_ axes: Axis.Set) {
        self.axes = axes
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .scrollTransition(.animated(.pokitSpring)) { view, transition in
                    switch axes {
                    case .horizontal:
                        view
                            .offset(x: transition.isIdentity ? 0 : CGFloat(transition.value * 100))
                    case .vertical:
                        view
                            .offset(y: transition.isIdentity ? 0 : CGFloat(transition.value * 200))
                    default:
                        view
                            .offset(y: transition.isIdentity ? 0 : CGFloat(transition.value * 200))
                    }
                    
                }
        } else {
            content
        }
    }
}

public extension View {
    func pokitScrollTransition(_ axes: Axis.Set = .vertical) -> some View {
        modifier(PokitScrollTransitionModifier(axes))
    }
}
