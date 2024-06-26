//
//  PokitIconButton.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

public struct PokitIconButton: View {
    private let labelIcon: PokitImage
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let action: () -> Void
    
    public init(
        _ labelIcon: PokitImage,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        action: @escaping () -> Void
    ) {
        self.labelIcon = labelIcon
        self.state = state
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
        .disabled(state == .disable)
    }
    
    private var label: some View {
        Image(self.labelIcon)
            .resizable()
            .frame(width: self.size.iconSize.width, height: self.size.iconSize.height)
            .foregroundStyle(self.state.iconColor)
            .padding(self.size.vPadding)
    }
    
    public func background(
        shape: PokitButtonStyle.Shape
    ) -> some View {
        self
            .pokitButtonBackground(
                state: self.state,
                shape: shape
            )
    }
}

#Preview {
    PokitIconButton(
        .icon(.search),
        state: .filled(.primary),
        size: .large
    ) {
        
    }
    .background(shape: .round)
}
