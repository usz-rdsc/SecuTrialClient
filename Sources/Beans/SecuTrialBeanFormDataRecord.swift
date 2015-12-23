//
//  SecuTrialBeanFormDataRecord.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


/**
Manually created FormDataRecordBean.
*/
public class SecuTrialBeanFormDataRecord: SecuTrialBean {
	
	public var project: String?
	
	public var centre: String?
	
	public var form: String?
	
	public var patient: SecuTrialBeanPatient?
	
	public var visit: SecuTrialBeanVisit?
	
//	public var ae: STAdverseEventBean?
	
	public var item: [SecuTrialBeanFormDataItem]?
	
	
	public required init() {
	}
	
	public required init(node: SOAPNode) throws {
		if let txt = (node.childNamed("project") as? SOAPTextNode)?.text {
			project = txt
		}
		if let txt = (node.childNamed("centre") as? SOAPTextNode)?.text {
			centre = txt
		}
		if let txt = (node.childNamed("form") as? SOAPTextNode)?.text {
			form = txt
		}
		if let sub = node.childNamed("patient") {
			patient = try SecuTrialBeanPatient(node: sub)
		}
		if let sub = node.childNamed("visit") {
			visit = try SecuTrialBeanVisit(node: sub)
		}
//		if let sub = node.childNamed("ae") {
//			ae = try STAdverseEventBean(node: sub)
//		}
		item = try node.childrenNamed("item").map() { try SecuTrialBeanFormDataItem(node: $0) }
	}
	
	
	public func node(name: String) -> SOAPNode {
		let node = SOAPNode(name: name)
		if let txt = project {
			node.addChild(SOAPTextNode(name: "project", textValue: txt))
		}
		if let txt = centre {
			node.addChild(SOAPTextNode(name: "centre", textValue: txt))
		}
		if let txt = form {
			node.addChild(SOAPTextNode(name: "form", textValue: txt))
		}
		if let sub = patient {
			node.addChild(sub.node("patient"))
		}
		if let sub = visit {
			node.addChild(sub.node("visit"))
		}
//		if let sub = ae {
//			node.addChild(sub.node("ae"))
//		}
		if let subs = item {
			for sub in subs {
				node.addChild(sub.node("item"))
			}
		}
		return node
	}
}

