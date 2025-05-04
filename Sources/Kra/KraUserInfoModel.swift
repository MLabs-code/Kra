//
//  KraUserInfoModel.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//


import Foundation

public struct KraUserInfoModel: Codable {
    public let msg: String?
    public let data: KraUserInfoData
    public let success: Int
}


public struct KraUserInfoData: Codable {
    public let daysLeft: Int?
    public let objectQuota, bytesQuota: Int
    public let mailing: Bool
    public let username: String
    public let objects, bytes: Int
    public let email, subscribedUntil: String
    
    public var vip_days: String? {
        if let daysLeft {
            return "\(daysLeft)"
        }
        return nil
    }
    
    public var isNeedExpandSubscrition: Bool {
        daysLeft == nil
    }

    enum CodingKeys: String, CodingKey {
        case daysLeft = "days_left"
        case objectQuota = "object_quota"
        case bytesQuota = "bytes_quota"
        case mailing, username, objects, bytes, email
        case subscribedUntil = "subscribed_until"
    }
}
