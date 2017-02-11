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
open class SecuTrialEntityImportFormat: SecuTrialEntityObject {
	
	open var formatName: String? {
		return propertyValueString("formatname")
	}
	
	open var identifier: String? {
		return propertyValueString("identifier")
	}
	
	open var importMapping: [SecuTrialEntityImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: SecuTrialEntityImportMapping.self)
	}
}

extension SecuTrialEntityImportFormat: Equatable {}
public func ==(left: SecuTrialEntityImportFormat, right: SecuTrialEntityImportFormat) -> Bool {
	return left.identifier == right.identifier
}


open class SecuTrialEntityImportMapping: SecuTrialEntityObject {
	
	open var importFormat: SecuTrialEntityImportFormat? {
		return propertyValue("importformat", type: SecuTrialEntityImportFormat.self)
	}
	
	open var externalKey: String? {
		return propertyValueString("externalkey")
	}
	
	open var dateFormat: String? {
		return propertyValueString("dateformat")
	}
}

