//
//  SecuTrialFormParser.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
Holds on to secuTrial form definition found in an XML export file.

Use `SecuTrialFormParser` to instantiate one of these from an XML file.
*/
public class SecuTrialFormDefinition {
	
	let root: SecuTrialEntityDictionary
	
	public let forms: [SecuTrialEntityForm]
	
	/// The name of the project the form applies to.
	public var projectname: String?
	
	/// The model name.
	public var modelname: String?
	
	/// The number of this form.
	public var formnumber: String?
	
	
	public init(definition: SecuTrialEntityDictionary) {
		root = definition
		projectname = (root["projectname"] as? SOAPTextNode)?.text
		modelname = (root["modelname"] as? SOAPTextNode)?.text
		formnumber = (root["formnumber"] as? SOAPTextNode)?.text
		
		if let formarr = definition["forms"] as? SecuTrialEntityArray {
			forms = formarr.objects("Form", type: SecuTrialEntityForm.self)
		}
		else {
			forms = []
		}
	}
}


/**
Parses secuTrial form definition export files (XML, some weird plist variant).
*/
public class SecuTrialFormParser {
	
	public init() {  }
	
	public func parseLocalFile(url: NSURL) throws -> SecuTrialFormDefinition {
		guard let data = NSData(contentsOfURL: url) else {
			throw SecuTrialError.Error("Failed to read data from «\(url)»")
		}
		return try parse(data)
	}
	
	public func parse(data: NSData) throws -> SecuTrialFormDefinition {
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
		return SecuTrialFormDefinition(definition: root)
	}
}

