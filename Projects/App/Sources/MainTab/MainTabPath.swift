//
//  MainTabPath.swift
//  App
//
//  Created by 김민호 on 7/29/24.
//

import Foundation

import ComposableArchitecture
import FeatureSetting
import FeatureCategoryDetail
import FeatureCategorySetting
import FeatureContentDetail
import FeatureContentSetting
import FeatureContentList

@Reducer
public struct MainTabPath {
    @ObservableState
    public enum State: Equatable {
        case 알림함(PokitAlertBoxFeature.State)
        case 검색(PokitSearchFeature.State)
        case 설정(PokitSettingFeature.State)
        case 포킷추가및수정(PokitCategorySettingFeature.State)
        case 링크추가및수정(ContentSettingFeature.State)
        case 카테고리상세(CategoryDetailFeature.State)
        case 링크목록(ContentListFeature.State)
    }

    public enum Action {
        case 알림함(PokitAlertBoxFeature.Action)
        case 검색(PokitSearchFeature.Action)
        case 설정(PokitSettingFeature.Action)
        case 포킷추가및수정(PokitCategorySettingFeature.Action)
        case 링크추가및수정(ContentSettingFeature.Action)
        case 카테고리상세(CategoryDetailFeature.Action)
        case 링크목록(ContentListFeature.Action)
    }

    public var body: some Reducer<State, Action> {
        Scope(state: \.알림함, action: \.알림함) { PokitAlertBoxFeature() }
        Scope(state: \.검색, action: \.검색) { PokitSearchFeature() }
        Scope(state: \.설정, action: \.설정) { PokitSettingFeature() }
        Scope(state: \.포킷추가및수정, action: \.포킷추가및수정) { PokitCategorySettingFeature() }
        Scope(state: \.링크추가및수정, action: \.링크추가및수정) { ContentSettingFeature() }
        Scope(state: \.카테고리상세, action: \.카테고리상세) { CategoryDetailFeature() }
        Scope(state: \.링크목록, action: \.링크목록) { ContentListFeature() }
    }
}

public extension MainTabFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            /// - 네비게이션 바 `알림`버튼 눌렀을 때
            case .pokit(.delegate(.alertButtonTapped)),
                 .remind(.delegate(.alertButtonTapped)):
                state.path.append(.알림함(PokitAlertBoxFeature.State(alertItems: AlertMock.mock)))
                return .none

            /// - 네비게이션 바 `검색`버튼 눌렀을 때
            case .pokit(.delegate(.searchButtonTapped)),
                 .remind(.delegate(.searchButtonTapped)):
                state.path.append(.검색(PokitSearchFeature.State()))
                return .none

            /// - 네비게이션 바 `설정`버튼 눌렀을 때
            case .pokit(.delegate(.settingButtonTapped)):
                state.path.append(.설정(PokitSettingFeature.State()))
                return .none

            /// - 포킷 `수정`버튼 눌렀을 때
            case let .pokit(.delegate(.수정하기(category))),
                 let .path(.element(_, action: .카테고리상세(.delegate(.포킷수정(category))))):
                state.path.append(.포킷추가및수정(PokitCategorySettingFeature.State(
                    type: .수정,
                    categoryId: category.id,
                    categoryImage: category.categoryImage,
                    categoryName: category.categoryName
                )))
                return .none

            /// - 포킷 `추가` 버튼 눌렀을 때
            case .delegate(.포킷추가하기),
                 .path(.element(_, action: .링크추가및수정(.delegate(.포킷추가하기)))):
                state.path.append(.포킷추가및수정(PokitCategorySettingFeature.State(type: .추가)))
                return .none

            /// - 포킷 `추가` or `수정`이 성공적으로 `완료`되었을 때
            case let .path(.element(_, action: .포킷추가및수정(.delegate(.settingSuccess(categoryName, categoryId))))):
                state.path.removeLast()
                return .none

            /// - 포킷 카테고리 아이템 눌렀을 때
            case let .pokit(.delegate(.categoryTapped(category))):
                state.path.append(.카테고리상세(CategoryDetailFeature.State(category: category)))
                return .none

            case .path(.element(_, action: .카테고리상세(.delegate(.포킷삭제)))):
                /// Todo: id값을 받아와 삭제API 보내기
                state.path.removeLast()
                return .none

            /// - 링크 상세
            case let .path(.element(_, action: .카테고리상세(.delegate(.contentItemTapped(content))))),
                 let .pokit(.delegate(.contentDetailTapped(content))),
                 let .remind(.delegate(.링크상세(content))),
                 let .path(.element(_, action: .링크목록(.delegate(.링크상세(content: content))))):
                // TODO: 링크상세 모델과 링크수정 모델 일치시키기
                state.contentDetail = ContentDetailFeature.State(contentId: content.id)
                return .none

            /// - 링크상세 바텀시트에서 링크수정으로 이동
            case let .contentDetail(.presented(.delegate(.editButtonTapped(id)))),
                 let .pokit(.delegate(.링크수정하기(id))),
                 let .remind(.delegate(.링크수정(id))),
                 let .path(.element(_, action: .카테고리상세(.delegate(.링크수정(id))))),
                 let .path(.element(_, action: .링크목록(.delegate(.링크수정(id))))):
                return .run { send in await send(.inner(.링크추가및수정이동(contentId: id))) }
                
            case let .contentDetail(.presented(.delegate(.컨텐츠_삭제_완료(contentId: id)))):
                state.contentDetail = nil
                // - TODO: 컨텐츠 상세를 띄운 뷰에 컨텐츠 삭제 반영
                return .none

            case let .inner(.링크추가및수정이동(contentId: id)):
                state.path.append(.링크추가및수정(
                    ContentSettingFeature.State(contentId: id)
                ))
                state.contentDetail = nil
                return .none

            /// - 링크 추가하기
            case .delegate(.링크추가하기):
                state.path.append(.링크추가및수정(ContentSettingFeature.State(urlText: state.link)))
                return .none

            /// - 링크추가 및 수정에서 저장하기 눌렀을 때
            case .path(.element(_, action: .링크추가및수정(.delegate(.저장하기_완료)))):
                state.path.removeLast()
                return .send(.remind(.delegate(.컨텐츠목록_조회)))
            /// - 각 화면에서 링크 복사 감지했을 때 (링크 추가 및 수정 화면 제외)
            case let .path(.element(_, action: .알림함(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .검색(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .설정(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .카테고리상세(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .포킷추가및수정(.delegate(.linkCopyDetected(url))))),
                 let .path(.element(_, action: .링크목록(.delegate(.linkCopyDetected(url))))):
                return .run { send in await send(.inner(.linkCopySuccess(url)), animation: .pokitSpring) }
            /// 링크목록 `안읽음`
            case .remind(.delegate(.링크목록_안읽음)):
                state.path.append(.링크목록(ContentListFeature.State(contentType: .unread)))
                return .none
            /// 링크목록 `즐겨찾기`
            case .remind(.delegate(.링크목록_즐겨찾기)):
                state.path.append(.링크목록(ContentListFeature.State(contentType: .favorite)))
                return .none
                
            case .path(.element(_, action: .설정(.delegate(.로그아웃)))):
                return .send(.delegate(.로그아웃))
            case .path(.element(_, action: .설정(.delegate(.회원탈퇴)))):
                return .send(.delegate(.회원탈퇴))
            default: return .none
            }
        }
        .forEach(\.path, action: \.path) { MainTabPath() }
    }
}

