//
//  BillboardData.swift
//  KioskAd
//
//  Created by Tim Fosteman on 2020-02-09.
//  Copyright © 2020 Fosteman's Software Solutions LLC. All rights reserved.
//

import Foundation
struct BillboardData : Decodable {
  var link: String
  var images: [String]
  var videoUrl: String
    static func decode(from json: String) -> BillboardData? {
    guard let jsonData = json.data(using: .utf8) else {return nil}
    let decoder = JSONDecoder()
    return try? decoder.decode(BillboardData.self, from: jsonData) }
}
