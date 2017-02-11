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
		let url = Bundle(for: type(of: self)).url(forResource: "TestFormDefinition", withExtension: "xml")
		XCTAssertNotNil(url)
		let main = try! parser.parseLocalFile(at: url!)
		XCTAssertEqual(1, main.forms.count, "Expecting one form but got \(main.forms.count)")
    }
}
