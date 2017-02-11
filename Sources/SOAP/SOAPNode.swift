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
open class SOAPNode {
	
	/// The id, if any.
	open var id: String? {
		return self.attr("id")
	}
	
	/// The node name.
	open let name: String
	
	/// The namespace of the node
	open var namespace: SOAPNamespace?
	
	/// Other namespaces defined on the node
	var namespaces: [SOAPNamespace]?
	
	/// The parent node.
	public weak var parent: SOAPNode?
	
	/// The root node.
	open var document: SOAPNode {
		return parent?.document ?? self
	}
	
	/// Node attributes.
	open var attributes = [SOAPNodeAttribute]()
	
	/// Child nodes.
	public fileprivate(set) var childNodes = [SOAPNode]()
	
	
	public required init(name: String) {
		self.name = name
	}
	
	open func copy(_ other: SOAPNode) {
		namespace = other.namespace
		namespaces = other.namespaces
		attributes = other.attributes
		for child in other.childNodes {
			addChild(child)
		}
	}
	
	/**
	Replaces a given node with a new instance of itself, copying all information from the other node.
	
	You usually use this to use a specific subclass in place of a generic SOAPNode.
	*/
	@discardableResult
	open class func replace(with other: SOAPNode) -> Self {
		let node = self.init(name: other.name)
		node.copy(other)
		node.replace(with: other)
		return node
	}
	
	/**
	Replaces the given node with itself in the DOM.
	*/
	open func replace(with other: SOAPNode) {
		if let parent = other.parent {
			let idx = parent.removeChild(other)
			parent.addChild(self, atIndex: idx)
		}
	}
	
	
	// MARK: - Child Nodes
	
	/**
	Add the given node as a child node to the receiver, setting the parent pointer accordingly.
	*/
	open func addChild(_ child: SOAPNode, atIndex: Int? = nil) {
		if let parent = child.parent {
			parent.removeChild(child)
		}
		child.parent = self
		if let idx = atIndex, idx < childNodes.count {
			childNodes.insert(child, at: idx)
		}
		else {
			childNodes.append(child)
		}
	}
	
	/**
	Remove the given node from the receiver's child nodes, unsetting the parent pointer accordingly. This method does nothing if the given
	node is not a child node of the receiver.
	*/
	@discardableResult
	open func removeChild(_ child: SOAPNode) -> Int? {
		let idx = childNodes.index() { $0 === child }
		if nil != idx {
			child.parent = nil
			childNodes = childNodes.filter() { $0 !== child }
		}
		return idx
	}
	
	/**
	Return the first child node with the given name and of the given type.
	*/
	open func childNamed<T: SOAPNode>(_ name: String, ofType: T.Type? = nil) -> T? {
		for child in childNodes {
			if name == child.name && child is T {
				return (child as! T)
			}
		}
		return nil
	}
	
	/**
	Return an array of child nodes with the given name.
	*/
	open func childrenNamed(_ name: String) -> [SOAPNode] {
		return childNodes.filter() { $0.name == name }
	}
	
	open func numChildNodes() -> Int {
		return childNodesForXMLString().count
	}
	
	open func nodeWithId(_ id: String) -> SOAPNode? {
		if id == self.id {
			return self
		}
		for child in childNodes {
			if let found = child.nodeWithId(id) {
				return found
			}
		}
		return nil
	}
	
	
	// MARK: - Namespaces
	
	func namespaceIsInScope(namespace otherNS: SOAPNamespace) -> Bool {
		if let myNS = namespace, otherNS == myNS {
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
	
	func namespaceWithURI(_ uri: String) -> SOAPNamespace? {
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
	
	/** Get the desired attribute's string value, if it exist. If a new value is provided, will set new value but return the old value. */
	@discardableResult
	open func attr(_ name: String, value: String? = nil) -> String? {
		for attr in attributes {
			if name == attr.name {
				let val = attr.value
				if let value = value {
					attr.value = value
				}
				return val
			}
		}
		if let value = value {
			attributes.append(SOAPNodeAttribute(name: name, value: value))
		}
		return nil
	}
	
	
	// MARK: - Serialization
	
	open func asXMLString(_ indentLevel: Int = 0) -> String {
		var tabs = ""
		for _ in 0..<indentLevel {
			tabs += "\t"
		}
		
		// build node name and add attributes
		let nodeName = (nil != namespace) ? "\(namespace!.name):\(name)" : name
		var attrs = [nodeName]
		if let ns = namespace, nil == parent || !parent!.namespaceIsInScope(namespace: ns) {
			attrs.append(ns.asXMLAttributeString())
		}
		if let ns = namespaces {
			attrs.append(contentsOf: ns.filter() { nil == namespace || $0.url != namespace!.url }.map() { $0.asXMLAttributeString() })
		}
		attrs.append(contentsOf: attributes.map() { return $0.asXMLAttributeString() })
		let parts = attrs.joined(separator: " ")
		
		// add child nodes, if any, and create string
		if 0 == numChildNodes() {
			return "\(tabs)<\(parts)/>"
		}
		let children = childNodesAsXMLString(useTabs: tabs, childIndentLevel: indentLevel+1)
		return "\(tabs)<\(parts)>\(children)</\(nodeName)>"
	}
	
	open func childNodesForXMLString() -> [SOAPNode] {
		return childNodes
	}
	
	func childNodesAsXMLString(useTabs tabs: String, childIndentLevel: Int = 0) -> String {
		let children = childNodesForXMLString().map() { return $0.asXMLString(childIndentLevel) }.joined(separator: "\n")
		return "\n\(children)\n\(tabs)"
	}
}


open class SOAPTextNode: SOAPNode {
	open var text: String?
	
	public convenience init(name: String, textValue: String) {
		self.init(name: name)
		text = textValue
	}
	
	open override func copy(_ other: SOAPNode) {
		super.copy(other)
		childNodes.removeAll()
		if let other = other as? SOAPTextNode {
			text = other.text
		}
	}
	
	open override func numChildNodes() -> Int {
		return 1
	}
	
	override func childNodesAsXMLString(useTabs tabs: String, childIndentLevel: Int = 0) -> String {
		return text ?? ""
	}
}


open class SOAPNamespace {
	open let name: String
	
	open let url: String
	
	public init(name: String, url: String) {
		self.name = name
		self.url = url
	}
	
	open func asXMLAttributeString() -> String {
		return "xmlns:\(name)=\"\(url)\""
	}
}

public func ==(left: SOAPNamespace, right: SOAPNamespace) -> Bool {
	return left.name == right.name && left.url == right.url
}


open class SOAPNodeAttribute {
	open let name: String
	
	open var value: String?
	
	public init(name: String) {
		self.name = name
	}
	
	public convenience init(name: String, value inValue: String) {
		self.init(name: name)
		value = inValue
	}
	
	func asXMLAttributeString() -> String {
		let val = value ?? ""		// TODO: encode!
		return "\(name)=\"\(val)\""
	}
}

