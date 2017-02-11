//
//  SecuTrialSurvey.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 23/12/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation
import ResearchKit


/// Callback used when a survey completes successfully.
public typealias SecuTrialSurveyCompletion = ((_ viewController: ORKTaskViewController, _ response: SecuTrialBeanFormDataRecord) -> Void)

/// Callback used when a survey fails or is cancelled.
public typealias SecuTrialSurveyCancelOrFailure = ((_ viewController: ORKTaskViewController, _ error: Error?) -> Void)


/**
Instances of this class can be used to create ResearchKit-surveys from secuTrial forms and a given import format.
*/
open class SecuTrialSurvey: NSObject, ORKTaskViewControllerDelegate {
	
	fileprivate var whenCompleted: SecuTrialSurveyCompletion?
	
	fileprivate var whenCancelledOrFailed: SecuTrialSurveyCancelOrFailure?
	
	open let form: SecuTrialEntityForm
	
	open let importFormat: SecuTrialEntityImportFormat
	
	
	public init(form: SecuTrialEntityForm, importFormat: SecuTrialEntityImportFormat) {
		self.form = form
		self.importFormat = importFormat
	}
	
	
	// MARK: - Surveys
	
	/**
	Creates a task from the receiver's `form`, then returns a task view controller set up to run through this task.
	
	- parameter complete: The callback to call when the survey was completed successfully
	- parameter failure: The callback to call when the survey was cancelled or an error occurred
	- returns: An ORKTaskViewController, set up with the `form`'s task, ready to be presented to the user
	*/
	open func taskViewController(complete: @escaping SecuTrialSurveyCompletion, failure: @escaping SecuTrialSurveyCancelOrFailure) throws -> ORKTaskViewController {
		if nil != whenCancelledOrFailed || nil != whenCompleted {
			throw SecuTrialError.alreadyPerformingSurvey
		}
		if !form.importFormats.contains(importFormat) {
			throw SecuTrialError.importFormatNotKnownToForm
		}
		
		whenCompleted = complete
		whenCancelledOrFailed = failure
		let task = try form.strk_asTask(with: importFormat)
		let viewController = ORKTaskViewController(task: task, taskRun: nil)
		viewController.delegate = self
		return viewController
	}
	
	/**
	All result data gathered from the survey.
	*/
	open func resultDataRecord() throws -> SecuTrialBeanFormDataRecord {
		throw SecuTrialError.error("Not implemented")
	}
	
	
	// MARK: - Task View Controller Delegate
	
	open func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
		if let error = error {
			didFailWithError(taskViewController, error: error)
		}
		else {
			didFinish(taskViewController, reason: reason)
		}
	}
	
	
	// MARK: - Survey Completion
	
	func didFinish(_ viewController: ORKTaskViewController, reason: ORKTaskViewControllerFinishReason) {
		switch reason {
		case .failed:
			didFailWithError(viewController, error: SecuTrialError.surveyFinishedWithError)
		case .completed:
			didComplete(viewController)
		case .discarded:
			didFailWithError(viewController, error: nil)
		case .saved:
			// TODO: support saving tasks
			didFailWithError(viewController, error: nil)
		}
	}
	
	func didComplete(_ viewController: ORKTaskViewController) {
		do {
			let responseItems = try viewController.result.strk_asResponseForTask(viewController.task!)
			let data = SecuTrialBeanFormDataRecord()
			data.form = importFormat.identifier!		// throwing ImportFormatWithoutIdentifier when instantiating the task view controller if this is nil
//			data.patient = patient
//			data.visit = visit
			data.item = responseItems
			whenCompleted?(viewController, data)
			done()
		}
		catch let error {
			didFailWithError(viewController, error: error)
		}
	}
	
	func didFailWithError(_ viewController: ORKTaskViewController, error: Error?) {
		whenCancelledOrFailed?(viewController, error)
		done()
	}
	
	fileprivate func done() {
		whenCompleted = nil
		whenCancelledOrFailed = nil
	}
}

