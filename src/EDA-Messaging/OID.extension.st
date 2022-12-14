Extension { #name : #OID }

{ #category : #'*EDA-Messaging' }
OID >> initialize [
	"initialize value corresponding to the mongo spec. It is a 12-byte value containing:
	* 4-byte timestamp
	* 3-byte machine identifier
	* 2-byte process identifier
	* 3-byte counter"

	| processIdentifier counter |
	processIdentifier := Processor activeProcess basicIdentityHash.
	value := LargePositiveInteger new: 12.
	"Equivalent to DateAnTime now asUnixTime, but without all the instantiation.
	(2177452800 is the offset in seconds between Squeak epoch and Unix epoch)
	Overall speedup of [OID new ] bench by 4X or so, so let's say it's worth it."
	counter := self class counterNext.
	value
		replaceFrom: 9
			to: 12
			with: Time totalSeconds - 2177452800
			startingAt: 1;
		replaceFrom: 6
			to: 8
			with: self class machineIdentifier
			startingAt: 1;
		byteAt: 5 put: (processIdentifier bitAnd: 16rFF);
		byteAt: 4 put: ((processIdentifier bitShift: -8) bitAnd: 16rFF);
		byteAt: 3 put: (counter bitShift: -16);
		byteAt: 2 put: ((counter bitShift: -8) bitAnd: 16rFF);
		byteAt: 1 put: (counter bitAnd: 16rFF)
]
