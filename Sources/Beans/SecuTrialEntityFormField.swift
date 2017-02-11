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
	case unknown
	case numeric = 27
	case checkbox = 33
	case date = 35
	case text = 88
	case radio = 127
	
	public var description: String {
		switch self {
		case .numeric:
			return "numeric"
		case .checkbox:
			return "checkbox"
		case .date:
			return "date"
		case .text:
			return "text"
		case .radio:
			return "radio"
		default:
			return "unknown"
		}
	}
}


/**
Definition of a form field, usually contained in a group within a form.
*/
open class SecuTrialEntityFormField: SecuTrialEntityObject {
	
	open var fflabel: String? {
		return propertyValueString("fflabel")
	}
	
	open var fftext: String? {
		return propertyValueString("fftext")
	}
	
	open var importMapping: [SecuTrialEntityImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: SecuTrialEntityImportMapping.self)
	}
	
	open var fieldType: SecuTrialEntityFormFieldType {
		if let type = propertyValue("fieldtype", type: SecuTrialEntityObject.self)?.type {
			if let fftype = type["fftype"] as? SOAPTextNode, "integer" == fftype.name, let intstr = fftype.text, let int = Int(intstr) {
				return SecuTrialEntityFormFieldType(rawValue: int) ?? .unknown
			}
		}
		return .unknown
	}
	
	/// Possible values for radiobuttons.
	open var values: [SecuTrialEntityFormFieldValue]? {
		let fvaluelinkArray = propertyArrayValueObjects("fvaluelinkArray", entities: "Fvaluelink")
		let values = fvaluelinkArray.map() { $0.propertyValue("fvalue", type: SecuTrialEntityFormFieldValue.self) }.filter() { nil != $0 }.map() { $0! }
		return values.isEmpty ? nil : values
	}
	
	// TODO: formfieldruleArray (checkboxes)
}


open class SecuTrialEntityFormFieldValue: SecuTrialEntityObject {
	
	//public var entity = "Fvalue"
	
	/// The radio button's label to display.
	open var fvlabel: String? {
		return propertyValueString("fvlabel")
	}
	
	/// The value associated with the radio button.
	open var fvvalue: String? {
		return propertyValueString("fvvalue")
	}
}

