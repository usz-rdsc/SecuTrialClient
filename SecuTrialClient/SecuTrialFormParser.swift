//
//  SecuTrialFormParser.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SecuTrialFormParser {
	
	public init() {  }
	
	public func parseLocalFile(url: NSURL) throws -> [SecuTrialEntityForm] {
		guard let data = NSData(contentsOfURL: url) else {
			throw SecuTrialError.Error("Failed to read data from «\(url)»")
		}
		return try parse(data)
	}
	
	public func parse(data: NSData) throws -> [SecuTrialEntityForm] {
		let parser = SOAPParser()
		parser.onEndElement = { element in
			if "array" == element.name {
				return try SecuTrialEntityArray(node: element)
			}
			if "dict" == element.name {
				return try SecuTrialEntityDictionary(node: element)
			}
			if "object" == element.name {
				if let entity = element.attr("entity") {
					if "Form" == entity {
						return try SecuTrialEntityForm(node: element)
					}
					if "Formgroup" == entity {
						return try SecuTrialEntityFormGroup(node: element)
					}
					if "Formfield" == entity {
						return try SecuTrialEntityFormField(node: element)
					}
					if "Importmapping" == entity {
						return try SecuTrialEntityImportMapping(node: element)
					}
					if "Importformat" == entity {
						return try SecuTrialEntityImportFormat(node: element)
					}
				}
				return try SecuTrialEntityObject(node: element)
			}
			if "property" == element.name {
				return try SecuTrialEntityProperty(node: element)
			}
			return nil
		}
		
		let root = try parser.parse(data) as! SecuTrialEntityDictionary
		if let formarr = root["forms"] as? SecuTrialEntityArray {
			return formarr.objects("Form", type: SecuTrialEntityForm.self)
		}
		return []
	}
}

