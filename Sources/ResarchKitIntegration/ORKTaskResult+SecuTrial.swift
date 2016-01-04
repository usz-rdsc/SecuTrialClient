//
//  ORKTaskResult+SecuTrial.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 04/01/16.
//  Copyright © 2016 USZ. All rights reserved.
//

import ResearchKit


extension ORKTaskResult {
	
	/**
	Collects responses for all questions with answers.
	
	- parameter task: The task this result is for
	- returns: An array of SecuTrialBeanFormDataItem instances for all completed questions
	*/
	func strk_asResponseForTask(task: ORKTask) throws -> [SecuTrialBeanFormDataItem] {
		guard let results = results as? [ORKStepResult] else {
			return []
		}
		
		// loop results to collect responses
		var items = [SecuTrialBeanFormDataItem]()
		for result in results {
			if let subitems = try result.strk_stepResponse(task) {
				items.appendContentsOf(subitems)
			}
		}
		return items
	}
}


extension ORKStepResult {
	
	/**
	Creates a SecuTrialBeanFormDataItem per ORKStep in the given ORKTask. Questions that do not have answers will be omitted.
	
	- parameter task: The ORKTask that was associated with the parent task result
	- returns: An array of SecuTrialBeanFormDataItem or nil
	*/
	func strk_stepResponse(task: ORKTask) throws -> [SecuTrialBeanFormDataItem]? {
		guard let results = results else {
			return nil
		}
		
		// loop results to collect answers; omit questions that do not have answers
		var items = [SecuTrialBeanFormDataItem]()
		for result in results {
			let step = task.stepWithIdentifier?(result.identifier) as? ORKQuestionStep
			do {	// TODO: remove when all result types are supported
			if let result = result as? ORKQuestionResult, let response = try result.strk_answerAsResponseValueOfStep(step) {
				let item = SecuTrialBeanFormDataItem(key: result.identifier, value: response)
				items.append(item)
			}
			else {
				throw SecuTrialError.Error("I cannot handle ORKStepResult result \(result)")
			}
			}
			catch let error {		// TODO: remove when all result types are supported
				strk_warn("CAUGHT: \(error)")
			}
		}
		return items
	}
}


extension ORKQuestionResult {
	
	/**
	Return a string representing the receiver's answer, if any.
	
	TODO: Cannot override methods defined in extensions, hence we need to check for the ORKQuestionResult subclass and then call the method
	implemented in the extensions below.
	
	- parameter step: The ORKQuestionStep subclass to return the response for
	- returns: A string response or nil if there is none
	*/
	func strk_answerAsResponseValueOfStep(step: ORKQuestionStep?) throws -> String? {
//		if let this = self as? ORKChoiceQuestionResult {
//			return this.strk_asQuestionAnswers(fhirType)
//		}
		if let this = self as? ORKTextQuestionResult {
			return this.strk_asResponseValue()
		}
		if let this = self as? ORKNumericQuestionResult {
			return this.strk_asResponseValue()
		}
//		if let this = self as? ORKScaleQuestionResult {
//			return this.chip_asQuestionAnswers(fhirType)
//		}
		if let this = self as? ORKBooleanQuestionResult {
			return this.strk_asResponseValue()
		}
//		if let this = self as? ORKTimeOfDayQuestionResult {
//			return this.chip_asQuestionAnswers(fhirType)
//		}
//		if let this = self as? ORKTimeIntervalQuestionResult {
//			return this.chip_asQuestionAnswers(fhirType)
//		}
//		if let this = self as? ORKDateQuestionResult {
//			return this.chip_asQuestionAnswers(fhirType)
//		}
		throw SecuTrialError.Error("I don't understand ORKQuestionResult answer from \(self)")
	}
}


extension ORKTextQuestionResult {
	func strk_asResponseValue() -> String? {
		guard let text = textAnswer else {
			return nil
		}
		return text
	}
}


extension ORKNumericQuestionResult {
	func strk_asResponseValue() -> String? {
		guard let numeric = numericAnswer else {
			return nil
		}
		if let unit = unit {
			return "\(numeric) \(unit)"
		}
		return "\(numeric)"
	}
}


extension ORKBooleanQuestionResult {
	func strk_asResponseValue() -> String? {
		if let boolean = booleanAnswer?.boolValue {
			return boolean ? "1" : "0"
		}
		return nil
	}
}
