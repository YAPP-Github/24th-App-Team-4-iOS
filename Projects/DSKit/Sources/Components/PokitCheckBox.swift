//
//  PokitCheckBox.swift
//  DSKit
//
//  Created by 김도형 on 6/29/24.
//

import SwiftUI

public struct PokitCheckBox: View {
    @Binding private var isSelected: Bool
    
    @State private var state: PokitCheckBox.CheckBoxState
    
    private let baseState: PokitCheckBox.CheckBoxState
    private let selectedState: PokitCheckBox.CheckBoxState
    private let shape: PokitCheckBox.Shape
    private let action: (() -> Void)?
    
    public init(
        baseState: PokitCheckBox.CheckBoxState,
        selectedState: PokitCheckBox.CheckBoxState,
        isSelected: Binding<Bool>,
        shape: PokitCheckBox.Shape,
        action: (() -> Void)? = nil
    ) {
        self.state = baseState
        self.baseState = baseState
        self._isSelected = isSelected
        self.selectedState = selectedState
        self.shape = shape
        self.action = action
    }
    
    public var body: some View {
        button
    }
    
    private var button: some View {
        Button {
            buttonTapped()
        } label: {
            Image(.icon(.check))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(self.state.iconColor)
        }
        .disabled(self.state == .disable)
        .background(background)
        .frame(width: 24, height: 24)
        .onChange(of: isSelected) { onChangedIsSelected($0) }
        .onAppear { onChangedIsSelected(isSelected) }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: self.shape.radius, style: .continuous)
            .fill(self.state.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: self.shape.radius, style: .continuous)
                    .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
            }
            .animation(.pokitDissolve, value: self.state)
    }
    
    private func buttonTapped() {
        withAnimation(.pokitDissolve) {
            isSelected.toggle()
        }
        action?()
    }
    
    private func onChangedIsSelected(_ newValue: Bool) {
        state = newValue ? selectedState : baseState
    }
}

public extension PokitCheckBox {
    enum CheckBoxState {
        case `default`
        case filled
        case stroke
        case disable
        case iconOnly
        case iconOnlyDefault
        
        var backgroundColor: Color {
            switch self {
            case .default, .stroke: return .pokit(.bg(.base))
            case .filled: return .pokit(.bg(.brand))
            case .disable: return .pokit(.bg(.disable))
            case .iconOnly, .iconOnlyDefault: return .clear
            }
        }
        
        var backgroundStrokeColor: Color {
            switch self {
            case .default: return .pokit(.border(.secondary))
            case .filled, .stroke: return .pokit(.border(.brand))
            case .disable: return .pokit(.border(.disable))
            case .iconOnly, .iconOnlyDefault: return .clear
            }
        }
        
        var iconColor: Color {
            switch self {
            case .default: return .pokit(.icon(.tertiary))
            case .filled: return .pokit(.icon(.inverseWh))
            case .stroke: return .pokit(.icon(.brand))
            case .disable: return .pokit(.icon(.disable))
            case .iconOnly: return .pokit(.icon(.brand))
            case .iconOnlyDefault: return .pokit(.icon(.tertiary))
            }
        }
    }
    
    enum Shape {
        case rectangle
        case round
        
        var radius: CGFloat {
            switch self {
            case .rectangle: return 4
            case .round: return 9999
            }
        }
    }
}
