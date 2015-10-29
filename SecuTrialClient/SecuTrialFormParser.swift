//
//  SecuTrialFormParser.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SecuTrialFormParser {
	
	public init() {  }
	
	public func parseLocalFile(url: NSURL) throws -> [STFForm] {
		guard let data = NSData(contentsOfURL: url) else {
			throw SecuTrialError.Error("Failed to read data from «\(url)»")
		}
		return try parse(data)
	}
	
	public func parse(data: NSData) throws -> [STFForm] {
		let parser = SOAPParser()
		parser.onEndElement = { element in
			if "array" == element.name {
				return try STFArray(node: element)
			}
			if "dict" == element.name {
				return try STFDict(node: element)
			}
			if "object" == element.name {
				if let entity = element.attr("entity") {
					if "Form" == entity {
						return try STFForm(node: element)
					}
					if "Formgroup" == entity {
						return try STFFormGroup(node: element)
					}
					if "Formfield" == entity {
						return try STFFormField(node: element)
					}
					if "Importmapping" == entity {
						return try STFImportMapping(node: element)
					}
					if "Importformat" == entity {
						return try STFImportFormat(node: element)
					}
				}
				return try STFObject(node: element)
			}
			if "property" == element.name {
				return try STFProperty(node: element)
			}
			return nil
		}
		
		let root = try parser.parse(data) as! STFDict
		if let formarr = root["forms"] as? STFArray {
			return formarr.objects("Form", type: STFForm.self)
		}
		return []
	}
}

