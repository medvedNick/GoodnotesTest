//
//  GoodnotesTestTests.swift
//  GoodnotesTestTests
//
//  Created by Nikita Medvedev on 15/01/2019.
//  Copyright © 2019 Goodnotes. All rights reserved.
//

import XCTest
@testable import GoodnotesTest

class GoodnotesTestTests: XCTestCase {

    override func setUp() {
		
    }

    override func tearDown() {
		
    }

    func test_emptySetsAreEqual() {
		let set1 = LWWElementSet(elements: [Int]())
		let set2 = LWWElementSet(elements: [Int]())
		
		XCTAssert(set1 == set2, "Empty sets are not equal")
    }

	func test_initialValueSetsAreEqual() {
		let set1 = LWWElementSet(elements: [1, 2, 3, 4])
		let set2 = LWWElementSet(elements: [2, 3, 1, 4])
		let set3 = LWWElementSet(elements: [1, 2, 4])
		
		XCTAssert(set1 == set2, "Sets with same initial values are not equal")
		XCTAssert(set1 != set3, "Sets with different initial values are equal")
	}
	
	func test_lookupElement() {
		let set = LWWElementSet(elements: [1, 2, 3, 4])
		
		XCTAssert(set.lookup(2), "Element 2 is not in set")
	}
	
	func test_lookupElementAfterAdd() {
		let set = LWWElementSet<Int>()
		set.add(2)
		
		XCTAssert(set.lookup(2) == true, "Element 2 is not in set")
		XCTAssert(set.lookup(3) == false, "Element 3 is in set")
	}
	
	func test_addRemoveElements() {
		let set = LWWElementSet<Int>()
		set.add(2)
		set.remove(3)
		set.add(3)
		set.remove(2)
		
		XCTAssert(set.lookup(2) == false, "Element 2 is not in set")
		XCTAssert(set.lookup(3) == true, "Element 3 is in set")
	}
	
	func test_addRemoveWithDifferentResult() {
		let set = LWWElementSet<Int>()
		set.add(2)
		set.remove(3)
		set.add(3)
		set.remove(2)
		
		XCTAssert(set.lookup(2) == false, "Element 2 is not in set")
		XCTAssert(set.lookup(3) == true, "Element 3 is in set")
	}
	
	func test_simpleMergeSets() {
		let set1 = LWWElementSet(elements: [1, 2, 3, 4])
		let set2 = LWWElementSet(elements: [2, 3, 1, 4])
		let set3 = LWWElementSet(elements: [1, 2, 3, 4])
		let resultSet = set1.merge(set2)
		
		XCTAssert(set3 == resultSet, "Merge result with same values is incorrect")
	}
	
	func test_mergeSetsWithInitialValues() {
		let set1 = LWWElementSet(elements: [1, 2, 3])
		let set2 = LWWElementSet(elements: [2, 3, 4])
		let set3 = LWWElementSet(elements: [1, 2, 3, 4])
		let resultSet = set1.merge(set2)
		
		XCTAssert(set3 == resultSet, "Merge result with initial values is incorrect")
	}
	
	func test_mergeSets() {
		let set1 = LWWElementSet<Int>()
		let set2 = LWWElementSet<Int>()
		let set3 = LWWElementSet(elements: [1, 3, 4])
		
		set1.add(1)
		set1.add(2)
		set1.add(3)
		
		set1.remove(2)
		
		set2.add(2)
		set2.add(3)
		set2.add(4)
		
		let resultSet = set1.merge(set2)
		
		XCTAssert(set3 == resultSet, "Merge result is incorrect")
	}
	
	func test_complexMergeSetsWithTimestamps() {
		let set1 = LWWTestElementSet(timestamps: [1.0, 3.0])
		let set2 = LWWTestElementSet(timestamps: [4.0, 5.0])
		let set3 = LWWElementSet(elements: [1, 3])
		
		set1.add(1)
		set1.remove(1)
		
		set2.add(1)
		set2.add(3)
		
		let resultSet = set1.merge(set2)
		
		XCTAssert(set3 == resultSet, "Merge result is incorrect")
	}
}

// Mock class which allows to manually set timestamps for operations
class LWWTestElementSet: LWWElementSet<Int> {
	var timestamps: [TimeInterval]
	
	init(timestamps: [TimeInterval]) {
		self.timestamps = timestamps
		super.init()
	}
	
	var index = 0
	override var currentTimestamp: TimeInterval {
		let timestamp = timestamps[index]
		index += 1
		return timestamp
	}
}
