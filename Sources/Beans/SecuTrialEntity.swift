//
//  SecuTrialEntityBase.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 29/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


/**
A SecuTrial form array element.
*/
open class SecuTrialEntityArray: SOAPNode {
	
	public init(node: SOAPNode) throws {
		super.init(name: node.name)
		copy(node)
	}
	
	public required init(name: String) {
		fatalError("Cannot use init(name:)")
	}
	
	public func objects<T: SecuTrialEntityObject>(_ entity: String, type: T.Type? = nil) -> [T] {
		var objects = [T]()
		for object in childNodes {
			var obj = object
			if let refid = object.attr("refid"), let ref = document.nodeWithId(refid) {
				obj = ref
			}
			if let obj = obj as? T, obj.entity == entity {
				objects.append(obj)
			}
		}
		return objects
	}
}


/**
A SecuTrial form dictionary element.
*/
open class SecuTrialEntityDictionary: SOAPNode {
	
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
					throw SecuTrialError.invalidDOM("<key> nodes must contain a <string> node with the key name, this one is: \(child.asXMLString())")
				}
			}
			else if "value" == child.name {
				if let current = current {
					if 1 == child.childNodes.count {
						dict[current] = child.childNodes[0]
					}
					else {
						throw SecuTrialError.invalidDOM("<value> nodes can only contain one child node, this one has: \(child.asXMLString())")
					}
				}
			}
			else {
				throw SecuTrialError.invalidDOM("<dict> nodes should only contain <key> and <value> nodes, but has <\(child.name)>")
			}
		}
		dictionary = dict
	}
	
	public required init(name: String) {
		fatalError("Cannot use init(name:)")
	}
	
	open subscript(name: String) -> SOAPNode? {
		return dictionary?[name]
	}
}

