//
//  Paths.swift
//  ClashX
//
//  Created by CYC on 2018/8/26.
//  Copyright © 2018年 west2online. All rights reserved.
//
import Foundation

let kConfigFolderPath = "\(NSHomeDirectory())/.config/clash/"

let kDefaultConfigFilePath = "\(kConfigFolderPath)config.yaml"

struct Paths {
    static func localConfigPath(for name: String) -> String {
        return "\(kConfigFolderPath)\(configFileName(for: name))"
    }

    static func configFileName(for name: String) -> String {
        return "\(name).yaml"
    }
    
    static func defaultCorePath() -> String? {
        Bundle.main.path(forResource: "com.metacubex.ClashX.ProxyConfigHelper.meta", ofType: nil)
    }
    
    static func alphaCorePath() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("com.metacubex.ClashX.meta")
            .appendingPathComponent("com.metacubex.ClashX.ProxyConfigHelper.meta")
    }
}
