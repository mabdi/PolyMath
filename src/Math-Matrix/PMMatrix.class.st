"
I represent a mathematical matrix. I can be build from rows as follows: 

[[[ 
PMMatrix rows: #((1 2 3)(4 5 6)).
]]]

I understand the usual matrix operations.

"
Class {
	#name : #PMMatrix,
	#superclass : #Object,
	#instVars : [
		'rows',
		'lupDecomposition'
	],
	#category : 'Math-Matrix'
}

{ #category : #example }
PMMatrix class >> example [
""
|a b c d|
"This is how we can create a matrix, a and b are 2x3 matrices in
this example"
a := PMMatrix rows: #( ( 1 0 1 ) (-1 -2 3)).
b := PMMatrix rows: #( ( 1 2 3 ) (-2 1 7)).

"Matrix product"
c := a * b.

"Elementwise matrix product"
d := a dot:b.

"This is how we can create a vector"
a := #(1 4 9 16 25) asPMVector.

"Vectors and Matrices support basic logical and arithmetic
operations"
Float pi sin * d.
a sqrt.
a > 3.
c cos.
c < 0.

"It is possible to create a vector/matrix of random numbers"
a := PMVector randomSize: 10 maxNumber: 3.
b := PMMatrix rows: 2 columns: 3 random: 5.

"It is also easy to create a vector/matrix of zeros/ones"
a := PMVector ones:15.
b := PMMatrix zerosRows: 2 cols: 3.

"We can also compute the cumulative sum or regular sum the vector/
matrix as following"
a := PMMatrix rows: #( ( 1 0 1 ) (-1 -2 3)).
a cumsum.
"a PMVector(1 1 2)"
"a PMVector(-1 -3 0)"
a sum.
"a PMVector(2 0)"

"Matrix trace (sum of a diagonal elements for a square matrix)"
a := PMMatrix rows: #((1 2 3)(4 5 6)(7 8 9)).
a tr.
"15"
]

{ #category : #'instance creation' }
PMMatrix class >> join: anArrayOfMatrices [
		"Inverse of the split operation."
	| rows n row rowSize n1 n2 |
	rows := OrderedCollection new.
	n1 := ( anArrayOfMatrices at: 1) numberOfColumns.
	n2 := n1 + 1.
	rowSize := n1 + ( anArrayOfMatrices at: 2) numberOfColumns.
	n := 0.
	( anArrayOfMatrices at: 1) rowsDo:
		[ :each |
		  n := n + 1.
		  row := PMVector new: rowSize.
		  row replaceFrom: 1 to: n1 with: each startingAt: 1;
			  replaceFrom: n2 to: rowSize with: ( ( anArrayOfMatrices at: 2) rowAt: n) startingAt: 1.
		  rows add: row.
		].
	n := 0.
	( anArrayOfMatrices at: 3) rowsDo:
		[ :each |
		  n := n + 1.
		  row := PMVector new: rowSize.
		  row replaceFrom: 1 to: n1 with: each startingAt: 1;
			  replaceFrom: n2 to: rowSize with: ( ( anArrayOfMatrices at: 4) rowAt: n) startingAt: 1.
		  rows add: row.
		].
	^self rows: rows
]

{ #category : #information }
PMMatrix class >> lupCRLCriticalDimension [
	^ 40
]

{ #category : #'instance creation' }
PMMatrix class >> new: anInteger [
	"Create an empty square matrix of dimension anInteger."

	^ self new initialize: anInteger
]

{ #category : #'instance creation' }
PMMatrix class >> onesRows: rows cols: columns [
	"Creates MxN matrix of ones"

	| a b |
	a := (1 to: rows) collect: [ :row | b := PMVector ones: columns ].
	^ self rows: a
]

{ #category : #'instance creation' }
PMMatrix class >> rows: anArrayOrVector [
	"Create a new matrix with given components."

	^ self new initializeRows: anArrayOrVector
]

{ #category : #'as yet unclassified' }
PMMatrix class >> rows: rows columns: columns random: aMaxNumber [
	"Answer a new Matrix of the given dimensions filled with random numbers"
	|a b|
	a:=	(1 to: rows) collect: [:row |b:=PMVector new:columns .
		1 to: columns do: [:column |
			b  at: column put: (aMaxNumber random)].
		b].
	^PMMatrix rows: a
]

{ #category : #'instance creation' }
PMMatrix class >> zerosRows: rows cols: columns [
	"Creates MxN matrix of zeros"

	| a b |
	a := (1 to: rows) collect: [ :row | b := PMVector zeros: columns ].
	^ self rows: a
]

{ #category : #operation }
PMMatrix >> * aNumberOrMatrixOrVector [
	"Answers the product of the receiver with the argument. The argument can be a number, matrix or vector."
	^ aNumberOrMatrixOrVector productWithMatrix: self
]

{ #category : #operation }
PMMatrix >> + aMatrixOrNumber [
	"Answers the sum of the receiver with aMatrix."
	^ aMatrixOrNumber addWithRegularMatrix: self
]

{ #category : #operation }
PMMatrix >> - aMatrix [
	"Answers the difference between the receiver and aMatrix."
	^ aMatrix subtractWithRegularMatrix: self
]

{ #category : #operation }
PMMatrix >> < aNumber [
	"Apply < operator to each element of the matrix"

	^ PMMatrix rows: (self rowsCollect: [ :each | each < aNumber ])
]

{ #category : #comparing }
PMMatrix >> = aNumberOrMatrix [ 
	^ (aNumberOrMatrix species = self species) and: [ self rows = aNumberOrMatrix rows ]
]

{ #category : #operation }
PMMatrix >> > aNumber [
	"Apply > operator to each element of the matrix"

	^ PMMatrix rows: (self rowsCollect: [ :each | each > aNumber ])
]

{ #category : #arithmetic }
PMMatrix >> abs [
	"Computes the element-wise absolute value."
	^ self class rows: (rows collect: #abs).
]

{ #category : #'double dispatching' }
PMMatrix >> adaptToNumber: rcvr andSend: selector [
	"selector must obviously be commutative for this simple solution, but at the moment its only used for multiplication"
	^ self perform:  selector with: rcvr.
]

{ #category : #'double dispatching' }
PMMatrix >> addWithRegularMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix as a PMMatrix."
	| n |
	n := 0.
	
	(self numberOfRows = aMatrix numberOfRows) &
	(self numberOfColumns = aMatrix numberOfColumns)
		ifFalse: [ SizeMismatch signal ].
	
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each + ( aMatrix rowAt: n)])
]

{ #category : #'double dispatching' }
PMMatrix >> addWithSymmetricMatrix: aMatrix [
	^ aMatrix addWithRegularMatrix: self 
]

{ #category : #transformation }
PMMatrix >> asSymmetricMatrix [
	"Convert the receiver to a symmetric matrix (no check is made)."
	^ PMSymmetricMatrix rows: rows
]

{ #category : #'cell accessing' }
PMMatrix >> at: aRowIndex at: aColumnIndex [
	"Answers the aRowIndex-th, aColumnIndex-th entry in the receiver."
	^ self rowAt: aRowIndex columnAt: aColumnIndex
]

{ #category : #'cell accessing' }
PMMatrix >> at: rowIndex at: columnIndex put: value [

	self rowAt: rowIndex columnAt: columnIndex put: value
	

]

{ #category : #'cell accessing' }
PMMatrix >> atColumn: anInteger [

	^ self columnAt: anInteger
]

{ #category : #'cell accessing' }
PMMatrix >> atColumn: aColumnIndex put: aCollection [

	aCollection withIndexDo: [: value : rowIndex |
		self rowAt: rowIndex columnAt: aColumnIndex put: value ]
	

]

{ #category : #'cell accessing' }
PMMatrix >> atColumn: aColumnNumber put: aCollection startingAt: rowNumber [
	" Fill the receiver with aCollection at aColumnNumber begining at rowNumber. "
	
	aCollection withIndexDo: [: value : rowIndex |
		(rowIndex + rowNumber ) <= self numberOfRows 
		ifTrue: 
		[ self rowAt: rowIndex + rowNumber
			columnAt: aColumnNumber 
			put: value ]]
	

]

{ #category : #'cell accessing' }
PMMatrix >> atRow: rowIndex put: aCollection [

	aCollection withIndexDo: [: value : columnIndex |
		self rowAt: rowIndex columnAt: columnIndex put: value ]
	

]

{ #category : #'cell accessing' }
PMMatrix >> atRow: rowIndex put: aCollection startingAt: startColumnNumber [ 
	"Fill the receiver with aCollection at rowIndex beggining at startColumnNumber. "
		
	aCollection withIndexDo: [: value : columnIndex |
		(columnIndex + startColumnNumber ) <= self numberOfColumns 
		ifTrue:
		[ self 
			rowAt: rowIndex 
			columnAt: columnIndex + startColumnNumber
			put: value ]]
	

]

{ #category : #comparing }
PMMatrix >> closeTo: aPMMatrix [
	"Tests that we are within the default Float >> #closeTo: precision of aPMMatrix (0.0001)."
	^ self closeTo: aPMMatrix precision: 0.0001
]

{ #category : #comparing }
PMMatrix >> closeTo: aPMMatrix precision: aPrecision [
	^ (self - aPMMatrix) abs sum sum < aPrecision
]

{ #category : #iterators }
PMMatrix >> collect: aBlock [
	"Applies aBlock elementwise to each cell of the matrix."
	^ self class rows: (rows collect: [ :r | r collect: aBlock ])
]

{ #category : #'cell accessing' }
PMMatrix >> columnAt: anInteger [
	"Answers the anInteger-th column of the receiver."
	^ rows collect: [ :each | each at: anInteger ]
]

{ #category : #iterators }
PMMatrix >> columnsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	| n |
	n := 0.
	^ rows last collect: [ :each | n := n + 1. aBlock value: (self columnAt: n)]
]

{ #category : #iterators }
PMMatrix >> columnsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	| n |
	n := 0.
	^ rows last do: [ :each | n := n + 1. aBlock value: ( self columnAt: n)]
]

{ #category : #operation }
PMMatrix >> cos [
	"Apply cos to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each cos])
]

{ #category : #operation }
PMMatrix >> cosh [
	"Apply cosh to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each cosh])
]

{ #category : #transformation }
PMMatrix >> cumsum [
	"Computes the cumulative sum for each row."

	^ PMMatrix rows: (rows collect: [ :each | each cumsum ])
]

{ #category : #'as yet unclassified' }
PMMatrix >> decompose [

	^ PMSingularValueDecomposition decompose: self
]

{ #category : #accessing }
PMMatrix >> determinant [
	^ self lupDecomposition determinant
]

{ #category : #accessing }
PMMatrix >> dimension [

	^ self rows size @ (self rows at: 1) size
]

{ #category : #operation }
PMMatrix >> dot: aMatrix [
	"Answers the elementwise product of the receiver with aMatrix."
	^ aMatrix elementwiseProductWithMatrix: self
]

{ #category : #operation }
PMMatrix >> eigen [
	"Computes all eigenvalues and eigenvectors of a matrix.
	Usage:
	matrix eigen values.
	matrix eigen vectors."

	self isSymmetric
		ifTrue: [ ^ self asSymmetricMatrix eigen ]
		ifFalse: [ self error: 'Eigenvalues and eigenvectors of non-symmetric matrix are currently not supported' ]
]

{ #category : #'double dispatching' }
PMMatrix >> elementwiseProductWithMatrix: aMatrix [
	"Answers the elementwise product between aMatrix and the receiver as a Matrix."
	| n |
	n := 0.
	^ PMMatrix rows: ( aMatrix rowsCollect: [ :each | n := n + 1. each dot: ( self rowAt: n)])

]

{ #category : #'as yet unclassified' }
PMMatrix >> equalsTo: aMatrix [
	self rows 
			with: aMatrix rows  
			do: [:a :b| (a equalsTo: b) ifFalse: [ ^false ] ].
	^ true 
]

{ #category : #comparing }
PMMatrix >> hash [
	^ rows hash
]

{ #category : #initialization }
PMMatrix >> initialize: anInteger [
	"Build empty components for a square matrix. No check is made: components are assumed to be orgainized in rows."
	rows := (1 to: anInteger) asPMVector collect: [ :each | PMVector new: anInteger].
]

{ #category : #initialization }
PMMatrix >> initializeRows: anArrayOrVector [
	"Defines the components of the recevier. No check is made: components are assumed to be orgainized in rows."
	rows := anArrayOrVector asPMVector collect: [ :each | each asPMVector].
]

{ #category : #operation }
PMMatrix >> inverse [
	"Answer the inverse of the receiver."

	^ self isSquare 
		ifTrue: [ self lupInverse ]
		ifFalse: [ self squared inverse * self transpose ]
]

{ #category : #'as yet unclassified' }
PMMatrix >> inversePivotColumns: anArray [
	"uses vector encoding of an interchange permutation matrix  in anArray as in qrFactorizationWithPivoting. Does inverse pivoting!"
	| res |
	res :=self deepCopy.
	anArray reverseWith: (1 to: anArray size ) do:  [ :piv :ind | piv ~= ind ifTrue: [res swapColumn: piv withColumn: ind ] ].
	^ res
]

{ #category : #operation }
PMMatrix >> inversePureCRL [
	"Answer the inverse of the receiver."
	^ self squared inversePureCRL * self transpose
]

{ #category : #testing }
PMMatrix >> isSquare [
	"Answers true if the number of rows is equal to the number of columns."
	^ rows size = rows last size
]

{ #category : #testing }
PMMatrix >> isSymmetric [
	^ self = self transpose 
]

{ #category : #private }
PMMatrix >> largestPowerOf2SmallerThan: anInteger [
	"Private - "
	| m m2|
	m := 2.
	[ m2 := m * 2.
	  m2 < anInteger] whileTrue:[ m := m2].
	^m
]

{ #category : #operation }
PMMatrix >> log [
	"Apply log to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each log])
	
]

{ #category : #accessing }
PMMatrix >> lupDecomposition [

	lupDecomposition isNil
		ifTrue: [ lupDecomposition :=PMLUPDecomposition equations: rows ].
	^ lupDecomposition
]

{ #category : #operation }
PMMatrix >> lupInverse [
	self lupDecomposition inverseMatrixComponents
		ifNil: [ PMSingularMatrixError new signal ]
		ifNotNil: [ :i | ^ self class rows: i ]
]

{ #category : #'as yet unclassified' }
PMMatrix >> mpInverse [
	"Moore Penrose Inverse. "
	|f g|
	self numberOfRows < self numberOfColumns 
		ifTrue:[	f := self transpose qrFactorizationWithPivoting. 
					g := f first.
					f := f second inversePivotColumns: (f at:3) ]
		ifFalse: [ f := self qrFactorizationWithPivoting. 
					g := (f second  inversePivotColumns: (f at:3)) transpose.
					f := f first transpose ]. 
	^ g * ((f *self *g) inverse) *f
]

{ #category : #transformation }
PMMatrix >> negate [
	"Inverse the sign of all components of the receiver."
	rows do: [ :each |each negate ]
]

{ #category : #accessing }
PMMatrix >> numberOfColumns [
	"Answer the number of rows of the receiver."
	^ rows last size
]

{ #category : #accessing }
PMMatrix >> numberOfRows [
	"Answer the number of rows of the receiver."
	^ rows size
]

{ #category : #'as yet unclassified' }
PMMatrix >> orthogonalize [
	"returns an orthonormal basis of column (!) vectors for a matrix of column vectors"
	^ self qrFactorizationWithPivoting first

]

{ #category : #printing }
PMMatrix >> printOn: aStream [
	(rows isNil or: [rows first isNil])
		ifTrue: [ super printOn: aStream. 
					aStream nextPutAll:'(uninitialized)'. ^ self ].
	rows 
		do: [ :each | each printOn: aStream]
		separatedBy: [ aStream cr].
		  
		
]

{ #category : #private }
PMMatrix >> privateTranspose [
	^ self transpose 
]

{ #category : #'double dispatching' }
PMMatrix >> productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order)."
	^ self productWithMatrixFinal: aMatrix
]

{ #category : #'double dispatching' }
PMMatrix >> productWithMatrixFinal: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order)."
	"speed optimized"
	|t|
	t :=self privateTranspose.
	^ PMMatrix  rows: ( aMatrix rowsCollect: [ :row | t rowsCollect: [ :col | row * col]])
]

{ #category : #'double dispatching' }
PMMatrix >> productWithTransposeMatrix: aMatrix [
	"Answers the product of the receiver with the transpose of aMatrix(in this order)."
	^ PMMatrix rows: (self rowsCollect: [ :row | aMatrix rowsCollect: [ :col | row * col]])
]

{ #category : #'double dispatching' }
PMMatrix >> productWithVector: aVector [
	"Answers the product of the receiver with aVector"
	^ self columnsCollect: [ :each | each * aVector ]
]

{ #category : #'as yet unclassified' }
PMMatrix >> qrFactorization [
	|identMat q r hh colSize i|
	self numberOfRows < self numberOfColumns ifTrue:[ self error: 'numberOfRows<numberOfColumns' ]. 
	r :=PMMatrix rows: (rows deepCopy).
	colSize := self numberOfRows.
	q := PMSymmetricMatrix identity: colSize.  
	identMat := q deepCopy.
	1 to: self numberOfColumns do: [:col| 
		hh := ((r columnAt: col) copyFrom: col to: colSize) householder.
		i := (PMVector new: col-1withAll: 0) , (hh at:2 ).
		q := q* (identMat - ((hh at: 1)*i tensorProduct: i ))."not really necessary, should be simplified"
		i := PMMatrix rows:  ( (r rows allButFirst: (col -1)) collect: [:aRow| aRow allButFirst: (col -1)]  ).
		i := i - ((hh at: 2) tensorProduct: ( (hh at: 1)*(hh at: 2)*i  ) ) .
		i rows withIndexDo: [ :aRow :index |
			aRow  withIndexDo: [ :n :c| r rowAt: (col + index -1) columnAt: (col +c -1) put: ((n equalsTo: 0) ifTrue: [0] ifFalse:  [n]  )  ]  ] .
	"col <colSize ifTrue: [i :=(hh at: 2) copyFrom: 2 to: colSize -col +1.  i withIndexDo: [:n :index| r rowAt: col columnAt: index put: n  ]  ]""and this part is not correct, dont uncomment before the bug is corrected! useful if q is not explicitely necessary" ].
"r rows allButFirst withIndexDo: [:aRow :ri|1 to: (ri min: self numberOfColumns ) do: [:ci|aRow at: ci put:0  ]   ]  ""not necessary with equalsTo:0"  
	i :=0.
	[(r rowAt: colSize) allSatisfy: [:n| n=0]  ]whileTrue: [i :=i+1.colSize :=colSize -1].
	i>0 ifTrue: [ r :=PMMatrix rows: (r rows copyFrom: 1 to:  colSize). 
					i := q numberOfColumns - i. 
					q := PMMatrix rows:  ( q rows collect: [:row| row copyFrom: 1 to: i]) ].  
	^{q. r}
]

{ #category : #'as yet unclassified' }
PMMatrix >> qrFactorizationWithPivoting [
	| identMat q r hh colSize i lengthArray rank mx pivot |
	self numberOfRows < self numberOfColumns
		ifTrue: [ self error: 'numberOfRows<numberOfColumns' ].
	lengthArray := self columnsCollect: [ :col | col * col ].
	mx := lengthArray indexOf: lengthArray max.
	pivot := Array new: lengthArray size.
	rank := 0.
	r := PMMatrix rows: rows deepCopy.
	colSize := self numberOfRows.
	q := PMSymmetricMatrix identity: colSize.
	identMat := q deepCopy.
	[ 
	rank := rank + 1.
	pivot at: rank put: mx.
	r swapColumn: rank withColumn: mx.
	lengthArray swap: rank with: mx.
	hh := ((r columnAt: rank) copyFrom: rank to: colSize) householder.
	i := (PMVector new: rank - 1 withAll: 0) , (hh at: 2).
	q := q * (identMat - ((hh at: 1) * i tensorProduct: i)).
	i := PMMatrix rows: ((r rows allButFirst: rank - 1) collect: [ :aRow | aRow allButFirst: rank - 1 ]).
	i := i - ((hh at: 2) tensorProduct: (hh at: 1) * (hh at: 2) * i).
	i rows
		withIndexDo: [ :aRow :index | 
			aRow
				withIndexDo: [ :n :c | 
					r
						rowAt: rank + index - 1
						columnAt: rank + c - 1
						put:
							((n equalsTo: 0)
								ifTrue: [ 0 ]
								ifFalse: [ n ]) ] ].
	rank + 1 to: lengthArray size do: [ :ind | lengthArray at: ind put: (lengthArray at: ind) - (r rowAt: rank columnAt: ind) squared ].
	rank < lengthArray size
		ifTrue: [ 
			mx := (lengthArray copyFrom: rank + 1 to: lengthArray size) max.
			(mx equalsTo: 0)
				ifTrue: [ mx := 0 ].
			mx := mx > 0
				ifTrue: [ lengthArray indexOf: mx startingAt: rank + 1 ]
				ifFalse: [ 0 ] ]
		ifFalse: [ mx := 0 ].
	mx > 0 ] whileTrue.
	i := 0.
	[ (r rowAt: colSize) allSatisfy: [ :n | n = 0 ] ]
		whileTrue: [ 
			i := i + 1.
			colSize := colSize - 1 ].
	i > 0
		ifTrue: [ 
			r := PMMatrix rows: (r rows copyFrom: 1 to: colSize).
			i := q numberOfColumns - i.
			pivot := pivot copyFrom: 1 to: i.
			q := PMMatrix rows: (q rows collect: [ :row | row copyFrom: 1 to: i ]) ].
	^ {q.
	r.
	pivot}
]

{ #category : #'as yet unclassified' }
PMMatrix >> rank [ 
	^	((self numberOfRows < self numberOfColumns 
			ifTrue: [ self transpose ] 
			ifFalse: [ self ])  qrFactorizationWithPivoting at: 2) rows size 
]

{ #category : #'cell accessing' }
PMMatrix >> rowAt: anInteger [
	"Answers the anInteger-th row of the receiver."
	^ rows at: anInteger
]

{ #category : #'cell accessing' }
PMMatrix >> rowAt: aRowIndex columnAt: aColumnIndex [
	"Answers the aRowIndex-th, aColumnIndex-th entry in the receiver."
	^ (rows at: aRowIndex) at: aColumnIndex
]

{ #category : #'cell accessing' }
PMMatrix >> rowAt: aRowIndex columnAt: aColumnIndex put: aValue [
	
	^(rows at: aRowIndex) at: aColumnIndex put: aValue
]

{ #category : #'cell accessing' }
PMMatrix >> rows [
	^rows
]

{ #category : #iterators }
PMMatrix >> rowsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	^ rows collect: aBlock
]

{ #category : #iterators }
PMMatrix >> rowsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	^ rows do: aBlock
]

{ #category : #transformation }
PMMatrix >> scaleBy: aNumber [

	rows do: [ :each | each scaleBy: aNumber ]
]

{ #category : #'cell accessing' }
PMMatrix >> setDiagonal: aVector [

	| n m |
	n := self numberOfRows.
	m := self numberOfColumns.
	n < m
		ifTrue: [
				1 to: n do: [ :i | self rowAt:  i columnAt: i put: (aVector at: i)].
				 ]
		ifFalse: [
				1 to: m do: [ :i | self rowAt:  i columnAt: i put: (aVector at: i)].
				 ].
	^self
]

{ #category : #operation }
PMMatrix >> sin [
	"Apply sin to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each sin])
]

{ #category : #operation }
PMMatrix >> sinh [
	"Apply sinh to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each sinh])
	
]

{ #category : #private }
PMMatrix >> species [
	^ PMMatrix 
]

{ #category : #private }
PMMatrix >> split [
	"Private - Answers an array of 4 matrices split from the receiver."
	| n m n1 m1 |
	n := self numberOfRows.
	m := self numberOfColumns.
	n1 := self largestPowerOf2SmallerThan: n.
	m1 := self largestPowerOf2SmallerThan: m.
	^ Array
		with: ( self class rows: ( ( 1 to: n1) asPMVector collect: [ :k | ( rows at: k) copyFrom: 1 to: m1]))
		with:( self class rows: ( ( 1 to: n1) asPMVector collect: [ :k | ( rows at: k) copyFrom: (m1 + 1) to: m]))
		with: ( self class rows: ( ( (n1 + 1) to: n) asPMVector collect: [ :k | ( rows at: k) copyFrom: 1 to: m1]))
		with:( self class rows: ( ( (n1 + 1) to: n) asPMVector collect: [ :k | ( rows at: k) copyFrom: (m1 + 1) to: m]))
]

{ #category : #operation }
PMMatrix >> sqrt [
	"Apply sqrt to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each sqrt])
]

{ #category : #operation }
PMMatrix >> squared [
	| transposed |
	transposed :=self privateTranspose.
	^ PMSymmetricMatrix 
		new: transposed numberOfRows 
		function: [ :x :y|(transposed rowAt: x) * (transposed rowAt: y) ]

]

{ #category : #private }
PMMatrix >> strassenProductWithMatrix: aMatrix [
	"Private"
	| matrixSplit selfSplit p1 p2 p3 p4 p5 p6 p7 |
	( self numberOfRows > 2 and: [ self numberOfColumns > 2])
		ifFalse:[ ^self class rows: ( aMatrix rowsCollect: [ :row | self columnsCollect: [ :col | row * col]])].
	selfSplit := self split.
	matrixSplit := aMatrix split.
	p1 := ( ( selfSplit at: 2) - ( selfSplit at: 4)) strassenProductWithMatrix: ( matrixSplit at: 1).
	p2 := ( selfSplit at: 4) strassenProductWithMatrix: ( ( matrixSplit at: 1) + ( matrixSplit at: 2)).
	p3 := ( selfSplit at: 1) strassenProductWithMatrix: ( ( matrixSplit at: 3) + ( matrixSplit at: 4)).
	p4 := ( ( selfSplit at: 3) - ( selfSplit at: 1)) strassenProductWithMatrix: ( matrixSplit at: 4).
	p5 := ( ( selfSplit at: 1) + ( selfSplit at: 4)) strassenProductWithMatrix: ( ( matrixSplit at: 1) + ( matrixSplit at: 4)).
	p6 := ( ( selfSplit at: 3) + ( selfSplit at: 4)) strassenProductWithMatrix: ( ( matrixSplit at: 2) - ( matrixSplit at: 4)).
	p7 := ( ( selfSplit at: 1) + ( selfSplit at: 2)) strassenProductWithMatrix: ( ( matrixSplit at: 1) - ( matrixSplit at: 3)).
	^self class join: ( Array
							with: ( p5 + p4 + p6 - p2)
							with: (p1 + p2)
							with: ( p3 + p4)
							with: ( p5 + p1 - p3 - p7)
							)
]

{ #category : #'double dispatching' }
PMMatrix >> subtractWithRegularMatrix: aMatrix [
	"Answers the difference between aMatrix and the receiver as a Matrix."
	| n |
	n := 0.
	^ PMMatrix rows: ( aMatrix rowsCollect: [ :each | n := n + 1. each - ( self rowAt: n)])
]

{ #category : #'double dispatching' }
PMMatrix >> subtractWithSymmetricMatrix: aMatrix [
	"Answers the difference between aMatrix and the receiver."
	^ self subtractWithRegularMatrix: aMatrix 
]

{ #category : #transformation }
PMMatrix >> sum [
	"Computes the row sum."

	| a |
	a := PMVector new: self numberOfRows.
	1 to: a size do: [ :n | a at: n put: (self rowAt: n) sum ].
	^ a
]

{ #category : #'as yet unclassified' }
PMMatrix >> swapColumn: anIndex withColumn:   a2Index [
	self rowsDo: [ :r| r swap: anIndex with: a2Index ]  

]

{ #category : #operation }
PMMatrix >> tan [
	"Apply tan to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each tan])
]

{ #category : #operation }
PMMatrix >> tanh [
	"Apply tanh to each element of a matrix"
	| n |
	n := 0.
	^ PMMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each tanh])
	
]

{ #category : #operation }
PMMatrix >> tr [
	"Return the trace or sum along diagonals of the array."
	"https://en.wikipedia.org/wiki/Trace_(linear_algebra)"

	| result |
	result := 0.
	1 to: self numberOfRows do: [ :n | result := result + (self at: n at: n) ].
	^ result
]

{ #category : #operation }
PMMatrix >> transpose [
	"Answer a new matrix, transpose of the receiver."
	^ self class rows: ( self columnsCollect: [ :each | each])
]

{ #category : #'double dispatching' }
PMMatrix >> transposeProductWithMatrix: aMatrix [
	"Answers the product of the transpose of the receiver with aMatrix (in this order)."
	"speed optimized"
	|t|
	t :=aMatrix privateTranspose.
	^ PMMatrix rows: (self columnsCollect: [ :row | t rowsCollect: [ :col | row * col]])
]