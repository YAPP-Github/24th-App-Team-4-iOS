//
//  PokitSelect.swift
//  DSKit
//
//  Created by 김도형 on 6/29/24.
//

import SwiftUI

import Util

public struct PokitSelect<Item: PokitSelectItem>: View {
    @Binding
    private var selectedItem: Item?
    @State
    private var state: PokitSelect.SelectState
    @State
    private var showSheet: Bool = false
    
    private let label: String
    private let list: [Item]?
    private let action: (Item) -> Void
    
    public init(
        selectedItem: Binding<Item?> = .constant(nil),
        state: PokitSelect.SelectState = .default,
        label: String,
        list: [Item]?,
        action: @escaping (Item) -> Void
    ) {
        self._selectedItem = selectedItem
        if selectedItem.wrappedValue != nil {
            self.state = .input
        } else {
            self._state = State(initialValue: state)
        }
        self.label = label
        self.list = list
        self.action = action
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            PokitLabel(text: label, size: .large)
            
            partSelectButton
        }
        .onChange(of: selectedItem) { onChangedSeletedItem($0) }
        .sheet(isPresented: $showSheet) {
            listSheet
                .presentationDragIndicator(.visible)
                .pokitPresentationCornerRadius()
                .presentationDetents([.medium])
                .pokitPresentationBackground()
        }
    }
    
    private var partSelectButton: some View {
        Button {
            partSelectButtonTapped()
        } label: {
            partSelectLabel
        }
        .disabled(self.state == .disable || self.state == .readOnly)
    }
    
    private var partSelectLabel: some View {
        HStack {
            Text(self.selectedItem?.categoryName ?? "선택해주세요.")
                .pokitFont(.b3(.m))
                .foregroundStyle(self.state.textColor)
                .contentTransition(.numericText())
            
            Spacer()
            
            Image(.icon(.arrowDown))
                .resizable()
                .foregroundStyle(self.state.iconColor)
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(self.state.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
            }
            .animation(.pokitDissolve, value: self.state)
    }
    
    private var listSheet: some View {
        Group {
            if let list {
                PokitList(
                    selectedItem: selectedItem,
                    list: list
                ) { item in
                    action(item)
                    listCellTapped(item)
                }
                .padding(.top, 36)
                .padding(.bottom, 20)
            } else {
                PokitLoading()
            }
        }
    }
    
    private func partSelectButtonTapped() {
        showSheet = true
    }
    
    private func listCellTapped(_ item: Item) {
        withAnimation(.pokitDissolve) {
            self.selectedItem = item
        }
        showSheet = false
    }
    
    private func onChangedSeletedItem(_ newValue: Item?) {
        state = newValue != nil ? .input : .default
    }
}

public extension PokitSelect {
    enum SelectState {
        case `default`
        case input
        case disable
        case readOnly
        
        var backgroundColor: Color {
            switch self {
            case .default, .input:
                return .pokit(.bg(.base))
            case .disable:
                return .pokit(.bg(.disable))
            case .readOnly:
                return .pokit(.bg(.secondary))
            }
        }
        
        var backgroundStrokeColor: Color {
            switch self {
            case .default, .input, .readOnly:
                return .pokit(.border(.secondary))
            case .disable:
                return .pokit(.border(.disable))
            }
        }
        
        var iconColor: Color {
            switch self {
            case .default, .readOnly, .input:
                return .pokit(.icon(.secondary))
            case .disable:
                return .pokit(.icon(.disable))
            }
        }
        
        var textColor: Color {
            switch self {
            case .default, .readOnly: return .pokit(.text(.tertiary))
            case .input: return .pokit(.text(.secondary))
            case .disable: return .pokit(.text(.disable))
            }
        }
    }
}
