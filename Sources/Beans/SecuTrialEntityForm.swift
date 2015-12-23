//
//  SecuTrialEntityForm.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 30/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


/**
Holds all content of a "Form" entity found in a secuTrial form definition XML.
*/
public class SecuTrialEntityForm: SecuTrialEntityObject {
	
	public var formname: String? {
		return propertyValueString("formname")
	}
	
	public var formtablename: String? {
		return propertyValueString("formtablename")
	}
	
	public var groups: [SecuTrialEntityFormGroup] {
		return propertyArrayValueObjects("formgroupArray", entities: "Formgroup", type: SecuTrialEntityFormGroup.self)
	}
	
	public var importFormats: [SecuTrialEntityImportFormat] {
		return propertyArrayValueObjects("importformatArray", entities: "Importformat", type: SecuTrialEntityImportFormat.self)
	}
}


public class SecuTrialEntityFormGroup: SecuTrialEntityObject {
	
	public var label: String? {
		return propertyValueString("fgquerylabel")
	}
	
	public var fields: [SecuTrialEntityFormField] {
		return propertyArrayValueObjects("formfieldArray", entities: "Formfield", type: SecuTrialEntityFormField.self)
	}
}

