//
//  PokitTextChip.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitTextChip: View {
    @State private var state: PokitButtonStyle.State
    
    private let labelText: String
    private let baseState: PokitButtonStyle.State
    private let selectedState: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        baseState: PokitButtonStyle.State,
        selectedState: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        action: @escaping () -> Void
    ) {
        self.state = baseState
        self.baseState = baseState
        self.selectedState = selectedState
        self.labelText = labelText
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        PokitTextButton(
            labelText,
            state: state,
            size: size
        ) {
            pokitTextButtonTapped()
            
            action()
        }
        .background(shape: .round)
    }
    
    private func pokitTextButtonTapped() {
        state = state == baseState ? selectedState : baseState
    }
}