//
//  ForumGroup.swift
//  iXland
//
//  Created by Boris Zhao on 2023-01-05.
//

import Foundation

struct ForumGroup: Codable {
    var id: Int
    var sort: Int
    var name: String
    var status: String
    var forums: [Forum]
}

struct Forum: Codable {
    var id: String
    var fGroup: String
    var sort: Int
    var name: String
    var showName: String
    var msg: String
    var interval: Int
    var threadCount: Int
    var permissionLevel: String
    var forumFuseId: String
    var createdAt: String
    var updateAt: String
    var status: String

    private enum CodingKeys: String, CodingKey {
        case id
        case fGroup
        case sort
        case name
        case showName
        case msg
        case interval
        case threadCount = "thread_count"
        case permissionLevel = "permission_level"
        case forumFuseId = "forum_fuse_id"
        case createdAt
        case updateAt
        case status
    }
}
