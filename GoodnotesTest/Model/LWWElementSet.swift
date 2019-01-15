//
//  LWWElementSet.swift
//  GoodnotesTest
//
//  Created by Nikita Medvedev on 15/01/2019.
//  Copyright © 2019 Goodnotes. All rights reserved.
//

import UIKit

/// LWW Element Set Implementation
///
/// - Parameter T: atomic element for the set. Restricted to Hashable
///
class LWWElementSet<T: Hashable> {

	typealias TimestampSet = [T: TimeInterval]
	
	private var addSet = TimestampSet()
	private var removeSet = TimestampSet()
	
	init() {
		
	}
	
	init(elements: [T]) {
		elements.forEach { _ = add($0) }
	}
	
	private init(addSet: TimestampSet, removeSet: TimestampSet) {
		self.addSet = addSet
		self.removeSet = removeSet
	}
	
	
	// MARK: - API

	
	/// Getter for plain set values
	///
	/// - Returns: values existing in set
	public var values: [T] {
		return addSet.keys.filter { addSet[$0]! > (removeSet[$0] ?? 0.0) }
	}
	
	/// Manager for timestamps
	///
	/// - Returns: timestamp manager
	public var timestampManager = TimestampManager()
	
	/// Checks if element exists in the set
	///
	/// - Parameter element: the element to find
	/// - Returns: true if elements exists in set, false overwise
	public func lookup(_ element: T) -> Bool {
		guard let addTimestamp = addSet[element] else {
			return false
		}
		
		guard let removeTimestamp = removeSet[element] else {
			return true
		}
		
		return addTimestamp > removeTimestamp
	}
	
	/// Adds an element into the set
	///
	/// - Parameter element and timestamp: the element to add and the timestamp of addition
	/// - Returns: self object so operation sequences could be created
	@discardableResult
	public func add(_ element: T, time: TimeInterval? = nil) -> Self {
		addSet[element] = time ?? timestampManager.currentTimestamp
		
		return self
	}
	
	/// Removes an element into the set
	///
	/// - Parameter element and timestamp: the element to add and the timestamp of removal
	/// - Returns: self object so operation sequences could be created
	@discardableResult
	public func remove(_ element: T, time: TimeInterval? = nil) -> Self {
		guard lookup(element) else {
			return self
		}
		removeSet[element] = time ?? timestampManager.currentTimestamp
		
		return self
	}
	
	/// Merges two structures into one
	///
	/// - Parameter other: the second set to merge current one with
	/// - Returns: merged element set
	public func merging(_ other: LWWElementSet<T>) -> LWWElementSet<T> {
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

// MARK: - Timestamp Manager
class TimestampManager {
	var currentTimestamp: TimeInterval {
		return Date().timeIntervalSince1970
	}
}
