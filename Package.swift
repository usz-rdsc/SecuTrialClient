//
//  Package.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 12/19/15.
//  Copyright 2015 Pascal Pfiffner
//

import PackageDescription

let package = Package(
	name: "SecuTrialClient",
	targets: [
		Target(name: "SOAP"),
		Target(name: "Beans", dependencies: [.Target(name: "SOAP")]),
		Target(name: "Client", dependencies: [.Target(name: "Beans")]),
	]
)
