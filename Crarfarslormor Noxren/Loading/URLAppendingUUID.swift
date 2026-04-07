//
//  URLAppendingUUID.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 06.04.2026.
//

import Foundation

enum URLAppendingUUID {
    /// Adds `uuid` query item when the URL does not already include that parameter.
    static func augment(base: URL, uuid: String) -> URL {
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        var items = components?.queryItems ?? []
        if items.contains(where: { $0.name == LoadingConfig.queryUUID }) {
            return base
        }
        items.append(URLQueryItem(name: LoadingConfig.queryUUID, value: uuid))
        components?.queryItems = items
        return components?.url ?? base
    }
}
