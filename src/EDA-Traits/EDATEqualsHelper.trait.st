Trait {
	#name : #EDATEqualsHelper,
	#category : #'EDA-Traits'
}

{ #category : #comparing }
EDATEqualsHelper >> = anInstance [
	^ self class = anInstance class
		and: [ self class allInstVarNames
				allSatisfy: [ :varName |
					(self instVarNamed: varName) = (anInstance instVarNamed: varName) ] ]
]
