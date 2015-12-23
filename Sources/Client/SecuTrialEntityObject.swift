//
//  SecuTrialEntityObject.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 29/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
import Beans
#endif


/**
An XML node in the SecuTrial form that represents an Object.
*/
public class SecuTrialEntityObject: SOAPNode {
	
	public var entity = "Object"
	
	public var properties: [SecuTrialEntityProperty]?
	
	public var type: SecuTrialEntityDictionary?
	
	public init(node: SOAPNode) throws {
		super.init(name: node.name)
		copy(node)
		
		if let ent = attr("entity") {
			entity = ent
		}
		
		var props = [SecuTrialEntityProperty]()
		for child in childNodes {
			if let prop = child as? SecuTrialEntityProperty {		// "property" == child.name
				props.append(prop)
			}
			else if let typ = child as? SecuTrialEntityDictionary {		// "dict" == child.name
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
	
	public subscript(name: String) -> SecuTrialEntityProperty? {
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
		if let property = self[name]?.value {
			if let refid = property.attr("refid"), let ref = document.nodeWithId(refid) as? T {
				return ref
			}
			return property as? T
		}
		return nil
	}
	
	public func propertyValueString(name: String) -> String? {
		return self[name]?.stringValue
	}
	
	public func propertyArrayValueObjects<T: SecuTrialEntityObject>(name: String, entities: String, type: T.Type? = nil) -> [T] {
		if let arr = propertyValue(name) as? SecuTrialEntityArray {
			return arr.objects(entities, type: T.self)
		}
		return []
	}
}


public class SecuTrialEntityProperty: SOAPNode {
	
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

