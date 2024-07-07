//
//  SelectFieldView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI
import DSKit

public struct SelectFieldView: View {
    /// - Properties
    private let store: StoreOf<SelectFieldFeature>
    /// - Initializer
    public init(store: StoreOf<SelectFieldFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SelectFieldView {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                title
                    .padding(.top, 16)
                
                fieldsFlow
                    .padding(.top, 36)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            PokitBottomButton(
                "다음",
                state: store.selectedFields.count == 0 ? .disable : .filled(.primary)
            ) {
                store.send(.nextButtonTapped)
            }
        }
        .background(.pokit(.bg(.base)))
        .pokitNavigationBar(title: "")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PokitToolbarButton(.icon(.arrowLeft)) {
                    store.send(.backButtonTapped)
                }
            }
        }
    }
    
    private var title: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("어떤 분야에 관심이 있으세요?")
                .pokitFont(.title1)
                .foregroundStyle(.pokit(.text(.primary)))
            
            Text("최대 3개를 골라주시면\n관련 콘텐츠를 추천해드릴게요!")
                .pokitFont(.title3)
                .foregroundStyle(.pokit(.text(.secondary)))
        }
    }
    
    private var fieldsFlow: some View {
        PokitFlowLayout(rowSpacing: 12, colSpacing: 10) {
            ForEach(store.fields, id: \.self) { field in
                let isSelected = store.selectedFields.contains(field)
                
                PokitTextChip(
                    field,
                    state: isSelected ? .filled(.primary) : .default(.primary),
                    size: .medium
                ) {
                    store.send(.fieldChipTapped(isSelected, field))
                }
            }
        }
    }
}
//MARK: - Configure View
extension SelectFieldView {
    
}
//MARK: - Preview
#Preview {
    NavigationStack {
        SelectFieldView(
            store: Store(
                initialState: .init(),
                reducer: { SelectFieldFeature() }
            )
        )
    }
}


