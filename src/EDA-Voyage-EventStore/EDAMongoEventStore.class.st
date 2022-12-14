Class {
	#name : #EDAMongoEventStore,
	#superclass : #EDAEventStore,
	#traits : 'EDAPrintOnHelper + EDATMongoHelper + EDATLogging',
	#classTraits : 'EDAPrintOnHelper classTrait + EDATMongoHelper classTrait + EDATLogging classTrait',
	#classInstVars : [
		'username',
		'password',
		'databaseName',
		'host',
		'port',
		'debug',
		'enableReplication',
		'enableSingleton',
		'ensuringCurrentOnSave',
		'ensuringCurrentReferencesOnQueries',
		'forceEager',
		'lazySynchronize',
		'wireProtocolEnabled',
		'authenticationMechanism',
		'urls',
		'tls'
	],
	#category : #'EDA-Voyage-EventStore'
}

{ #category : #accessing }
EDAMongoEventStore class >> authenticationMechanism [
	^ authenticationMechanism
]

{ #category : #accessing }
EDAMongoEventStore class >> authenticationMechanism: anObject [
	authenticationMechanism := anObject
]

{ #category : #accessing }
EDAMongoEventStore class >> databaseName [
	^ databaseName
]

{ #category : #accessing }
EDAMongoEventStore class >> databaseName: anObject [
	databaseName := anObject
]

{ #category : #accessing }
EDAMongoEventStore class >> debug [
	^ debug
]

{ #category : #accessing }
EDAMongoEventStore class >> debug: aBoolean [
	debug = aBoolean
		ifTrue: [ ^ self ].
	debug := aBoolean.
	self refreshVoyageSettings
]

{ #category : #'class initialization' }
EDAMongoEventStore class >> doInitialize [
	self urls: nil.
	self tls: nil.
	self databaseName: nil.
	self username: nil.
	self password: nil.
	self debug: nil.
	self enableReplication: nil.
	self enableSingleton: nil.
	self ensuringCurrentOnSave: nil.
	self ensuringCurrentReferencesOnQueries: nil.
	self forceEager: nil.
	self lazySynchronize: nil.
	self wireProtocolEnabled: nil
]

{ #category : #accessing }
EDAMongoEventStore class >> enableReplication [
	^ enableReplication
]

{ #category : #accessing }
EDAMongoEventStore class >> enableReplication: aBoolean [
	enableReplication = aBoolean
		ifTrue: [ ^ self ].
	enableReplication := aBoolean.
	self refreshVoyageSettings
]

{ #category : #accessing }
EDAMongoEventStore class >> enableSingleton [
	^ enableSingleton
]

{ #category : #accessing }
EDAMongoEventStore class >> enableSingleton: aBoolean [
	enableSingleton = aBoolean
		ifTrue: [ ^ self ].
	enableSingleton := aBoolean.
	self refreshVoyageSettings
]

{ #category : #accessing }
EDAMongoEventStore class >> ensuringCurrentOnSave [
	^ ensuringCurrentOnSave
]

{ #category : #accessing }
EDAMongoEventStore class >> ensuringCurrentOnSave: aBoolean [
	ensuringCurrentOnSave = aBoolean
		ifTrue: [ ^ self ].
	ensuringCurrentOnSave := aBoolean.
	self refreshVoyageSettings
]

{ #category : #accessing }
EDAMongoEventStore class >> ensuringCurrentReferencesOnQueries [
	^ ensuringCurrentReferencesOnQueries
]

{ #category : #accessing }
EDAMongoEventStore class >> ensuringCurrentReferencesOnQueries: aBoolean [
	ensuringCurrentReferencesOnQueries = aBoolean
		ifTrue: [ ^ self ].
	ensuringCurrentReferencesOnQueries := aBoolean.
	self refreshVoyageSettings
]

{ #category : #accessing }
EDAMongoEventStore class >> forceEager [
	^ forceEager
]

{ #category : #accessing }
EDAMongoEventStore class >> forceEager: aBoolean [
	forceEager = aBoolean
		ifTrue: [ ^ self ].
	forceEager := aBoolean.
	self refreshVoyageSettings
]

{ #category : #'class initialization' }
EDAMongoEventStore class >> initialize [
	self doInitialize
]

{ #category : #accessing }
EDAMongoEventStore class >> lazySynchronize [
	^ lazySynchronize
]

{ #category : #accessing }
EDAMongoEventStore class >> lazySynchronize: aBoolean [
	lazySynchronize = aBoolean
		ifTrue: [ ^ self ].
	lazySynchronize := aBoolean.
	self refreshVoyageSettings
]

{ #category : #accessing }
EDAMongoEventStore class >> password [
	^ password
]

{ #category : #accessing }
EDAMongoEventStore class >> password: anObject [
	password := anObject
]

{ #category : #'refresh settings' }
EDAMongoEventStore class >> refreshVoyageSettings [
	EDAVOMongoRepository allInstancesDo: [ :repo | self refreshVoyageSettingsOn: repo ]
]

{ #category : #accessing }
EDAMongoEventStore class >> tls [
	^ tls
]

{ #category : #accessing }
EDAMongoEventStore class >> tls: aBoolean [
	tls := aBoolean
]

{ #category : #accessing }
EDAMongoEventStore class >> urls [
	^ urls
]

{ #category : #accessing }
EDAMongoEventStore class >> urls: aString [
	urls := aString
]

{ #category : #accessing }
EDAMongoEventStore class >> username [
	^ username
]

{ #category : #accessing }
EDAMongoEventStore class >> username: anObject [
	username := anObject
]

{ #category : #accessing }
EDAMongoEventStore class >> wireProtocolEnabled [
	^ wireProtocolEnabled
]

{ #category : #accessing }
EDAMongoEventStore class >> wireProtocolEnabled: aBoolean [
	wireProtocolEnabled = aBoolean
		ifTrue: [ ^ self ].
	wireProtocolEnabled := aBoolean.
	self refreshVoyageSettings
]

{ #category : #persistence }
EDAMongoEventStore >> allEvents [
	| eventsCriteria |
	eventsCriteria := Dictionary empty.
	^ EDAEventSourcingEvent
		selectMany: eventsCriteria
		sortBy:
			(OrderedCollection
				with: #timestamp -> VOOrder ascending
				with: #_id -> VOOrder ascending) asDictionary
]

{ #category : #persistence }
EDAMongoEventStore >> allEventsOfAggregate: anAggregateRootClass groupedBy: aField [
	| eventsCriteria |
	eventsCriteria := Dictionary empty.
	^ (self
		findEventsOfAggregate: anAggregateRootClass
		whereCriteria: eventsCriteria)
		groupedBy: [ :event | event instVarNamed: aField ]
]

{ #category : #persistence }
EDAMongoEventStore >> allEventsOfTenant: aTenant [
	| eventsCriteria |
	eventsCriteria := (OrderedCollection
		with: 'tenant' -> aTenant)
		asDictionary.
	^ EDAEventSourcingEvent
		selectMany: eventsCriteria
		sortBy: (OrderedCollection with: #timestamp -> VOOrder ascending with: #_id -> VOOrder ascending) asDictionary
]

{ #category : #persistence }
EDAMongoEventStore >> findEventsOfAggregate: anAggregateRootClass whereCriteria: aCriteriaDictionary [
	| eventsCriteria |
	eventsCriteria := Dictionary newFrom: aCriteriaDictionary.
	eventsCriteria at: 'aggregateRootClass' put: anAggregateRootClass greaseString.
	^ EDAEventSourcingEvent
		selectMany: eventsCriteria
		sortBy: (OrderedCollection with: #timestamp -> VOOrder ascending) asDictionary
]

{ #category : #persistence }
EDAMongoEventStore >> findEventsOfAggregate: anAggregateRootClass whereId: aNumber [
	^ self
		findEventsOfAggregate: anAggregateRootClass
		whereCriteria: (Dictionary with: 'id' -> aNumber)
]

{ #category : #persistence }
EDAMongoEventStore >> findEventsOfTenant: aTenant ofAggregate: anAggregateRootClass whereCriteria: aCriteriaDictionary [
	| eventsCriteria |
	eventsCriteria := Dictionary newFrom: aCriteriaDictionary.
	eventsCriteria at: 'tenant' put: aTenant.
	eventsCriteria at: 'aggregateRootClass' put: anAggregateRootClass greaseString.
	^ EDAEventSourcingEvent
		selectMany: eventsCriteria
		sortBy: (OrderedCollection with: #timestamp -> VOOrder ascending) asDictionary
]

{ #category : #persistence }
EDAMongoEventStore >> findEventsOfTenant: aTenant ofAggregate: anAggregateRootClass whereId: aNumber [
	^ self
		findEventsOfTenant: aTenant ofAggregate: anAggregateRootClass
		whereCriteria: (OrderedCollection with: 'id' -> aNumber) asDictionary
]

{ #category : #persistence }
EDAMongoEventStore >> initBackendRepository [
	| mongoRepository |
	mongoRepository := self mongoRepositoryClass
		mongoUrls: (self csvToCollection: self class urls)
		database: self class databaseName
		username: self class username
		password: self class password.
	"result cache: EDAMongoNoCache new."
	mongoRepository debug: self class debug.
	self class configReplicationOnRepository: mongoRepository.
	self class configSingletonOnRepository: mongoRepository.
	mongoRepository ensuringCurrentOnSave: self class ensuringCurrentOnSave.
	mongoRepository
		ensuringCurrentReferencesOnQueries: self class ensuringCurrentReferencesOnQueries.
	mongoRepository lazySynchronize: self class lazySynchronize.
"	result wireProtocolEnabled: self class wireProtocolEnabled."
	^ mongoRepository
]

{ #category : #persistence }
EDAMongoEventStore >> mongoRepositoryClass [
	^ EDAVOMongoRepository
]

{ #category : #persistence }
EDAMongoEventStore >> saveEvents: anEventCollection [
	anEventCollection do: [ :event | event save ]
]
