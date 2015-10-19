//
//  STFormDataRecordBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
Manually created FormDataRecordBean.
*/
public class STFormDataRecordBean: SecuTrialBean {
	
	let node: SOAPNode
	
	public var project: String?
	
	public var centre: String?
	
	public var patient: STPatientBean?
	
	public var visit: STVisitBean?
	
//	public var ae: STAdverseEventBean?
	
	public var form: String?
	
	public var item: [STFormDataItemBean]?
	
	public required init(node: SOAPNode) throws {
		self.node = node
		if let txt = (node.childNamed("project") as? SOAPTextNode)?.text {
			project = txt
		}
		if let txt = (node.childNamed("centre") as? SOAPTextNode)?.text {
			centre = txt
		}
		if let txt = (node.childNamed("statusCode") as? SOAPTextNode)?.text {
			form = txt
		}
		if let sub = node.childNamed("patient") {
			patient = try STPatientBean(node: sub)
		}
		if let sub = node.childNamed("visit") {
			visit = try STVisitBean(node: sub)
		}
//		if let sub = node.childNamed("ae") {
//			ae = try STAdverseEventBean(node: sub)
//		}
		if let subs = node.childrenNamed("item") {
			item = try subs.map() { try STFormDataItemBean(node: $0) }
		}
	}
}

