SecuTrialClient
===============

Client, written in Swift 2.0, to use _secuTrial_ with _ResearchKit_.

## Hierarchy

A client holds on to all _forms_ that can be exchanged with the respective endpoint as `SecuTrialEntityForm`.
A form usually has one _import format_ but can have multiple, represented as `SecuTrialEntityImportFormat`.
The chosen import format determines the import identifier, crucial when returning data to the server.

A form holds on to one or more _groups_, represented as `SecuTrialEntityFormGroup`, which contains 0 or more _fields_ as `SecuTrialEntityFormField`.


