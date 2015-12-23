//
//  SecuTrialEntityForm.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 30/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


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
	
	public var fields: [SecuTrialEntityFormField] {
		return propertyArrayValueObjects("formfieldArray", entities: "Formfield", type: SecuTrialEntityFormField.self)
	}
}


public class SecuTrialEntityFormField: SecuTrialEntityObject {
	
	public var fflabel: String? {
		return propertyValueString("fflabel")
	}
	
	public var fftext: String? {
		return propertyValueString("fftext")
	}
	
	public var importMapping: [SecuTrialEntityImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: SecuTrialEntityImportMapping.self)
	}
	
	public var fieldType: Int? {
		if let type = propertyValue("fieldtype", type: SecuTrialEntityObject.self)?.type {
			if let fftype = type["fftype"] as? SOAPTextNode where "integer" == fftype.name, let intstr = fftype.text {
				return Int(intstr)
			}
		}
		return nil
	}
	
	// TODO: fvaluelinkArray (radiobutton values/labels)
	
	// TODO: formfieldruleArray (checkboxes)
}


public class SecuTrialEntityImportMapping: SecuTrialEntityObject {
	
	public var importFormat: SecuTrialEntityImportFormat? {
		return propertyValue("importformat", type: SecuTrialEntityImportFormat.self)
	}
	
	public var externalKey: String? {
		return propertyValueString("externalkey")
	}
	
	public var dateFormat: String? {
		return propertyValueString("dateformat")
	}
}


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

