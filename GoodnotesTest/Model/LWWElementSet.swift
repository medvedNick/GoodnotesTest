//
//  LWWElementSet.swift
//  GoodnotesTest
//
//  Created by Nikita Medvedev on 15/01/2019.
//  Copyright © 2019 Goodnotes. All rights reserved.
//

import UIKit

class LWWElementSet<T: Hashable> {

	typealias TimestampSet = [T: TimeInterval]
	
	private var addSet = TimestampSet()
	private var removeSet = TimestampSet()
	
	init() {
		
	}
	
	init(elements: [T]) {
		elements.forEach { add($0) }
	}
	
	private init(addSet: TimestampSet, removeSet: TimestampSet) {
		self.addSet = addSet
		self.removeSet = removeSet
	}
	
	var currentTimestamp: TimeInterval {
		return Date().timeIntervalSince1970
	}
	
	private var values: [T] {
		return addSet.keys.filter { addSet[$0]! > (removeSet[$0] ?? 0.0) }
	}
	
	// MARK: - API
	
	public func lookup(_ element: T) -> Bool {
		guard let addTimestamp = addSet[element] else {
			return false
		}
		
		guard let removeTimestamp = removeSet[element] else {
			return true
		}
		
		return addTimestamp > removeTimestamp
	}
	
	public func add(_ element: T) {
		addSet[element] = currentTimestamp
	}
	
	public func remove(_ element: T) {
		if !lookup(element) {
			return
		}
		removeSet[element] = currentTimestamp
	}
	
	public func merge(_ other: LWWElementSet<T>) -> LWWElementSet<T> {
		let newAddSet = LWWElementSet.merge(set1: addSet, set2: other.addSet)
		let newRemoveSet = LWWElementSet.merge(set1: removeSet, set2: other.removeSet)
		
		return LWWElementSet(addSet: newAddSet, removeSet: newRemoveSet)
	}
}

// MARK: - Equatable
extension LWWElementSet: Equatable {
	static func == (lhs: LWWElementSet<T>, rhs: LWWElementSet<T>) -> Bool {
		return Set(lhs.values) == Set(rhs.values)
	}
}

// MARK: - Helper
extension LWWElementSet {
	static private func merge(set1: TimestampSet, set2: TimestampSet) -> TimestampSet {
		let newKeys = Array(set1.keys) + Array(set2.keys)
		return Dictionary(newKeys.map { timestamp in
			return (timestamp, max(set1[timestamp] ?? 0.0, set2[timestamp] ?? 0.0))
		}) { timestamp1, timestamp2 in
			return max(timestamp1, timestamp2)
		}
	}
}
