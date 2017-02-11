//
//  SecuTrialBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


public protocol SecuTrialBean {
	
	init()
	
	init(node: SOAPNode) throws
	
	func node(_ name: String) -> SOAPNode
}

