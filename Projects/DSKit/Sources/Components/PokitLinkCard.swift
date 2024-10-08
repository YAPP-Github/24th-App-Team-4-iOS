//
//  PokitLinkCard.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

import Util
import NukeUI

public struct PokitLinkCard<Item: PokitLinkCardItem>: View {
    private let link: Item
    private let action: () -> Void
    private let kebabAction: (() -> Void)?
    
    public init(
        link: Item,
        action: @escaping () -> Void,
        kebabAction: (() -> Void)? = nil
    ) {
        self.link = link
        self.action = action
        self.kebabAction = kebabAction
    }
    
    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
    }
    
    @MainActor
    private var buttonLabel: some View {
        HStack(spacing: 12) {
            thumbleNail
            
            VStack(spacing: 8) {
                HStack {
                    title
                    
                    Spacer(minLength: kebabAction != nil ? 24 : 0)
                }
                
                HStack {
                    subTitle
                    
                    Spacer()
                }
                
                HStack {
                    badges()
                    
                    Spacer()
                }
            }
            .overlay(alignment: .topTrailing) {
                if let kebabAction {
                    kebabButton(kebabAction)
                }
            }
        }
    }
    
    private var title: some View {
        Text(link.title)
            .pokitFont(.b3(.b))
            .foregroundStyle(.pokit(.text(.primary)))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
    }
    
    private var subTitle: some View {
        Text("\(link.createdAt) • \(link.domain)")
            .pokitFont(.detail2)
            .foregroundStyle(.pokit(.text(.tertiary)))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private func badges() -> some View {
        let isUnCategorized = link.categoryName == "미분류"
        
        HStack(spacing: 6) {
            PokitBadge(
                link.categoryName,
                state: isUnCategorized ? .unCategorized : .default
            )
            
            if let isRead = link.isRead, !isRead {
                PokitBadge("안읽음", state: .unRead)
            }
        }
    }
    
    @ViewBuilder
    private func kebabButton(_ kebabAction: @escaping () -> Void) -> some View {
        Button(action: kebabAction) {
            Image(.icon(.kebab))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.pokit(.icon(.primary)))
        }
    }
    
    @MainActor
    private var thumbleNail: some View {
        LazyImage(url: .init(string: link.thumbNail)) { phase in
            Group {
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Color.pokit(.bg(.disable))
                        
                        PokitSpinner()
                            .foregroundStyle(.pokit(.icon(.brand)))
                            .frame(width: 48, height: 48)
                    }
                }
            }
            .animation(.pokitDissolve, value: phase.image)
        }
        .frame(width: 124, height: 94)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private var divider: some View {
        Rectangle()
            .fill(.pokit(.color(.grayScale(._100))))
            .frame(height: 1)
    }
    
    @ViewBuilder
    public func divider(isFirst: Bool, isLast: Bool) -> some View {
        let edge: Edge.Set = isFirst ? .bottom : isLast ? .top : .vertical
        
        self
            .padding(edge, 20)
            .background(alignment: .bottom) {
                if !isLast {
                    divider
                }
            }
    }
}
