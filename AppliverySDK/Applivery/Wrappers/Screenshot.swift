//
//  ScreenshotWrapper.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez on 5/3/16.
//  Copyright © 2016 Applivery S.L. All rights reserved.
//

import Foundation


struct Screenshot {

	var image: UIImage


	// MARK: - Factory Methods

	static func capture() -> Screenshot {
		let image = Screenshot.takeScreenshot()
		let screenshot = Screenshot(image: image)

		return screenshot
	}

	private static func takeScreenshot() -> UIImage {
		guard let layer = UIApplication.shared.keyWindow?.layer else {
			logWarn("Key window is nil")
			return UIImage()
		}
		
		let scale = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)

		guard let context = UIGraphicsGetCurrentContext() else {
			logWarn("Couldn't get context")
			return UIImage()
		}
		
		layer.render(in: context)
		
		guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
			logWarn("Couldn't get image")
			return UIImage()
		}
		
		UIGraphicsEndImageContext()

		return image
	}


	// MARK: - Public Methods

	func base64() -> String? {
		let imageData = UIImageJPEGRepresentation(self.image, 0.9)
		let base64String = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)

		return base64String
	}

}
