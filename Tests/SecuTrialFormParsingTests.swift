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
		
		// DEBUG: print form tree
		print("-  MAIN:  \(main.modelname ?? "<nil>")")
		for form in main.forms {
			print("--  FORM:  \(form.formname ?? "<nil>")  [\(form.formtablename ?? "<nil>")]")
			
			for format in form.importFormats {
				print("---  IMPORT:  “\(format.formatName ?? "<nil>")”, identifier “\(format.identifier ?? "<nil>")”")
			}
			
			for group in form.groups {
				print("---  GROUP")
				for field in group.fields {
					print("----  FIELD:  “\(field.fflabel ?? "<nil>")”, type \(field.fieldType)")
					if let txt = field.fftext {
						print("-----  FFTEXT:  “\(txt)”")
					}
					for imports in field.importMapping {
						print("-----  MAPPED:  “\(imports.externalKey ?? "<nil>")”")
						if let ip = imports.importFormat {
							print("-----  IMPORTFMT:  “\(ip.identifier ?? "<nil>")”")
						}
						if let df = imports.dateFormat {
							print("-----  DATEFMT:  \(df)")
						}
					}
				}
			}
		}
    }
}
