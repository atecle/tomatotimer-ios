//
//  FocusListEntity+Helper.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/4/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import CoreData

// swiftlint:disable statement_position
extension FocusListEntity {

    static func focusList(from entity: FocusListEntity?) -> FocusList {
        guard let entity = entity else { return .none }
        let list: FocusList
        if
            entity.isKind(of: StandardListEntity.self),
            let standardListEntity = entity as? StandardListEntity,
            let standardList = StandardList(entity: standardListEntity) {
            list = .standard(standardList)
        }
        else if entity.isKind(of: SessionListEntity.self),
           let sessionListEntity = entity as? SessionListEntity,
           let sessionList = SessionList(entity: sessionListEntity) {
            list = .session(sessionList)
        }
        else if entity.isKind(of: SingleTaskListEntity.self),
           let singleTaskListEntity = entity as? SingleTaskListEntity,
           let singleTaskList = SingleTaskList(entity: singleTaskListEntity) {
            list = .singleTask(singleTaskList)
        }
        else {
            list = .none
        }

        return list
    }
}
