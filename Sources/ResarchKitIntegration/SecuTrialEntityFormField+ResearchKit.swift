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
		return UUID().uuidString
	}
	
	/**
	Instantiates an ORKStep for fields that have `importMapping` set, nil otherwise.
	*/
	public func strk_asStep() -> ORKStep? {
		if importMapping.isEmpty {
			return nil
		}
		guard let answerFormat = strk_answerFormat() else {
			strk_warn("No answer format is compatible with field \"\(fflabel ?? "<nil>")\", omitting")
			return nil
		}
		
		let step = ORKQuestionStep(identifier: strk_identifier())
		step.answerFormat = answerFormat
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
		case .numeric:
			return ORKAnswerFormat.decimalAnswerFormat(withUnit: nil)
		
		case .checkbox:
			return ORKAnswerFormat.booleanAnswerFormat()
		
		case .radio:
			guard let values = values else {
				strk_warn("Radio form field \"\(fflabel ?? "<nil>")\" has no values, omitting")
				return nil
			}
			let choices = values.map() { ORKTextChoice(text: $0.fvlabel ?? "Unknown", value: $0.fvvalue as NSCoding & NSCopying & NSObjectProtocol? ?? "" as NSCoding & NSCopying & NSObjectProtocol) }
			return ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: choices)
		
		case .date:
			if let format = importMapping.first?.dateFormat {
				switch format {
				case "dd.MM.yyyy HH:mm":
					return ORKAnswerFormat.dateTime()
				case "dd.MM.yyyy":
					return ORKAnswerFormat.dateAnswerFormat()
				case "HH:mm":
					return ORKAnswerFormat.timeOfDayAnswerFormat()
				default:
					strk_warn("Date format \"\(format)\" is not handled, defaulting to date-only")
					return ORKAnswerFormat.dateAnswerFormat()
				}
			}
			return ORKAnswerFormat.dateAnswerFormat()
		
		case .text:
			return ORKAnswerFormat.textAnswerFormat()
		default:
			strk_warn("Unknown field type, defaulting to text entry")
			return ORKAnswerFormat.textAnswerFormat()
		}
	}
}

