SecuTrialClient
===============

Client, written in Swift 3.0, to use _secuTrial_ together with [_ResearchKit_](http://researchkit.org).

## Usage

This client framework must be linked with the ResearchKit framework.
See the [SecuTrialApp](https://github.com/usz-rdsc/SecuTrialApp), which includes both this client as well as ResearchKit as a submodule side-by-side.

## Hierarchy

A client holds on to all _forms_ that can be exchanged with the respective endpoint as `SecuTrialEntityForm`.
A form usually has one _import format_ but can have multiple, represented as `SecuTrialEntityImportFormat`.
The chosen import format determines the import identifier, crucial when returning data to the server.

A form holds on to one or more _groups_, represented as `SecuTrialEntityFormGroup`, which contains 0 or more _fields_ as `SecuTrialEntityFormField`.


