Class {
	#name : #EDAIntegrationTestGenerator,
	#superclass : #EDAGenerator,
	#category : 'EDA-Tools'
}

{ #category : #'code generation' }
EDAIntegrationTestGenerator >> createIntegrationTestClass [
	| cls |
	cls := (self appName , self aggregate capitalized , 'IntegrationTestCase') asSymbol.
	^ (self class environment at: (self appName , 'ApplicationIntegrationTestCase') asSymbol)
		subclass: (self appName , self aggregate capitalized , 'IntegrationTestCase') asSymbol
						uses: (Smalltalk at: (self appName , 'T' , self aggregate capitalized , 'TestHelper') asSymbol)

		instanceVariableNames: ''
		classVariableNames: ''
		package: self appName , '-Application-Tests-' , self aggregate capitalized
]

{ #category : #'code generation' }
EDAIntegrationTestGenerator >> createIntegrationTestMethod [
	^ self
		compile: self generateIntegrationTestMethodName
		sourceCode: self generateIntegrationTestMethod
		inClass: (self class environment at: (self appName , self aggregate capitalized , 'IntegrationTestCase') asSymbol)
		classifiedAs: self protocol
]

{ #category : #protected }
EDAIntegrationTestGenerator >> description [
	^ 'integration test for ' , self aggregate greaseString
]

{ #category : #protected }
EDAIntegrationTestGenerator >> doGenerate [
	self createIntegrationTestClass.
	self createIntegrationTestMethod
]

{ #category : #delegated }
EDAIntegrationTestGenerator >> generateDomainTestMethodName [
	| delegate |
	delegate := EDADomainTestGenerator
		fromExampleFile: self commandFile
		version: self version
		appName: self appName
		aggregate: self aggregate
		commandNameResolver: self commandNameResolver
		andEventNameResolver: self eventNameResolver.
	^ delegate generateDomainTestMethodName

]

{ #category : #'code generation' }
EDAIntegrationTestGenerator >> generateIntegrationTestMethod [
	| result cr routingKey createdTest evtName |
	cr := Character cr.
	evtName := self toCamelCase: self eventName.
	routingKey := self
		camelCaseToDotSeparated: (self toCamelCase: self eventName capitalized).
	result := WriteStream with: String new.
	result
		nextPutAll: self generateDomainTestMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll:
			'	| aggregateRootId previousEvents command commandMessage expectedEvent expectedMessage expectedRoutingKey '.
	createdTest := routingKey endsWithSubCollection: '.created'.
	createdTest
		ifFalse: [ result
				nextPutAll: 'previous';
				nextPutAll: (self toCamelCase: self aggregate capitalized);
				nextPutAll: 'Created ' ].
	result
		nextPut: $|;
		nextPut: cr.
	result
		nextPutAll: '	previousEvents := OrderedCollection new.';
		nextPut: cr.
	result
		nextPutAll: '	command := self build';
		nextPutAll: (self toCamelCase: self commandName capitalized);
		nextPutAll: 'SampleCommand.';
		nextPut: cr.
	result
		nextPutAll: '	commandMessage := self read';
		nextPutAll: (self toCamelCase: self commandName capitalized);
		nextPutAll: 'FromFile.';
		nextPut: cr.
	result
		nextPutAll: '	aggregateRootId := command aggregateRootId.';
		nextPut: cr.
	self isDeletedEvent
		ifTrue: [ result
				nextPutAll:
					'	expectedEvent := self buildDeletedEventWithId: aggregateRootId andCommand: command.' ]
		ifFalse: [ result
				nextPutAll: '	expectedEvent := self build';
				nextPutAll: evtName;
				nextPutAll: 'SampleEventWithId: aggregateRootId ';
				nextPutAll: 'andCommandId: command commandId.' ].
	result nextPut: cr.
	result
		nextPutAll: '	expectedMessage := self read';
		nextPutAll: (self toCamelCase: self eventName capitalized);
		nextPutAll: 'FromFile.';
		nextPut: cr.
	result
		nextPutAll: '	expectedRoutingKey := ''';
		nextPutAll: routingKey;
		nextPut: $';
		nextPut: $.;
		nextPut: cr.
	createdTest
		ifTrue: [ result
				nextPutAll: '	"TODO: Add XXXCreated events to previousEvents collection,"';
				nextPut: cr;
				nextPutAll: '	"one for each dependency, if any. Do not forget to change "';
				nextPut: cr;
				nextPutAll: '	"protocol so the generator skips overriding your changes!"';
				nextPut: cr;
				nextPutAll: '	self flag: #TODO.';
				nextPut: cr ]
		ifFalse: [ result
				nextPutAll: '	previous';
				nextPutAll: (self toCamelCase: self aggregate capitalized);
				nextPutAll: 'Created := self build';
				nextPutAll: (self toCamelCase: self aggregate capitalized);
				nextPutAll:
					'CreatedSampleEventWithId: aggregateRootId andCommandId: command commandId.';
				nextPut: cr.
			result
				nextPutAll: '	previous';
				nextPutAll: (self toCamelCase: self aggregate capitalized);
				nextPutAll: 'Created id: command aggregateRootId.';
				nextPut: cr.
			result
				nextPutAll: '	previousEvents add: previous';
				nextPutAll: (self toCamelCase: self aggregate capitalized);
				nextPutAll: 'Created.';
				nextPut: cr ].
	result
		nextPutAll: '	self';
		nextPut: cr.
	result
		nextPutAll: '		givenPreviousEvents: previousEvents ofTenant: command tenant';
		nextPut: cr.
	result
		nextPutAll: '		whenReceiveCommandMessage: commandMessage';
		nextPut: cr.
	result
		nextPutAll: '		thenStoreEvent: expectedEvent';
		nextPut: cr.
	result
		nextPutAll: '		andPublishEventMessage: expectedMessage';
		nextPut: cr.
	result
		nextPutAll: '		withRoutingKey: expectedRoutingKey';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDAIntegrationTestGenerator >> generateIntegrationTestMethodName [
	^ self generateDomainTestMethodName 
]
