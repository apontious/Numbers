//
//  Model.swift
//  Numbers http://github.com/apontious/Numbers
//
//  Created by Andrew Pontious on 7/28/17.
//  Copyright © 2017 Andrew Pontious. All rights reserved.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

import UIKit

class ModelObject: CustomStringConvertible {
	let name: String
	let url: URL
	let index: Int
	let useCache: Bool
	
	private var image: UIImage?
	
	init(name: String, url: URL, index: Int, useCache: Bool) {
		self.name = name
		self.url = url
		self.index = index
		self.useCache = useCache
	}
	
	// MARK: CustomStringConvertible
	
	public var description: String {
		return "{name \"\(name)\" url \(url) index \(index)}"
	}
	func image(_ handler: @escaping (UIImage?, Error?) -> Void) {
		assert(Thread.isMainThread)
		
		// Image already loaded, can invoke callback synchronously (but don't count on it!).
		if (useCache && image != nil) {
			handler(image, nil)
			return
		}

		let savedDescription = self.description
		
		URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (imageData, response, error) in
			// Callback will be on background thread. Do work here, but only modify self and invoke callbacks on main thread.
			
			do {
				guard error == nil else {
					throw JSONError.message("Unable to fetch image data from \(savedDescription): \(error!)")
				}
				guard let imageData = imageData else {
					throw JSONError.message("Unable to fetch image data from \(savedDescription): No image data and no error specified")
				}
				guard let image = UIImage(data: imageData) else {
					throw JSONError.message("Image data from \(savedDescription) is not a valid image")
				}
				
				DispatchQueue.main.sync {
					self?.image = image // Modify properties only on main thread for safety
					handler(image, nil)
				}
			} catch {
				DispatchQueue.main.sync {
					handler(nil, error)
				}
			}
		}).resume()
		
	}
	
}

protocol ModelDelegate {
	func didReceiveObjects(error: Error?)
}

private enum JSONError: Error {
	case message(String)
}

/**
 Designed to be used only on main thread for simplicity.
 */
class Model {
	
	// MARK: Private
	
	private let delegate: ModelDelegate
	
	private let jsonURL = URL(string: "https://raw.githubusercontent.com/apontious/Numbers/master/list.json")!
	
	// MARK: APIs
	
	private(set) var objects: [ModelObject] = []

	init(useCache: Bool, delegate: ModelDelegate) {
		assert(Thread.isMainThread)
		
		self.delegate = delegate
		
		let savedUseCacheFlag = useCache
		
		URLSession.shared.dataTask(with: jsonURL, completionHandler: { [weak self] (jsonData, response, error) in
			// Callback will be on background thread. Do work here, but only modify self and invoke callbacks on main thread.
			
			do {
				guard error == nil else {
					throw JSONError.message("Unable to fetch JSON data: \(error!)")
				}
				guard let jsonData = jsonData else {
					throw JSONError.message("Unable to fetch JSON data: No JSON data and no error specified")
				}
				guard let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: String]] else {
					throw JSONError.message("JSON data not an array of dictionaries of strings")
				}
				
				var i = 0
				
				let objects: [ModelObject] = try jsonArray.map({ (dictionary: [String : String]) -> ModelObject in
					guard let name = dictionary["name"] else {
						throw JSONError.message("In JSON array of dictionaries, in dictionary at index \(i), key/value pair \"name\" is missing")
					}
					guard let urlString = dictionary["url"] else {
						throw JSONError.message("In JSON array of dictionaries, in dictionary at index \(i), key/value pair \"url\" is missing")
					}
					guard let url = URL(string: urlString) else {
						throw JSONError.message("In JSON array of dictionaries, in dictionary at index \(i), the string \(urlString) in key/value pair \"url\" is not a valid URL")
					}
					let object = ModelObject(name: name, url: url, index: i, useCache: savedUseCacheFlag)
					
					i = i+1
					
					return object
				})
				
				DispatchQueue.main.sync {
					self?.objects = objects // Modify properties only on main thread for safety
					self?.delegate.didReceiveObjects(error: nil)
				}
			} catch {
				DispatchQueue.main.sync {
					self?.delegate.didReceiveObjects(error: error)
				}
			}
		}).resume()
	}
}
