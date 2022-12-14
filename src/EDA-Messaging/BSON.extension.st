Extension { #name : #BSON }

{ #category : #'*EDA-Messaging' }
BSON >> nextOIDPut: anOID [
	"write ObjectId to stream. ObjectId is encoded big-endian"

	| value |
	value := anOID value.
	12 to: 1 by: -1 do: [ :digitIndex | stream nextBytePut: (value byteAt: digitIndex) ]
]
