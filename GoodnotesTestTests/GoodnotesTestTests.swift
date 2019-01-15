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
		set.add(2).remove(3).add(3).remove(2)
		
		XCTAssert(set.lookup(2) == false, "Element 2 is not in set")
		XCTAssert(set.lookup(3) == true, "Element 3 is in set")
	}
	
	func test_addRemoveWithDifferentResult() {
		let set = LWWElementSet<Int>()
		set.add(2).remove(3).add(3).remove(2)
		
		XCTAssert(set.lookup(2) == false, "Element 2 is not in set")
		XCTAssert(set.lookup(3) == true, "Element 3 is in set")
	}
	
	func test_simpleMergeSets() {
		let set1 = LWWElementSet(elements: [1, 2, 3, 4])
		let set2 = LWWElementSet(elements: [2, 3, 1, 4])
		let set3 = LWWElementSet(elements: [1, 2, 3, 4])
		let resultSet = set1.merging(set2)
		
		XCTAssert(set3 == resultSet, "Merge result with same values is incorrect")
	}
	
	func test_mergeSetsWithInitialValues() {
		let set1 = LWWElementSet(elements: [1, 2, 3])
		let set2 = LWWElementSet(elements: [2, 3, 4])
		let set3 = LWWElementSet(elements: [1, 2, 3, 4])
		let resultSet = set1.merging(set2)
		
		XCTAssert(set3 == resultSet, "Merge result with initial values is incorrect")
	}
	
	func test_mergeSets() {
		let set1 = LWWElementSet<Int>()
		let set2 = LWWElementSet<Int>()
		let set3 = LWWElementSet(elements: [1, 2, 4])
		
		// one can set timestamp manager so no neet to set time on each -add or -remove
		let manager = TestTimestampManager()
		set1.timestampManager = manager
		set2.timestampManager = manager
		
		set1.add(1).add(2).add(3).remove(2)
		set2.add(2).add(3).add(4).remove(3)
		
		let resultSet = set1.merging(set2)
		
		XCTAssert(set3 == resultSet, "Merge result is incorrect")
	}
	
	func test_complexMergeSetsWithTimestamps() {
		let set1 = LWWElementSet<Int>()
		let set2 = LWWElementSet<Int>()
		let set3 = LWWElementSet(elements: [1, 3])
		
		// in this test its more consistent to set time manually;
		// '1' would be removed on set1 before addition on set2 in terms of time, so it should exists in result
		set1.add(1, time: 1.0).remove(1, time: 2.0)
		set2.add(1, time: 3.0).add(3, time: 4.0)
		
		let resultSet = set1.merging(set2)
		
		XCTAssert(set3 == resultSet, "Merge result is incorrect")
	}
}

class TestTimestampManager: TimestampManager {
	var index = 0.0
	
	override var currentTimestamp: TimeInterval {
		index += 1.0
		return index
	}
}

