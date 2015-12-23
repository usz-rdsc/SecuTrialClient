//
//  SecuTrialEntityFormField+ResearchKit.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 23/12/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import ResearchKit


extension SecuTrialEntityFormField {
	
	public func strk_asStep() throws -> ORKStep {
		return ORKInstructionStep(identifier: "intro_to_\(id ?? "field")")
	}
}
