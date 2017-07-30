//
//  NumbersViewController.swift
//  Numbers http://github.com/apontious/Numbers
//
//  Created by Andrew Pontious on 7/25/17.
//  Copyright © 2017 Andrew Pontious. All rights reserved.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

import UIKit

class NumbersViewController: UITableViewController, ModelDelegate {

	private var model: Model?
	
	private var wrongMode = true

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Wrong", style: .plain, target: self, action: #selector(_num_toggleLoading(_:)))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		_num_resetTableView()
	}
	
	// MARK: - Private
	
	func _num_resetTableView() {
		model = nil
		tableView.reloadData()
		
		URLSession.shared.reset {
			DispatchQueue.main.async {
				self.model = Model(useCache: false, delegate: self)
				self.tableView.reloadData()
			}
		}
	}
	
	func _num_toggleLoading(_ sender: UIBarButtonItem) {
		if wrongMode {
			sender.title = "Right"
			wrongMode = false

		} else {
			sender.title = "Wrong"
			wrongMode = true
		}

		_num_resetTableView()
	}
	
	func _num_loadImage(forObject object: ModelObject, cell: UITableViewCell) {
		let savedWrongMode = wrongMode
		
		object.image { [weak self] (image, error) in
			if error != nil || image == nil {
				// TODO: display alert?
				return
			}
			
			if savedWrongMode {
				// Wrong Mode
				// Set loaded image on cell that originally requested it.
				// This is wrong because cell might have gotten recycled between request and fulfillment.
				cell.imageView!.image = image!
			} else {
				// Right Mode
				// Set loaded image on cell that currently corresponds to row (might not be currently visible).
				// Exercise for reader: cancel requests for cells that are no longer visible.
				if let currentCell = self?.tableView.cellForRow(at: IndexPath(row: object.index, section: 0)) {
					currentCell.imageView!.image = image!
				}
			}
		}
		
	}
	
	// MARK: - UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.model != nil {
			return self.model!.objects.count
		} else {
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let object = self.model!.objects[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		cell.textLabel!.text = object.name

		_num_loadImage(forObject: object, cell: cell)
		
		return cell
	}

	// MARK: - ModelDelegate
	
	func didReceiveObjects(error: Error?) {
		if (error != nil) {
			// TODO: display error?
		} else {
			self.tableView.reloadData()
		}
	}
}

