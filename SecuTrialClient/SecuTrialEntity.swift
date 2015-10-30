//
//  SecuTrialEntityBase.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 29/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
A SecuTrial form array element.
*/
class SecuTrialEntityArray: SOAPNode {
	
	init(node: SOAPNode) throws {
		super.init(name: node.name)
		copy(node)
	}
	
	required init(name: String) {
		fatalError("Cannot use init(name:)")
	}
	
	func objects<T: SecuTrialEntityObject>(entity: String, type: T.Type? = nil) -> [T] {
		var objects = [T]()
		for object in childNodes {
			if let obj = object as? T where obj.entity == entity {
				objects.append(obj)
			}
		}
		return objects
	}
}


/**
A SecuTrial form dictionary element.
*/
public class SecuTrialEntityDictionary: SOAPNode {
	
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

