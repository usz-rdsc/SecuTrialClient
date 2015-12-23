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
public typealias SecuTrialSurveyCompletion = ((viewController: ORKTaskViewController, response: String?) -> Void)

/// Callback used when a survey fails or is cancelled.
public typealias SecuTrialSurveyCancelOrFailure = ((viewController: ORKTaskViewController, error: ErrorType?) -> Void)


/**
Instances of this class can be used to create ResearchKit-surveys from secuTrial forms.
*/
public class SecuTrialSurvey: NSObject, ORKTaskViewControllerDelegate {
	
	private var whenCompleted: SecuTrialSurveyCompletion?
	
	private var whenCancelledOrFailed: SecuTrialSurveyCancelOrFailure?
	
	public let form: SecuTrialEntityForm
	
	public init(form: SecuTrialEntityForm) {
		self.form = form
	}
	
	
	// MARK: - Surveys
	
	public func taskViewController(complete complete: SecuTrialSurveyCompletion, failure: SecuTrialSurveyCancelOrFailure) throws -> ORKTaskViewController {
		whenCompleted = complete
		whenCancelledOrFailed = failure
		let task = try form.strk_asTask()
		let viewController = ORKTaskViewController(task: task, taskRunUUID: nil)
		viewController.delegate = self
		return viewController
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
			whenCompleted?(viewController: viewController, response: nil)
		case .Discarded:
			didFailWithError(viewController, error: nil)
		case .Saved:
			// TODO: support saving tasks
			didFailWithError(viewController, error: nil)
		}
	}
	
	func didFailWithError(viewController: ORKTaskViewController, error: ErrorType?) {
		whenCancelledOrFailed?(viewController: viewController, error: error)
	}
}

