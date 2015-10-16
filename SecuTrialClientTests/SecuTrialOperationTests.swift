//
//  SecuTrialOperationTests.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import XCTest
@testable import SecuTrialClient


class SecuTrialOperationTests: XCTestCase {
	
	func testExample() {
		let data = NSData(contentsOfURL: NSBundle(forClass: self.dynamicType).URLForResource("TestEnvelope", withExtension: "xml")!)
		XCTAssertNotNil(data)
		let ops = SecuTrialOperation(name: "authenticate")
		ops.expectedResponseBean = STWebServiceResult.self
		ops.expectsResponseBeanAt = ["authenticateResponse", "authenticateReturn"]
		let res = ops.handleResponseData(data!)
		XCTAssertNotNil(res.bean)
		XCTAssertNil(res.error)
		if let bean = res.bean as? STWebServiceResult {
			XCTAssertNotNil(bean.message)
			XCTAssertEqual(1, bean.statusCode)
			XCTAssertEqual(0, bean.errorCode)
			XCTAssertEqual("64enfEQAr6rj2kXpC7jbjw", bean.message!)
		}
	}
}
