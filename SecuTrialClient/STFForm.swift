//
//  STFForm.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 30/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
Holds all content of a "Form" entity found in a secuTrial form definition XML.
*/
public class STFForm: STFObject {
	
	public var groups: [STFFormGroup] {
		return propertyArrayValueObjects("formgroupArray", entities: "Formgroup", type: STFFormGroup.self)
	}
	
	// Returns an array of all Fields in all Groups that have an Importmapping with importformat.
	public var importables: [STFImportMapping] {
		var arr = [STFImportMapping]()
		for group in groups {
			for field in group.fields {
				for mapping in field.importMapping {
					if nil != mapping.importFormat {
						arr.append(mapping)
					}
				}
			}
		}
		return arr
	}
}


public class STFFormGroup: STFObject {
	
	public var fields: [STFFormField] {
		return propertyArrayValueObjects("formfieldArray", entities: "Formfield", type: STFFormField.self)
	}
}


public class STFFormField: STFObject {
	
	public var importMapping: [STFImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: STFImportMapping.self)
	}
	
	public var fieldType: Int? {
		if let type = propertyValue("fieldtype", type: STFObject.self)?.type {
			if let fftype = type["fftype"] as? SOAPTextNode where "integer" == fftype.name, let intstr = fftype.text {
				return Int(intstr)
			}
		}
		return nil
	}
	
	// TODO: fvaluelinkArray (radiobutton values/labels)
	
	// TODO: formfieldruleArray (checkboxes)
}


public class STFImportMapping: STFObject {
	
	public var importFormat: STFImportFormat? {
		return propertyValue("importformat", type: STFImportFormat.self)
	}
	
	public var externalKey: String? {
		return propertyValueString("externalkey")
	}
	
	public var dateFormat: String? {
		return propertyValueString("dateformat")
	}
	
	public var formField: STFFormField? {
		return propertyValue("formfield", type: STFFormField.self)
	}
}


public class STFImportFormat: STFObject {
	
	public var formatName: String? {
		return propertyValueString("formatname")
	}
	
	public var identifier: String? {
		return propertyValueString("identifier")
	}
	
	public var importMapping: [STFImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: STFImportMapping.self)
	}
}

