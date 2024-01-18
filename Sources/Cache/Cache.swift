//
//  Cache.swift
//  Pocket Congress
//
//  Created by Siddharth M. Bhatia on 12/21/23.
//

import Foundation

/// `Cache` handles loading content asyncronously while efficently handling concurrent duplicative requests.
actor Cache<Input, Output>: ObservableObject where Input: Hashable {
	
	/// Method that is used to asynchronously load a given `Output` 
	/// from an `Input`.
	private var load: (Input) async throws -> Output
	
	/// Creates a new `Cache`.
	///
	/// - Parameter load: Method to asyncronously load data from the source.
	///					  The result will be cached for subsequent requests.
	public init(load: @escaping (Input) async throws -> Output) {
		self.load = load
	}
	
	@Published
	/// <#Description#>
	public var _storage: [Input : Entry] = [:]
	
	/// Accesses a value from the cache, loading it if not found.
	/// - Parameter input: The value to look for in the cache, or load.
	/// - Returns: The value either stored in the cache or loaded.
	/// - Throws: Rethrows any errors thrown from the load task.
	private func value(for input: Input) async throws -> Output {
		if let cached = _storage[input] {
			switch cached {
				case .ready(let output):
					return output
				case .inProgress(let task):
					return try await task.value
			}
		}
		
		let task = Task {
			try await load(input)
		}
		
		_storage[input] = .inProgress(task)
		
		do {
			let output = try await task.value
			_storage[input] = .ready(output)
			return output
		} catch {
			_storage.removeValue(forKey: input)
			throw error
		}
	}
	
	subscript(input: Input) -> Output {
		get async throws {
			return try await self.value(for: input)
		}
	}
	
	/// Retrieves a value immediately if already cached.
	/// 
	/// - Parameter input: The value to retrieve.
	/// - Returns: The result for the specified input, if already loaded. Otherwise, returns `nil`.
	func retrieveIfAvailable(_ input: Input) -> Output? {
		if case .ready(let output) = _storage[input] {
			return output
		}
		return nil
	}
	
	/// A result or pending result stored in the cache.
	private enum Entry {
		case inProgress(Task<Output, Error>)
		case ready(Output)
	}
	
}
