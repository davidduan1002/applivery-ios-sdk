//
//  StartInteractor.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez on 4/10/15.
//  Copyright © 2015 Applivery S.L. All rights reserved.
//

import Foundation


protocol StartInteractorOutput {
	func forceUpdate()
	func otaUpdate()
	func feedbackEvent()
}


class StartInteractor {
	
	var output: StartInteractorOutput!
	
	private let configDataManager: PConfigDataManager
	private let globalConfig: GlobalConfig
	private let eventDetector: EventDetector
	
	
	// MARK: Initializers
	
	init(configDataManager: PConfigDataManager = ConfigDataManager(),
		globalConfig: GlobalConfig = GlobalConfig.shared,
		eventDetector: EventDetector = ScreenshotDetector()) {
			self.configDataManager = configDataManager
			self.globalConfig = globalConfig
			self.eventDetector = eventDetector
	}
	
	
	// MARK: Internal Methods
	
	func start() {
		LogInfo("Applivery is starting...")
		self.eventDetector.listenEvent(self.output.feedbackEvent)
		
		guard !self.globalConfig.appStoreRelease else {
			return LogWarn("The build is marked like an AppStore Release. Applivery won't present any update (or force update) message to the user")
		}
		
		self.updateConfig()
	}
	
	
	// MARK: Private Methods
	
	private func updateConfig() {
		self.configDataManager.updateConfig { response in
			switch response {
				
			case .Success(let config, let version):
				if !self.checkForceUpdate(config, version: version) {
					self.checkOtaUpdate(config, version: version)
				}
				
			case .Error:
				let currentConfig = self.configDataManager.getCurrentConfig()
				if !self.checkForceUpdate(currentConfig.config, version: currentConfig.version) {
					self.checkOtaUpdate(currentConfig.config, version: currentConfig.version)
				}
			}
		}
	}
	
	private func checkForceUpdate(config: Config?, version: String) -> Bool {
		guard let conf = config else { return false }
		guard conf.forceUpdate else { return false }
		
		LogInfo("Checking if app version: \(version) is older than minVersion: \(conf.minVersion)")
		if self.isOlder(version, minVersion: conf.minVersion) {
			self.output.forceUpdate()
			
			return true
		}
		
		return false
	}
	
	private func checkOtaUpdate(config: Config?, version: String) {
		guard let conf = config else { return }
		guard conf.otaUpdate else { return }
		
		LogInfo("Checking if app version: \(version) is older than last build version: \(conf.lastVersion)")
		if self.isOlder(version, minVersion: conf.lastVersion) {
			self.output.otaUpdate()
		}
	}
	
	private func isOlder(currentVersion: String, minVersion: String) -> Bool {
		let (current, min) = self.equalLengthFillingWithZeros(currentVersion, b: minVersion)
		let result = current.compare(min, options: NSStringCompareOptions.NumericSearch, range: nil, locale: nil)
		
		return result == NSComparisonResult.OrderedAscending
	}
	
	private func equalLengthFillingWithZeros(a: String, b: String) -> (String, String) {
		let componentsA = a.componentsSeparatedByString(".")
		let componentsB = b.componentsSeparatedByString(".")
		
		if componentsA.count == componentsB.count {
			return (a, b)
		}
		else if componentsA.count < componentsB.count {
			let dif = componentsB.count - componentsA.count
			let a2 = self.fillWithZeros(componentsA, length: dif)
			return (a2, b)
		}
		else {
			let dif = componentsA.count - componentsB.count
			let b2 = self.fillWithZeros(componentsB, length: dif)
			return (a, b2)
		}
	}
	
	private func fillWithZeros(s: [String], length: Int) -> String {
		var string = s
		for _ in 1...length {
			string.append("0")
		}
		
		return string.joinWithSeparator(".")
	}
}
