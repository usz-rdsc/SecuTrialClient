//
//  SOAPNode.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SOAPNode {
	public let name: String
	
	public var namespace: SOAPNamespace?
	
	var attributes = [SOAPNodeAttribute]()
	
	var childNodes = [SOAPNode]()
	
	public init(name inName: String) {
		name = inName
	}
	
	
	// MARK: - Chid Nodes
	
	func addChild(child: SOAPNode) {
		childNodes.append(child)
	}
	
	func numChildNodes() -> Int {
		return childNodes.count
	}
	
	
	// MARK: - Serialization
	
	public func asXMLString(indentLevel: Int = 0) -> String {
		var tabs = ""
		for _ in 0..<indentLevel {
			tabs += "\t"
		}
		
		// build node name and add attributes
		let nodeName = (nil != namespace) ? "\(namespace!.name):\(name)" : name
		var attrs = [nodeName]
		if let namespace = namespace {
			attrs.append(namespace.asXMLAttributeString())
		}
		attrs.appendContentsOf(attributes.map() { return $0.asXMLAttributeString() })
		let parts = attrs.joinWithSeparator(" ")
		
		// add child nodes, if any, and create string
		if 0 == numChildNodes() {
			return "\(tabs)<\(parts)/>"
		}
		let children = childNodesAsXMLString(useTabs: tabs, childIndentLevel: indentLevel+1)
		return "\(tabs)<\(parts)>\(children)</\(nodeName)>"
	}
	
	func childNodesAsXMLString(useTabs tabs: String, childIndentLevel: Int = 0) -> String {
		let children = childNodes.map() { return $0.asXMLString(childIndentLevel) }.joinWithSeparator("\n")
		return "\n\(children)\n\(tabs)"
	}
}

public class SOAPTextNode: SOAPNode {
	public var text: String?
	
	public convenience init(name: String, textValue: String) {
		self.init(name: name)
		text = textValue
	}
	
	override func numChildNodes() -> Int {
		return 1
	}
	
	override func childNodesAsXMLString(useTabs tabs: String, childIndentLevel: Int = 0) -> String {
		return text ?? ""
	}
}

public class SOAPNamespace {
	public let name: String
	
	public let url: String
	
	public init(name inName: String, url inURL: String) {
		name = inName
		url = inURL
	}
	
	public func asXMLAttributeString() -> String {
		return "xmlns:\(name)=\"\(url)\""
	}
}

class SOAPNodeAttribute {
	let name: String
	
	var value: String?
	
	init(name inName: String) {
		name = inName
	}
	
	convenience init(name: String, value inValue: String) {
		self.init(name: name)
		value = inValue
	}
	
	func asXMLAttributeString() -> String {
		let val = value ?? ""		// TODO: encode!
		return "\(name)=\"\(val)\""
	}
}

