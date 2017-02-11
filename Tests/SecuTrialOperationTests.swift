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
		let data = try? Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "TestEnvelope", withExtension: "xml")!)
		XCTAssertNotNil(data)
		let ops = SecuTrialOperation(name: "authenticate")
		ops.expectedResponseBean = SecuTrialBeanWebServiceResult.self
		ops.expectsResponseBeanAt = ["authenticateResponse", "authenticateReturn"]
		let res = ops.handleResponseData(data!)
		XCTAssertNotNil(res.bean)
		XCTAssertNil(res.error)
		if let bean = res.bean as? SecuTrialBeanWebServiceResult {
			XCTAssertNotNil(bean.message)
			XCTAssertEqual(1, bean.statusCode)
			XCTAssertEqual("64enfEQAr6rj2kXpC7jbjw", bean.message!)
		}
	}
}
