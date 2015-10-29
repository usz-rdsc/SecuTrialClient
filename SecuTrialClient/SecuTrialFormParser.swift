//
//  SecuTrialFormParser.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SecuTrialFormParser {
	
	public init() {  }
	
	public func parseLocalFile(url: NSURL) throws -> [STFForm] {
		guard let data = NSData(contentsOfURL: url) else {
			throw SecuTrialError.Error("Failed to read data from «\(url)»")
		}
		return try parse(data)
	}
	
	public func parse(data: NSData) throws -> [STFForm] {
		let parser = SOAPParser()
		parser.onEndElement = { element in
			if "array" == element.name {
				return try STFArray(node: element)
			}
			if "dict" == element.name {
				return try STFDict(node: element)
			}
			if "object" == element.name {
				if let entity = element.attr("entity") {
					if "Form" == entity {
						return try STFForm(node: element)
					}
					if "Formgroup" == entity {
						return try STFFormGroup(node: element)
					}
					if "Formfield" == entity {
						return try STFFormField(node: element)
					}
					if "Importmapping" == entity {
						return try STFImportMapping(node: element)
					}
					if "Importformat" == entity {
						return try STFImportFormat(node: element)
					}
				}
				return try STFObject(node: element)
			}
			if "property" == element.name {
				return try STFProperty(node: element)
			}
			return nil
		}
		
		let root = try parser.parse(data) as! STFDict
		if let formarr = root["forms"] as? STFArray {
			return formarr.objects("Form", type: STFForm.self)
		}
		return []
	}
}


class STFArray: SOAPNode {
	
	init(node: SOAPNode) throws {
		super.init(name: node.name)
		copy(node)
	}

	required init(name: String) {
		fatalError("Cannot use init(name:)")
	}
	
	func objects<T: STFObject>(entity: String, type: T.Type? = nil) -> [T] {
		var objects = [T]()
		for object in childNodes {
			if let obj = object as? T where obj.entity == entity {
				objects.append(obj)
			}
		}
		return objects
	}
}


public class STFDict: SOAPNode {
	
	var dictionary: [String: SOAPNode]?
	
	public init(node: SOAPNode) throws {
		super.init(name: node.name)
		copy(node)
		
		var dict = [String: SOAPNode]()
		var current: String?
		for child in childNodes {
			if "key" == child.name {
				if let str = child.childNamed("string", ofType: SOAPTextNode.self)?.text {
					current = str
				}
				else {
					throw SecuTrialError.InvalidDOM("<key> nodes must contain a <string> node with the key name, this one is: \(child.asXMLString())")
				}
			}
			else if "value" == child.name {
				if let current = current {
					if 1 == child.childNodes.count {
						dict[current] = child.childNodes[0]
					}
					else {
						throw SecuTrialError.InvalidDOM("<value> nodes can only contain one child node, this one has: \(child.asXMLString())")
					}
				}
			}
			else {
				throw SecuTrialError.InvalidDOM("<dict> nodes should only contain <key> and <value> nodes, but has <\(child.name)>")
			}
		}
		dictionary = dict
	}

	public required init(name: String) {
	    fatalError("Cannot use init(name:)")
	}
	
	public subscript(name: String) -> SOAPNode? {
		return dictionary?[name]
	}
}


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

