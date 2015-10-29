//
//  STFObject.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 29/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
An XML node in the SecuTrial form that represents an Object.
*/
public class STFObject: SOAPNode {
	
	public var entity = "Object"
	
	public var properties: [STFProperty]?
	
	public var type: STFDict?
	
	public init(node: SOAPNode) throws {
		super.init(name: node.name)
		copy(node)
		
		if let ent = attr("entity") {
			entity = ent
		}
		
		var props = [STFProperty]()
		for child in childNodes {
			if let prop = child as? STFProperty {		// "property" == child.name
				props.append(prop)
			}
			else if let typ = child as? STFDict {		// "dict" == child.name
				type = typ
			}
			else {
				throw SecuTrialError.InvalidDOM("<object> nodes can not contain <\(child.name)> nodes, but this one does")
			}
		}
		properties = props
	}
	
	public required init(name: String) {
		fatalError("Cannot use init(name:)")
	}
	
	public subscript(name: String) -> STFProperty? {
		if let properties = properties {
			for prop in properties {
				if name == prop.name {
					return prop
				}
			}
		}
		return nil
	}
	
	public func propertyValue<T: SOAPNode>(name: String, type: T.Type? = nil) -> T? {
		return self[name]?.value as? T
	}
	
	public func propertyValueString(name: String) -> String? {
		return self[name]?.stringValue
	}
	
	public func propertyArrayValueObjects<T: STFObject>(name: String, entities: String, type: T.Type? = nil) -> [T] {
		if let arr = propertyValue(name) as? STFArray {
			return arr.objects(entities, type: T.self)
		}
		return []
	}
}


public class STFForm: STFObject {
	
	public var groups: [STFFormGroup] {
		return propertyArrayValueObjects("formgroupArray", entities: "Formgroup", type: STFFormGroup.self)
	}
}


public class STFFormGroup: STFObject {
	
	public var fields: [STFFormField] {
		return propertyArrayValueObjects("formfieldArray", entities: "Formfield", type: STFFormField.self)
	}
}


public class STFFormField: STFObject {
	
	public var mapping: [STFImportMapping] {
		return propertyArrayValueObjects("importmappingArray", entities: "Importmapping", type: STFImportMapping.self)
	}
}


public class STFImportMapping: STFObject {
	
	public var format: STFImportFormat? {
		return propertyValue("importformat", type: STFImportFormat.self)
	}
}


public class STFImportFormat: STFObject {
	
}


public class STFProperty: SOAPNode {
	
	public var value: SOAPNode? = nil
	
	public var stringValue: String? {
		if let txt = value as? SOAPTextNode {
			return txt.text
		}
		return nil
	}
	
	public init(node: SOAPNode) throws {
		let name = node.attr("name") ?? "<>"		// this is shit, but Swift requires to initialize everything before throwing
		super.init(name: name)
		copy(node)
		if 1 != childNodes.count {
			throw SecuTrialError.InvalidDOM("<property> node can only have one child node, this one is: \(node.asXMLString())")
		}
		if "<>" == name {
			throw SecuTrialError.InvalidDOM("<property> nodes must have a “name” attribute: \(node.asXMLString())")
		}
		if "null" != childNodes[0].name {
			value = childNodes[0]
		}
	}
	
	public required init(name: String) {
		fatalError("Cannot use init(name:)")
	}
}

