//
//  UserNotificationCenter.swift
//  ClashX Meta
//
//  Copyright © 2024 west2online. All rights reserved.
//

import Cocoa
import UserNotifications


class UserNotificationCenter: NSObject {
	static let shared = UserNotificationCenter()
	
	private override init() {
		super.init()
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.delegate = self
	}
	
	func post(title: String, info: String, identifier: String? = nil, notiOnly: Bool = true) {
		Task { @MainActor in
			do {
				let notificationCenter = UNUserNotificationCenter.current()
				let settings = await notificationCenter.notificationSettings()
				
				switch settings.authorizationStatus {
				case .denied:
					guard !notiOnly else { return }
					postNotificationAlert(title: title, info: info, identifier: identifier)
				case .authorized, .provisional:
					postNotification(title: title, info: info, identifier: identifier)
				case .notDetermined:
					let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
					
					if granted {
						postNotification(title: title, info: info, identifier: identifier)
					} else {
						guard !notiOnly else { return }
						postNotificationAlert(title: title, info: info, identifier: identifier)
					}
				@unknown default:
					postNotification(title: title, info: info, identifier: identifier)
				}
			} catch {
				Logger.log("Request notification authorization failed, \(error)", level: .error)
			}
		}
	}
	
	private func postNotification(title: String, info: String, identifier: String? = nil) {
		var userInfo: [String: Any] = [:]
		if let identifier = identifier {
			userInfo = ["identifier": identifier]
		}
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.removeAllDeliveredNotifications()
		notificationCenter.removeAllPendingNotificationRequests()
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = info
		content.userInfo = userInfo
		let uuidString = UUID().uuidString
		let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
		notificationCenter.add(request) { error in
			if let err = error {
				Logger.log("send noti fail: \(String(describing: err))")
				DispatchQueue.main.async {
					self.postNotificationAlert(title: title, info: info, identifier: identifier)
				}
			}
		}
	}
	
	func postNotificationAlert(title: String, info: String, identifier: String? = nil) {
		if Settings.disableNoti {
			return
		}
		let alert = NSAlert()
		alert.messageText = title
		alert.informativeText = info
		alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
		alert.runModal()
		if let identifier = identifier {
			handleNotificationActive(with: identifier)
		}
	}
	
	func postConfigFileChangeDetectionNotice() {
		post(title: NSLocalizedString("Config file have been changed", comment: ""),
			 info: NSLocalizedString("Tap to reload config", comment: ""),
			 identifier: "postConfigFileChangeDetectionNotice")
	}
	
	func postStreamApiConnectFail(api: String) {
		post(title: "\(api) api connect error!",
			 info: NSLocalizedString("Use reload config to try reconnect.", comment: ""))
	}
	
	func postMetaErrorNotice(msg: String) {
		let message = "Meta Core: \(msg)"
		postNotificationAlert(title: NSLocalizedString("Start Meta Fail!", comment: ""), info: message)
	}
	
	func postConfigErrorNotice(msg: String) {
		let configName = ConfigManager.selectConfigName.isEmpty ? "" :
		Paths.configFileName(for: ConfigManager.selectConfigName)
		
		let message = "\(configName): \(msg)"
		postNotificationAlert(title: NSLocalizedString("Config loading Fail!", comment: ""), info: message)
	}
	
	func postSpeedTestBeginNotice() {
		post(title: NSLocalizedString("Benchmark", comment: ""),
			 info: NSLocalizedString("Benchmark has begun, please wait.", comment: ""))
	}
	
	func postSpeedTestingNotice() {
		post(title: NSLocalizedString("Benchmark", comment: ""),
			 info: NSLocalizedString("Benchmark is processing, please wait.", comment: ""))
	}
	
	func postSpeedTestFinishNotice() {
		post(title: NSLocalizedString("Benchmark", comment: ""),
			 info: NSLocalizedString("Benchmark Finished!", comment: ""), notiOnly: false)
	}
	
	func postProxyChangeByOtherAppNotice() {
		post(title: NSLocalizedString("System Proxy Changed", comment: ""),
			 info: NSLocalizedString("Proxy settings are changed by another process. ClashX is no longer the default system proxy.", comment: ""), notiOnly: true)
	}
	
	func postUpdateNotice(msg: String) {
		postNotificationAlert(title: "Update ClashX Meta", info: msg)
	}
}

extension UserNotificationCenter: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		if let identifier = response.notification.request.content.userInfo["identifier"] as? String {
			handleNotificationActive(with: identifier)
		}
		center.removeAllDeliveredNotifications()
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		[.banner, .sound]
	}
	
	func handleNotificationActive(with identifier: String) {
		switch identifier {
		case "postConfigFileChangeDetectionNotice":
			DispatchQueue.main.async {
				AppDelegate.shared.updateConfig()
			}
		default:
			break
		}
	}
}
