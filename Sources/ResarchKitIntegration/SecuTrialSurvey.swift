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
public typealias SecuTrialSurveyCompletion = ((viewController: ORKTaskViewController, response: SecuTrialBeanFormDataRecord) -> Void)

/// Callback used when a survey fails or is cancelled.
public typealias SecuTrialSurveyCancelOrFailure = ((viewController: ORKTaskViewController, error: ErrorType?) -> Void)


/**
Instances of this class can be used to create ResearchKit-surveys from secuTrial forms.
*/
public class SecuTrialSurvey: NSObject, ORKTaskViewControllerDelegate {
	
	private var whenCompleted: SecuTrialSurveyCompletion?
	
	private var whenCancelledOrFailed: SecuTrialSurveyCancelOrFailure?
	
	public let form: SecuTrialEntityForm
	
	public let importFormat: SecuTrialEntityImportFormat
	
	
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
	public func taskViewController(complete complete: SecuTrialSurveyCompletion, failure: SecuTrialSurveyCancelOrFailure) throws -> ORKTaskViewController {
		if nil != whenCancelledOrFailed || nil != whenCompleted {
			throw SecuTrialError.AlreadyPerformingSurvey
		}
		if !form.importFormats.contains(importFormat) {
			throw SecuTrialError.ImportFormatNotKnownToForm
		}
		
		whenCompleted = complete
		whenCancelledOrFailed = failure
		let task = try form.strk_asTask(importFormat)
		let viewController = ORKTaskViewController(task: task, taskRunUUID: nil)
		viewController.delegate = self
		return viewController
	}
	
	/**
	All result data gathered from the survey.
	*/
	public func resultDataRecord() throws -> SecuTrialBeanFormDataRecord {
		throw SecuTrialError.Error("Not implemented")
	}
	
	
	// MARK: - Task View Controller Delegate
	
	public func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
		if let error = error {
			didFailWithError(taskViewController, error: error)
		}
		else {
			didFinish(taskViewController, reason: reason)
		}
	}
	
	
	// MARK: - Survey Completion
	
	func didFinish(viewController: ORKTaskViewController, reason: ORKTaskViewControllerFinishReason) {
		switch reason {
		case .Failed:
			didFailWithError(viewController, error: SecuTrialError.SurveyFinishedWithError)
		case .Completed:
			didComplete(viewController)
		case .Discarded:
			didFailWithError(viewController, error: nil)
		case .Saved:
			// TODO: support saving tasks
			didFailWithError(viewController, error: nil)
		}
	}
	
	func didComplete(viewController: ORKTaskViewController) {
		do {
			let responseItems = try viewController.result.strk_asResponseForTask(viewController.task!)
			let data = SecuTrialBeanFormDataRecord()
			data.form = importFormat.identifier!		// throwing ImportFormatWithoutIdentifier when instantiating the task view controller if this is nil
			data.item = responseItems
			whenCompleted?(viewController: viewController, response: data)
			done()
		}
		catch let error {
			didFailWithError(viewController, error: error)
		}
	}
	
	func didFailWithError(viewController: ORKTaskViewController, error: ErrorType?) {
		whenCancelledOrFailed?(viewController: viewController, error: error)
		done()
	}
	
	private func done() {
		whenCompleted = nil
		whenCancelledOrFailed = nil
	}
}

