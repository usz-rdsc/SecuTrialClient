//
//  SecuTrialEntityForm+ResearchKit.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 23/12/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import ResearchKit


extension SecuTrialEntityForm {
	
	public func strk_asTask(identifier: String = NSUUID().UUIDString) throws -> ORKTask {
		return ORKOrderedTask(identifier: identifier, steps: try strk_asSteps())
	}
	
	public func strk_asSteps() throws -> [ORKStep] {
		var steps = [ORKStep]()
		for group in groups {
			let substeps = try group.strk_asSteps()
			steps.appendContentsOf(substeps)
		}
		return steps
	}
}


extension SecuTrialEntityFormGroup {
	
	public func strk_asSteps() throws -> [ORKStep] {
		var steps = [ORKStep]()
		
		// add questions
		for field in fields {
			if let step = field.strk_asStep() {
				steps.append(step)
			}
		}
		
		// only use if not empty
		if !steps.isEmpty {
			let intro = ORKInstructionStep(identifier: "label_\(id ?? "group")")
			intro.title = label
			steps.insert(intro, atIndex: 0)
		}
		return steps
	}
}

