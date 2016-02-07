//
//  Applivery.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez on 3/10/15.
//  Copyright © 2015 Applivery S.L. All rights reserved.
//

import Foundation


@objc public enum LogLevel: Int {
	/// No log will be shown. Recommended for production environments.
	case None = 0
	
	/// Only warnings and errors. Recommended for develop environments.
	case Error = 1
	
	/// Errors and relevant information. Recommended for test integrating Applivery.
	case Info = 2
	
	/// Request and Responses to Applivery's server will be displayed. Not recommended to use, only for debugging Applivery.
	case Debug = 3
}


/**
	The Applivery's class provides the entry point to the Applivery service.

	### Usage

	You should use the `sharedInstance` property to get a unique singleton instance, then set your `logLevel` configuration and finally call to the method:

		start(apiKey apiKey: String, appId: String, appStoreRelease: Bool)


	### Overview 

	When Applivery's starts, the latests configuration for your build will be retrieved, and the build version of your app will be checked. Then applivery could:
	1. Do nothing if the app is in the latest version or any update is checked in the app configuration.
	2. Shows a cancellable alert if there is a new available update in Applivery, giving the user the chance to update to the latest build.
	3. Shows a modal screen, that user can not dismiss, with the only option to update to the latest build. This will force yours users to update giving them any chance to continue using the app.

	- seealso: [Applivery's README on GitHub](https://github.com/applivery/applivery-ios-sdk/blob/master/README.md)
	- Since: 1.0
	- Version: 1.0
	- Author: Alejandro Jiménez Agudo
	- Copyright: Applivery
*/
public class Applivery: NSObject, StartInteractorOutput {
	
	/// Singleton instance
	public static let sharedInstance = Applivery()
	
	/**
		Type of Applivery's logs you want displayed in the debug console
	
		- **None**: No log will be shown. Recommended for production environments.
		- **Error**: Only warnings and errors. Recommended for develop environments.
		- **Info**: Errors and relevant information. Recommended for test integrating Applivery.
		- **Debug**: Request and Responses to Applivery's server will be displayed. Not recommended to use, only for debugging Applivery.
	*/
	public var logLevel: LogLevel {
		didSet {
			self.globalConfig.logLevel = self.logLevel
		}
	}
	
	private let startInteractor: StartInteractor
	private let globalConfig: GlobalConfig
	private let updateCoordinator: PUpdateCoordinator
	
	
	// MARK: Initializers
	override convenience init() {
		self.init(startInteractor: StartInteractor(), globalConfig: GlobalConfig.shared, updateCoordinator: UpdateCoordinator())
		self.startInteractor.output = self
	}
	
	internal init(startInteractor: StartInteractor, globalConfig: GlobalConfig, updateCoordinator: PUpdateCoordinator) {
		self.startInteractor = startInteractor
		self.globalConfig = globalConfig
		self.updateCoordinator = updateCoordinator
		self.logLevel = .None
	}
	
	
	// MARK: Public method
	
	/**
		Starts Applivery's framework
		
		- Parameters:
			- apiKey: Your developer's Api Key
			- appId: Your application's ID
			- appStoreRelease: Flag to mark the build as a build that will be submitted to the AppStore. This is needed to prevent unwanted behavior like prompt to a final user that a new version is available on Applivery.
				* True: Applivery will stop any activity. **Use this for AppStore**
				* False: Applivery will works as normally. Use this with distributed builds in Applivery.
	
		- Attention: Be sure that the param **appStoreRelease** is true before submitting to the AppStore
		- Since: 1.0
		- Version: 1.0
	*/
	public func start(apiKey apiKey: String, appId: String, appStoreRelease: Bool) {
		self.loadFonts()
		
		self.globalConfig.apiKey = apiKey
		self.globalConfig.appId = appId
		self.globalConfig.appStoreRelease = appStoreRelease
		
		self.startInteractor.start()
	}
	
	
	// MARK: Start Interactor
	internal func forceUpdate() {
		LogInfo("Application must be updated!!")
		self.updateCoordinator.forceUpdate()
	}
	
	internal func otaUpdate() {
		LogInfo("New OTA update available!")
		self.updateCoordinator.otaUpdate()
	}
	
	
	// MARK - Private Helpers
	
	private func loadFonts() {
		UIFont.registerFontWithFilenameString("Lato-Light.ttf", bundle: NSBundle.AppliveryBundle())
		UIFont.registerFontWithFilenameString("Lato-Regular.ttf", bundle: NSBundle.AppliveryBundle())
		UIFont.registerFontWithFilenameString("fontawesome-webfont.ttf", bundle: NSBundle.AppliveryBundle())
	}
	
}