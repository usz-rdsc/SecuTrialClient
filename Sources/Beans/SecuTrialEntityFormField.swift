//
//  SecuTrialEntityFormField.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 23/12/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


public enum SecuTrialEntityFormFieldType: Int, CustomStringConvertible {
	case Unknown
	case Numeric = 27
	case Checkbox = 33
	case Date = 35
	case Text = 88
	case Radio = 127
	
	public var description: String {
		switch self {
		case .Numeric:
			return "numeric"
		case .Checkbox:
			return "checkbox"
		case .Date:
			return "date"
		case .Text:
			return "text"
		case .Radio:
			return "radio"
		default:
			return "unknown"
		}
	}
}


/**
Definition of a form field, usually contained in a group within a form.
*/
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
	
	public var fieldType: SecuTrialEntityFormFieldType {
		if let type = propertyValue("fieldtype", type: SecuTrialEntityObject.self)?.type {
			if let fftype = type["fftype"] as? SOAPTextNode where "integer" == fftype.name, let intstr = fftype.text, let int = Int(intstr) {
				return SecuTrialEntityFormFieldType(rawValue: int) ?? .Unknown
			}
		}
		return .Unknown
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

