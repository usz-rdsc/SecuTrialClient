//
//  SOAPNode.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
Instances of this class represent one XML node in a SOAP tree.
*/
public class SOAPNode {
	
	/// The node name.
	public let name: String
	
	/// The namespace of the node
	public var namespace: SOAPNamespace?
	
	/// Other namespaces defined on the node
	var namespaces: [SOAPNamespace]?
	
	/// The parent node.
	weak var parent: SOAPNode?
	
	/// Node attributes.
	var attributes = [SOAPNodeAttribute]()
	
	/// Child nodes.
	private(set) var childNodes = [SOAPNode]()
	
	
	public required init(name: String) {
		self.name = name
	}
	
	public func copy(other: SOAPNode) {
		namespace = other.namespace
		namespaces = other.namespaces
		attributes = other.attributes
		for child in other.childNodes {
			addChild(child)
		}
	}
	
	/**
	Replaces a given node with itself, copying all information from the other node.
	
	You usually use this to use a specific subclass in place of a generic SOAPNode.
	*/
	public class func replace(otherNode other: SOAPNode) -> Self {
		let node = self.init(name: other.name)
		node.copy(other)
		if let parent = other.parent {
			let idx = parent.removeChild(other)
			parent.addChild(node, atIndex: idx)
		}
		return node
	}
	
	
	// MARK: - Child Nodes
	
	/**
	Add the given node as a child node to the receiver, setting the parent pointer accordingly.
	*/
	func addChild(child: SOAPNode, atIndex: Int? = nil) {
		if let parent = child.parent {
			parent.removeChild(child)
		}
		child.parent = self
		if let idx = atIndex where idx < childNodes.count {
			childNodes.insert(child, atIndex: idx)
		}
		else {
			childNodes.append(child)
		}
	}
	
	/**
	Remove the given node from the receiver's child nodes, unsetting the parent pointer accordingly. This method does nothing if the given
	node is not a child node of the receiver.
	*/
	func removeChild(child: SOAPNode) -> Int? {
		let idx = childNodes.indexOf() { $0 === child }
		if nil != idx {
			child.parent = nil
			childNodes = childNodes.filter() { $0 !== child }
		}
		return idx
	}
	
	/**
	Return the first child node with the given name and of the given type.
	*/
	public func childNamed<T: SOAPNode>(name: String, ofType: T.Type? = nil) -> T? {
		for child in childNodes {
			if name == child.name && child is T {
				return child as! T
			}
		}
		return nil
	}
	
	/**
	Return an array of child nodes with the given name.
	*/
	public func childrenNamed(name: String) -> [SOAPNode] {
		return childNodes.filter() { $0.name == name }
	}
	
	func numChildNodes() -> Int {
		return childNodesForXMLString().count
	}
	
	
	// MARK: - Namespaces
	
	func namespaceIsInScope(namespace otherNS: SOAPNamespace) -> Bool {
		if let myNS = namespace where otherNS == myNS {
			return true
		}
		if let nss = namespaces {
			for ns in nss {
				if ns == otherNS {
					return true
				}
			}
		}
		return parent?.namespaceIsInScope(namespace: otherNS) ?? false
	}
	
	func namespaceWithURI(uri: String) -> SOAPNamespace? {
		if let nss = namespaces {
			for ns in nss {
				if ns.url == uri {
					return ns
				}
			}
		}
		return parent?.namespaceWithURI(uri)
	}
	
	
	// MARK: - Attributes
	
	public func attr(name: String, value: String? = nil) -> String? {
		for attr in attributes {
			if name == attr.name {
				if let value = value {
					attr.value = value
				}
				return attr.value
			}
		}
		if let value = value {
			attributes.append(SOAPNodeAttribute(name: name, value: value))
			return value
		}
		return nil
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
		if let ns = namespace where nil == parent || !parent!.namespaceIsInScope(namespace: ns) {
			attrs.append(ns.asXMLAttributeString())
		}
		if let ns = namespaces {
			attrs.appendContentsOf(ns.filter() { nil == namespace || $0.url != namespace!.url }.map() { $0.asXMLAttributeString() })
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
	
	func childNodesForXMLString() -> [SOAPNode] {
		return childNodes
	}
	
	func childNodesAsXMLString(useTabs tabs: String, childIndentLevel: Int = 0) -> String {
		let children = childNodesForXMLString().map() { return $0.asXMLString(childIndentLevel) }.joinWithSeparator("\n")
		return "\n\(children)\n\(tabs)"
	}
}


public class SOAPTextNode: SOAPNode {
	public var text: String?
	
	public convenience init(name: String, textValue: String) {
		self.init(name: name)
		text = textValue
	}
	
	public override func copy(other: SOAPNode) {
		super.copy(other)
		childNodes.removeAll()
		if let other = other as? SOAPTextNode {
			text = other.text
		}
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
	
	public init(name: String, url: String) {
		self.name = name
		self.url = url
	}
	
	public func asXMLAttributeString() -> String {
		return "xmlns:\(name)=\"\(url)\""
	}
}

public func ==(left: SOAPNamespace, right: SOAPNamespace) -> Bool {
	return left.name == right.name && left.url == right.url
}


class SOAPNodeAttribute {
	let name: String
	
	var value: String?
	
	init(name: String) {
		self.name = name
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

