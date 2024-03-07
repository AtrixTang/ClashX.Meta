//
//  ProxyConfigRemoteProcessProtocol.swift
//  com.metacubex.ClashX.ProxyConfigHelper
//
//  Copyright © 2024 west2online. All rights reserved.
//

import Foundation

@objc(ProxyConfigRemoteProcessProtocol)
protocol ProxyConfigRemoteProcessProtocol {
	func getVersion(reply: @escaping (String) -> Void)
	
	
	func initMetaCore(path: String)
	func startMeta(confPath: String, confFilePath: String, confJSON: String, reply: @escaping (String?) -> Void)
	func verifyMeta(confPath: String, confFilePath: String, reply: @escaping (String?) -> Void)
	func stopMeta()
	func updateTun(state: Bool)
	func getUsedPorts(reply: @escaping (String?) -> Void)
	
	
	func enableProxy(port: Int, socksPort: Int, pac: String?, filterInterface: Bool, ignoreList: [String], reply: @escaping (String?) -> Void)
	func disableProxy(filterInterface: Bool, reply: @escaping (String?) -> Void)
	func restoreProxy(currentPort: Int, socksPort: Int, info: [String: Any], filterInterface: Bool, reply: @escaping (String?) -> Void)
	func getCurrentProxySetting(reply: @escaping ([String: Any]) -> Void)
}
