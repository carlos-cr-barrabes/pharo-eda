code generation - command
createCommandEqualsMethod
	^ self compile: '=' sourceCode: (self generateEqualsMethodFor: self retrieveCommandAttributes) inClass: (self retrieveCommandClassName asSymbol asClass) classifiedAs: #equals