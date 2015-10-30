//
//  SecuTrialFormParsingTests.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import XCTest
import SecuTrialClient


class SecuTrialFormParsingTests: XCTestCase {
	
	func testFirst() {
		let parser = SecuTrialFormParser()
		let url = NSBundle(forClass: self.dynamicType).URLForResource("TestFormDefinition", withExtension: "xml")
		XCTAssertNotNil(url)
		let main = try! parser.parseLocalFile(url!)
		XCTAssertEqual(1, main.forms.count, "Expecting one form but got \(main.forms.count)")
    }
}
