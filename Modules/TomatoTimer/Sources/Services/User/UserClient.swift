//
//  UserClient.swift
//  TomatoTimer
//
//  Created by adam tecle on 8/18/23.
//  Copyright © 2023 adamtecle. All rights reserved.
//

import Foundation
import Combine
import Dependencies

struct UserClient {

    var create: () async throws -> Void
    var fetch: () async throws -> User?
    var monitorUser: () -> AnyPublisher<User, Error>
    var update: (@escaping (inout User) -> Void) async throws -> Void

    static func live(
        coreDataClient: CoreDataRepository<UserEntity>
    ) -> Self {
        Self(
            create: {
                try await coreDataClient.create(User(didPurchasePlus: false))
            },
            fetch: {
                let request = UserEntity.fetchRequest()
                request.sortDescriptors = UserEntity.defaultSortDescriptors
                return try await coreDataClient.fetchNonManaged(request).first
            },
            monitorUser: {
                let request = UserEntity.fetchRequest()
                request.sortDescriptors = UserEntity.defaultSortDescriptors
                return coreDataClient.monitor(request)
                    .compactMap(\.first)
                    .eraseToAnyPublisher()
            },
            update: { updateUser in
                let request = UserEntity.fetchRequest()
                request.sortDescriptors = UserEntity.defaultSortDescriptors
                try await coreDataClient.updateOne(request) { entity, context in
                    guard var user = entity?.toNonManagedObject() else { return }
                    updateUser(&user)
                    entity?.update(from: user, context: context)
                }
            }
        )
    }
}

extension UserClient: DependencyKey {
    static let liveValue: UserClient = UserClient.live(
        coreDataClient: .live(
            coreDataStack: CoreDataStack.live
        )
    )
}

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
}
