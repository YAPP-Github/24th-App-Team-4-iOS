//
//  SearchView.swift
//  Feature
//
//  Created by 김도형 on 7/26/24.

import SwiftUI

import ComposableArchitecture
import DSKit

@ViewAction(for: SearchFeature.self)
public struct SearchView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<SearchFeature>
    @FocusState
    private var focused: Bool
    @State
    private var recentSearchListHeight: CGFloat = 0
    
    /// - Initializer
    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SearchView {
    var body: some View {
        WithPerceptionTracking {
            VStack {
                navigationBar
                
                recentSearch
                    .padding(.top, 20)
                
                PokitDivider()
                    .padding(.top, 28)
                
                Spacer()
            }
        }
    }
}
//MARK: - Configure View
private extension SearchView {
    var navigationBar: some View {
        HStack(spacing: 8) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: {}
            )
            
            PokitIconRInput(
                text: $store.searchText,
                icon: store.isSearching ? .icon(.x) : .icon(.search),
                shape: .round,
                focusState: $focused,
                equals: true,
                onSubmit: { send(.searchTextInputOnSubmitted) },
                iconTappedAction: store.isSearching ? { send(.searchTextInputIconTapped) } : nil
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
    }
    
    var recentSearch: some View {
        VStack(spacing: 20) {
            HStack(spacing: 4) {
                Text("최근 검색어")
                    .pokitFont(.b2(.b))
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Spacer()
                
                PokitTextLink(
                    "전체 삭제",
                    color: .text(.tertiary),
                    action: {}
                )
                
                Text("|")
                    .pokitFont(.b3(.m))
                    .foregroundStyle(.pokit(.text(.tertiary)))
                
                PokitTextLink(
                    "자동저장 \(store.isAutoSaveSearch ? "끄기" : "켜기")",
                    color: .text(.tertiary),
                    action: { send(.autoSaveButtonTapped, animation: .pokitSpring) }
                )
                .contentTransition(.numericText())
            }
            .padding(.horizontal, 20)
            
            if store.isSearching {
                filterToolbar
            } else if store.isAutoSaveSearch {
                if store.recentSearchTexts.isEmpty {
                    Text("검색 내역이 없습니다.")
                        .pokitFont(.b3(.r))
                        .foregroundStyle(.pokit(.text(.tertiary)))
                        .pokitBlurReplaceTransition(.smooth)
                        .padding(.vertical, 5)
                } else {
                    recentSearchList
                }
            } else {
                Text("최근 검색 저장 기능이 꺼져있습니다.")
                    .pokitFont(.b3(.r))
                    .foregroundStyle(.pokit(.text(.tertiary)))
                    .pokitBlurReplaceTransition(.smooth)
                    .padding(.vertical, 5)
            }
        }
    }
    
    var recentSearchList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(store.recentSearchTexts, id: \.self) { text in
                    PokitIconRChip(
                        text,
                        state: .default(.primary),
                        size: .small,
                        action: { send(.searchTextChipButtonTapped(text: text)) }
                    )
//                    .pokitScrollTransition(.horizontal)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 1)
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .opacity
            )
        )
    }
    
    var filterToolbar: some View {
        HStack(spacing: 0) {
            filterButton
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    pokitFilterButton
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
            }
        }
        .padding(.leading, 20)
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing).animation(.pokitSpring),
                removal: .opacity.animation(.smooth)
            )
        )
    }
    
    var filterButton: some View {
        PokitIconLButton(
            "필터",
            .icon(.filter),
            state: .stroke(.secondary),
            size: .small,
            shape: .round,
            action: { }
        )
    }
    
    var pokitFilterButton: some View {
        PokitIconRButton(
            store.pokitFilter ?? "포킷명",
            .icon(.arrowDown),
            state: store.pokitFilter == nil ? .default(.primary) : .stroke(.primary),
            size: .small,
            shape: .round,
            action: {}
        )
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        SearchView(
            store: Store(
                initialState: .init(),
                reducer: { SearchFeature()._printChanges() }
            )
        )
    }
}


