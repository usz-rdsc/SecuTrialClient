//
//  SOAPNodeTests.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 15/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import XCTest
@testable import SecuTrialClient


class SOAPNodeTests: XCTestCase {
	
	func testEnvelopeParsing() {
		let data = NSData(contentsOfURL: NSBundle(forClass: self.dynamicType).URLForResource("TestEnvelope", withExtension: "xml")!)
		XCTAssertNotNil(data)
		let parser = SOAPEnvelopeParser()
		do {
			let envelope = try parser.parse(data!)
			XCTAssertNotNil(envelope)
			XCTAssertNotNil(envelope?.header)
			XCTAssertNotNil(envelope?.body)
			let resp = envelope?.body?.childNamed("authenticateResponse")
			XCTAssertNotNil(resp, "Expecting 'authenticateResponse' child node")
			XCTAssertEqual("ns3", resp!.namespace!.name)
			XCTAssertEqual("http://DefaultNamespace", resp!.namespace!.url)
			let ret = resp!.childNamed("authenticateReturn")
			XCTAssertNotNil(ret, "Expecting 'authenticateReturn' child node")
			XCTAssertNil(ret!.namespace)
			let status = ret!.childNamed("statusCode") as? SOAPTextNode
			XCTAssertNotNil(status, "Expecting 'statusCode' child node")
			XCTAssertTrue(ret!.childNodes[2] === status!)
			XCTAssertNil(status!.namespace)
			XCTAssertEqual("xsd:int", status!.attr("xsi:type")!)
			XCTAssertEqual("1", status!.text!)
		}
		catch let err {
			XCTAssertNil(err, "Error parsing TestEnvelope")
		}
	}
	
	func dontTestPerformanceExample() {
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.
		}
	}
}

