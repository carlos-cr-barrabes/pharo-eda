Class {
	#name : #DefaultEnglishEventNameResolver,
	#superclass : #Object,
	#traits : 'EDATSourceCodeHelper',
	#classTraits : 'EDATSourceCodeHelper classTrait',
	#category : 'EDA-Tools'
}

{ #category : #resolving }
DefaultEnglishEventNameResolver >> resolve: aCommandName [
	| result aux |
	result := nil.
	aux := aCommandName allRegexMatches: '([^_]*)'.
	aux size > 2
		ifTrue: [ | verb rest past |
			verb := aux at: 1.
			rest := aux allButFirst.
			past := self verbInPastTense: verb.
			result := ''.
			rest
				keysAndValuesDo: [ :i :noun | 
					i > 1
						ifTrue: [ result := result , '_' ].
					result := result , noun ].
			result := result , past ].
	^ result
]
