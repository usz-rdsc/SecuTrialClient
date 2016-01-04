//
//  SecuTrialEntityImportFormat.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 04/01/16.
//  Copyright © 2016 USZ. All rights reserved.
//


/**
An import format belongs to a data form and determines how form data is handled.
*/
public class SecuTrialEntityImportFormat: SecuTrialEntityObject {
	
	public var formatName: String? {
		return propertyValueString("formatname")
	}
	
	public var identifier: String? {
		return propertyValueString("identifier")
	}
	
	public var importMapping: [SecuTrialEntityImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: SecuTrialEntityImportMapping.self)
	}
}

extension SecuTrialEntityImportFormat: Equatable {}
public func ==(left: SecuTrialEntityImportFormat, right: SecuTrialEntityImportFormat) -> Bool {
	return left.identifier == right.identifier
}

