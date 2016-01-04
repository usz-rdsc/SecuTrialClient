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
	
	/// Possible values for radiobuttons.
	public var values: [SecuTrialEntityFormFieldValue]? {
		let fvaluelinkArray = propertyArrayValueObjects("fvaluelinkArray", entities: "Fvaluelink")
		let values = fvaluelinkArray.map() { $0.propertyValue("fvalue", type: SecuTrialEntityFormFieldValue.self) }.filter() { nil != $0 }.map() { $0! }
		return values.isEmpty ? nil : values
	}
	
	// TODO: formfieldruleArray (checkboxes)
}


public class SecuTrialEntityFormFieldValue: SecuTrialEntityObject {
	
	//public var entity = "Fvalue"
	
	/// The radio button's label to display.
	public var fvlabel: String? {
		return propertyValueString("fvlabel")
	}
	
	/// The value associated with the radio button.
	public var fvvalue: String? {
		return propertyValueString("fvvalue")
	}
}

