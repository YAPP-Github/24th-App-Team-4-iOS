//
//  CategoryDetailView.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import SwiftUI

import ComposableArchitecture
import DSKit
import Util

@ViewAction(for: CategoryDetailFeature.self)
public struct CategoryDetailView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<CategoryDetailFeature>
    
    /// - Initializer
    public init(store: StoreOf<CategoryDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension CategoryDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                header
                linkScrollView
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden()
            .toolbar { self.navigationBar }
            .sheet(isPresented: $store.isCategorySheetPresented) {
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224,
                    delegateSend: { store.send(.scope(.categoryBottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isCategorySelectSheetPresented) {
                PokitCategorySheet(
                    selectedItem: nil,
                    list: CategoryItemMock.addLinkMock,
                    action: { send(.categorySelected($0)) }
                )
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: store.kebobSelectedType ?? .포킷삭제,
                    delegateSend: { store.send(.scope(.categoryDeleteBottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isFilterSheetPresented) {
                CategoryFilterSheet(
                    delegateSend: { store.send(.scope(.filterBottomSheet($0))) }
                )
            }
            .onAppear { send(.onAppear) }
        }
    }
}
//MARK: - Configure View
private extension CategoryDetailView {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.dismiss) }
            )
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            PokitToolbarButton(.icon(.kebab), action: { send(.categoryKebobButtonTapped(.포킷삭제, selectedItem: nil)) })
        }
    }
    
    var header: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                /// cateogry title
                Button(action: { send(.categorySelectButtonTapped) }) {
                    Text("포킷")
                        .foregroundStyle(.pokit(.text(.primary)))
                        .pokitFont(.title1)
                    Image(.icon(.arrowDown))
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                }
                .buttonStyle(.plain)
            }
            HStack {
                Text("링크 14개")
                Spacer()
                PokitIconLButton(
                    "필터",
                    .icon(.filter),
                    state: .filled(.primary),
                    size: .small,
                    shape: .round,
                    action: { send(.filterButtonTapped) }
                )
            }
        }
    }
    
    var linkScrollView: some View {
        ScrollView(showsIndicators: false) {
            ForEach(store.mock) { link in
                let isFirst = link == store.mock.first
                let isLast = link == store.mock.last
                
                PokitLinkCard(
                    link: link,
                    action: { send(.linkItemTapped(link)) }, 
                    kebabAction: { send(.categoryKebobButtonTapped(.링크삭제, selectedItem: link)) }
                )
                .divider(isFirst: isFirst, isLast: isLast)
            }
        }
        .animation(.spring, value: store.mock.elements)
    }
    
    struct PokitCategorySheet: View {
        @State private var height: CGFloat = 0
        var action: (CategoryItemMock) -> Void
        var selectedItem: CategoryItemMock?
        var list: [CategoryItemMock]
        
        public init(
            selectedItem: CategoryItemMock?,
            list: [CategoryItemMock],
            action: @escaping (CategoryItemMock) -> Void
        ) {
            self.selectedItem = selectedItem
            self.list = list
            self.action = action
        }
        
        var body: some View {
            PokitList(
                selectedItem: selectedItem,
                list: list,
                action: action
            )
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        CategoryDetailView(
            store: Store(
                initialState: .init(mock: DetailItemMock.recommendedMock),
                reducer: { CategoryDetailFeature() }
            )
        )
    }
}


