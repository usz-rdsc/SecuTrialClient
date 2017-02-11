//
//  SecuTrialEntityForm+ResearchKit.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 23/12/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import ResearchKit


extension SecuTrialEntityForm {
	
	public func strk_asTask(with format: SecuTrialEntityImportFormat) throws -> ORKTask {
		guard let identifier = format.identifier else {
			throw SecuTrialError.importFormatWithoutIdentifier
		}
		return try strk_asTask(with: identifier)
	}
	
	public func strk_asTask(with identifier: String = UUID().uuidString) throws -> ORKTask {
		return ORKOrderedTask(identifier: identifier, steps: try strk_asSteps())
	}
	
	public func strk_asSteps() throws -> [ORKStep] {
		var steps = [ORKStep]()
		for group in groups {
			let substeps = try group.strk_asSteps()
			steps.append(contentsOf: substeps)
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
		
		// only add instruction step if the group's steps are not empty
		if !steps.isEmpty {
			let intro = ORKInstructionStep(identifier: "label_\(id ?? "group")")
			intro.title = label
			steps.insert(intro, at: 0)
		}
		return steps
	}
}

