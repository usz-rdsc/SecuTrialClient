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
open class SecuTrialEntityForm: SecuTrialEntityObject {
	
	open var formname: String? {
		return propertyValueString("formname")
	}
	
	open var formtablename: String? {
		return propertyValueString("formtablename")
	}
	
	open var groups: [SecuTrialEntityFormGroup] {
		return propertyArrayValueObjects("formgroupArray", entities: "Formgroup", type: SecuTrialEntityFormGroup.self)
	}
	
	open var importFormats: [SecuTrialEntityImportFormat] {
		return propertyArrayValueObjects("importformatArray", entities: "Importformat", type: SecuTrialEntityImportFormat.self)
	}
}


open class SecuTrialEntityFormGroup: SecuTrialEntityObject {
	
	open var label: String? {
		return propertyValueString("fgquerylabel")
	}
	
	open var fields: [SecuTrialEntityFormField] {
		return propertyArrayValueObjects("formfieldArray", entities: "Formfield", type: SecuTrialEntityFormField.self)
	}
}

