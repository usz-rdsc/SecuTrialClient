//
//  SecuTrialEntityFormField+ResearchKit.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 23/12/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import ResearchKit


extension SecuTrialEntityFormField {
	
	/**
	The full identifier to identify values for this form field. Composed of importMapping.importFormat.identifier plus
	importMapping.externalKey, separated by a period.
	*/
	public func strk_identifier() -> String {
		if let mapping = importMapping.first, let key = mapping.externalKey {
			if let formatid = mapping.importFormat?.identifier {
				return "\(formatid).\(key)"
			}
			return key
		}
		return NSUUID().UUIDString
	}
	
	/**
	Instantiates an ORKStep for fields that have `importMapping` set, nil otherwise.
	*/
	public func strk_asStep() -> ORKStep? {
		if importMapping.isEmpty {
			return nil
		}
		
		let step = ORKQuestionStep(identifier: strk_identifier())
		step.answerFormat = strk_answerFormat()
		step.title = strk_bestTitle()
		step.text = fftext
		return step
	}
	
	public func strk_bestTitle() -> String? {
		return fflabel
	}
	
	/**
	The answer format to use by this form field.
	
	- returns: The ORKAnswerFormat best suitable for the field
	*/
	public func strk_answerFormat() -> ORKAnswerFormat? {
		switch fieldType {
		case .Numeric:
			return ORKAnswerFormat.decimalAnswerFormatWithUnit(nil)
		case .Checkbox:
			return ORKAnswerFormat.booleanAnswerFormat()
		// TODO: create choices
//		case .Radio:
//			let choices = [ORKTextChoice]()
//			return ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: choices)
		case .Date:
			if let format = importMapping.first?.dateFormat {
				switch format {
				case "dd.MM.yyyy HH:mm":
					return ORKAnswerFormat.dateTimeAnswerFormat()
				case "dd.MM.yyyy":
					return ORKAnswerFormat.dateAnswerFormat()
				case "HH:mm":
					return ORKAnswerFormat.timeOfDayAnswerFormat()
				default:
					return ORKAnswerFormat.dateAnswerFormat()
				}
			}
			return ORKAnswerFormat.dateAnswerFormat()
		case .Text:
			return ORKAnswerFormat.textAnswerFormat()
		default:
			return ORKAnswerFormat.textAnswerFormat()
		}
	}
}

