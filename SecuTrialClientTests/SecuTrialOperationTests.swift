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
		ops.withResponseEnvelope = { envelope in
			return SecuTrialResponse(envelope: envelope, parsePath: ["authenticateResponse", "authenticateReturn"])
		}
		let res = ops.handleResponseData(data!)
		XCTAssertNotNil(res)
		XCTAssertNotNil(res.statusCode)
		XCTAssertNotNil(res.errorCode)
		XCTAssertNotNil(res.message)
		XCTAssertNil(res.error)
		XCTAssertFalse(res.isError)
		XCTAssertEqual(1, res.statusCode!)
		XCTAssertEqual(0, res.errorCode!)
		XCTAssertEqual("64enfEQAr6rj2kXpC7jbjw", res.message!)
	}
}
