Class {
	#name : #NgramModelWithAddKSmoothingTest,
	#superclass : #TestCase,
	#instVars : [
		'smoothing',
		'k'
	],
	#category : #'NgramModel-Tests'
}

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> setUp [ 
	k := 2.
	smoothing := NgramAddKSmoothing withK: k.
]

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> testCanBeInitialized [
	| model |
	model := NgramModel order: 2 withSmoothing: smoothing.
	self assert: smoothing model equals: model
]

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> testTrainedBigramModelIsProbabilityDistribution [
	| text vocab model ngram sumOfProbabilities |
	text := 'Lorem ipsum dolor sit amet'.
	vocab := #('<s>' Lorem ipsum dolor sit amet).
	
	model := NgramModel order: 2 withSmoothing: smoothing.
	model trainOnSentence: text.
	
	vocab do: [ :firstWord |
		sumOfProbabilities := vocab inject: 0 into: [ :sum :secondWord |
			ngram := { firstWord . secondWord } asNgram.
			sum + (model probabilityOfNgram: ngram) ].
		
		self assert: sumOfProbabilities closeTo: 1 ].
]

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> testTrainedModelCounts [
	| model text ngram1 ngram2 ngram3 ngram4 ngram5 |
	model := NgramModel order: 2 withSmoothing: smoothing.
	
	text := 'lorem ipsum ipsum ipsum dolor'.
	ngram1 := #('<s>' lorem) asNgram.
	ngram2 := #(lorem ipsum) asNgram.
	ngram3 := #(ipsum ipsum) asNgram.
	ngram4 := #(ipsum dolor) asNgram.
	ngram5 := #(dolor '<s>') asNgram.
	
	model trainOnSentence: text.
	
	self assert: (model countOfNgram: ngram1) equals: 1.
	self assert: (model countOfNgram: ngram2) equals: 1.
	self assert: (model countOfNgram: ngram3) equals: 2.
	self assert: (model countOfNgram: ngram4) equals: 1.
	self assert: (model countOfNgram: ngram5) equals: 1.
]

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> testTrainedModelProbabilitiesOfNgrams [
	| model text vocab ngram1 ngram2 ngram3 ngram4 ngram5 |
	model := NgramModel order: 2 withSmoothing: smoothing.
	
	text := 'lorem ipsum ipsum ipsum dolor'.
	vocab := #('<s>' lorem ipsum dolor).
	
	ngram1 := #('<s>' lorem) asNgram.
	ngram2 := #(lorem ipsum) asNgram.
	ngram3 := #(ipsum ipsum) asNgram.
	ngram4 := #(ipsum dolor) asNgram.
	ngram5 := #(dolor '<s>') asNgram.
	
	model trainOnSentence: text.
	
	self assert: (model probabilityOfNgram: ngram1) equals: (1 + k) / (1 + (k * vocab size)) asFloat.
	self assert: (model probabilityOfNgram: ngram2) equals: (1 + k) / (1 + (k * vocab size)) asFloat.
	self assert: (model probabilityOfNgram: ngram3) equals: (2 + k) / (3 + (k * vocab size)) asFloat.
	self assert: (model probabilityOfNgram: ngram4) equals: (1 + k) / (3 + (k * vocab size)) asFloat.
	self assert: (model probabilityOfNgram: ngram5) equals: (1 + k) / (1 + (k * vocab size)) asFloat.
]

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> testTrainedModelSelfProbabilityOfText [
	| model text x1 x2 x3 |
	model := NgramModel order: 2 withSmoothing: smoothing.
	
	text := 'lorem ipsum ipsum ipsum dolor'.
	
	x1 := (1 + k) / (1 + (k * 4)) asFloat.
	x2 := (2 + k) / (3 + (k * 4)) asFloat.
	x3 := (1 + k) / (3 + (k * 4)) asFloat.
	
	model trainOnSentence: text.
	self
		assert: (model probabilityOfText: text)
		closeTo: x1 ** 3 * (x2 ** 2) * x3 asFloat.
]

{ #category : #tests }
NgramModelWithAddKSmoothingTest >> testTrainedUnigramModelIsProbabilityDistribution [
	| text vocab model ngram sumOfProbabilities |
	text := 'Lorem ipsum dolor sit amet'.
	vocab := #('<s>' Lorem ipsum dolor sit amet).
	
	model := NgramModel order: 1 withSmoothing: smoothing.
	model trainOnSentence: text.
	
	sumOfProbabilities := vocab inject: 0 into: [ :sum :word |
		ngram := { word } asNgram.
		sum + (model probabilityOfNgram: ngram) ].
		
	self assert: sumOfProbabilities equals: 1.
]
