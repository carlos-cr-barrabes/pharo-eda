"
* Class: EDAStompTopicPublisher

Communicates with Stomp exchanges to publish messages.

* Responsibility: 

Contains the configuration needed to publish messages to exchanges.
"
Class {
	#name : #EDAStompTopicPublisher,
	#superclass : #EDATopicPublisher,
	#traits : 'EDATLogging',
	#classTraits : 'EDATLogging classTrait',
	#instVars : [
		'client'
	],
	#classInstVars : [
		'username',
		'routingKey',
		'password',
		'exchange',
		'durable',
		'host',
		'port',
		'timeout',
		'errorExchange',
		'errorRoutingKey'
	],
	#category : #'EDA-StompMessaging'
}

{ #category : #accessing }
EDAStompTopicPublisher class >> destination [
	^ self destinationWithRoutingKey: self routingKey
]

{ #category : #accessing }
EDAStompTopicPublisher class >> destinationWithRoutingKey: key [
	^ '/exchange/', self exchange, '/', key
]

{ #category : #initialization }
EDAStompTopicPublisher class >> doInitialize [
	self host: nil.
	self port: nil.
	self exchange: nil.
	self username: nil.
	self password: nil.
	self timeout: nil.
	self routingKey: nil.
	self durable: true
]

{ #category : #accessing }
EDAStompTopicPublisher class >> durable [
	^ durable
]

{ #category : #accessing }
EDAStompTopicPublisher class >> durable: val [
	durable := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> errorDestination [
	^ '/exchange/' , self errorExchange , '/#'
]

{ #category : #accessing }
EDAStompTopicPublisher class >> errorExchange [
	^ errorExchange
]

{ #category : #accessing }
EDAStompTopicPublisher class >> errorExchange: aString [
	errorExchange := aString
]

{ #category : #accessing }
EDAStompTopicPublisher class >> errorRoutingKey [
	^ errorRoutingKey
]

{ #category : #accessing }
EDAStompTopicPublisher class >> errorRoutingKey: val [
	errorRoutingKey := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> exchange [
	^ exchange
]

{ #category : #accessing }
EDAStompTopicPublisher class >> exchange: val [
	exchange := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> host [
	^ host
]

{ #category : #accessing }
EDAStompTopicPublisher class >> host: val [
	host := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> password [
	^ password
]

{ #category : #accessing }
EDAStompTopicPublisher class >> password: val [
	password := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> port [
	^ port
]

{ #category : #accessing }
EDAStompTopicPublisher class >> port: val [
	port := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> routingKey [
	^ routingKey
]

{ #category : #accessing }
EDAStompTopicPublisher class >> routingKey: val [
	routingKey := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> timeout [
	^ timeout
]

{ #category : #accessing }
EDAStompTopicPublisher class >> timeout: val [
	timeout := val
]

{ #category : #accessing }
EDAStompTopicPublisher class >> username [
	^ username
]

{ #category : #accessing }
EDAStompTopicPublisher class >> username: val [
	username := val
]

{ #category : #initialization }
EDAStompTopicPublisher >> buildClientWith: config [
	| result |
	result := StampClient new.
	result login: config username.
	result passcode: config password.
	result host: config host.
	result port: config port.
	result timeout: config timeout.
	^ result
	
]

{ #category : #private }
EDAStompTopicPublisher >> buildIdUsingClient: aClient withConfig: config [
	^ aClient nextId , '-', config exchange, config routingKey
]

{ #category : #accessing }
EDAStompTopicPublisher >> client [
	^ client
]

{ #category : #accessing }
EDAStompTopicPublisher >> client: val [
	client := val
]

{ #category : #initialization }
EDAStompTopicPublisher >> initialize [
	super initialize.
	self client: (self buildClientWith: self class)

]

{ #category : #logging }
EDAStompTopicPublisher >> logMessagePublished: message usingClient: aClient on: aDestination [
	self
		logInfoMessage:
			'Published message ' , message greaseString , ' in '
				, aDestination greaseString , '.'
]

{ #category : #logging }
EDAStompTopicPublisher >> logPublishingMessage: message usingClient: aClient on: aDestination [
	self
		logInfoMessage: 'Publishing message in ' , aDestination greaseString , '.'
]

{ #category : #private }
EDAStompTopicPublisher >> nextId [
	^ self buildIdUsingClient: self client withConfig: self class
]

{ #category : #API }
EDAStompTopicPublisher >> publishError: aMessage [
	^ self
		publishError: true
		message: aMessage
		usingClient: self client
		withConfig: self class
]

{ #category : #API }
EDAStompTopicPublisher >> publishError: isError message: aMessage usingClient: aClient withConfig: config [
	| sendFrame destination |
	destination := isError
		ifTrue: [ config errorDestination ]
		ifFalse: [ config destination ].
	self
		logPublishingMessage: aMessage
		usingClient: aClient
		on: destination.
	aClient isConnected
		ifFalse: [ aClient open ].
	[
	sendFrame := StampSendFrame new.
	sendFrame destination: destination.
	sendFrame text: aMessage.
	sendFrame persistent: config durable.
	aClient writeWithReceipt: sendFrame.
	self
		logMessagePublished: aMessage
		usingClient: aClient
		on: destination ]
		ensure: [ aClient close ]
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessage: aMessage [
	^ self
		publishError: false message: aMessage
		usingClient: self client
		withConfig: self class
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessage: aMessage inTransaction: transactionId [
	^ self publishMessage: aMessage inTransaction: transactionId usingClient: self client withConfig: self class
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessage: aMessage inTransaction: transactionId usingClient: aClient withConfig: config [
	| sendFrame destination |
	self
		logPublishingMessage: aMessage
		usingClient: aClient
		on: config destination.
	destination := config destination.
	(sendFrame := StampSendFrame new)
		text: aMessage;
		destination: config destination;
		persistent: config durable;
		timeout: config timeout;
		transaction: transactionId.
	aClient writeWithReceipt: sendFrame.
	self
		logMessagePublished: aMessage
		usingClient: aClient
		on: destination
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessage: aMessage withRoutingKey: aRoutingKeyString [
	^ self publishMessage: aMessage withRoutingKey: aRoutingKeyString usingClient: self client withConfig: self class
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessage: aMessage withRoutingKey: aRoutingKeyString usingClient: aClient withConfig: config [
	| sendFrame destination |
	destination := config destinationWithRoutingKey: aRoutingKeyString.
	self
		logPublishingMessage: aMessage
		usingClient: aClient
		on: destination.
	aClient isConnected
		ifFalse: [ aClient open ].
	[ sendFrame := StampSendFrame new.
	sendFrame destination: destination.
	sendFrame text: aMessage.
	sendFrame persistent: config durable.
	aClient writeWithReceipt: sendFrame.
	self
		logMessagePublished: aMessage
		usingClient: aClient
		on: destination ]
		ensure: [ aClient close ]
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessages: messageCollection inTransaction: transactionId usingClient: aClient withConfig: config [
	| beginFrame commitFrame |
	aClient isConnected
		ifFalse: [ aClient open ].
	[ 
	beginFrame := StampBeginFrame transaction: transactionId.
	aClient writeWithReceipt: beginFrame.
	messageCollection
		do: [ :message | 
			self
				publishMessage: message
				inTransaction: transactionId
				usingClient: aClient
				withConfig: config ].
	commitFrame := StampCommitFrame transaction: transactionId.
	aClient writeWithReceipt: commitFrame ]
		ensure: [ aClient close ]
]

{ #category : #API }
EDAStompTopicPublisher >> publishMessagesAtomically: messageCollection [
	^ self publishMessages: messageCollection inTransaction: self nextId usingClient: self client withConfig
]