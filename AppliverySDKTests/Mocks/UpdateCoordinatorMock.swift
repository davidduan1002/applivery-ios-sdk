//
//  UpdateCoordinatorMock.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez on 21/11/15.
//  Copyright © 2015 Applivery S.L. All rights reserved.
//

import Foundation
@testable import Applivery

class UpdateCoordinatorMock: PUpdateCoordinator {
	
	var outForceUpdateCalled = false
	var outOtaUpdateCalled = false
	
	
	func forceUpdate() {
		self.outForceUpdateCalled = true
	}
	
	func otaUpdate() {
		self.outOtaUpdateCalled = true
	}
	
}