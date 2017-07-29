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

	private var model: Model!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.model = Model(delegate: self)
	}
	
	// MARK: - UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.model.objects.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		cell.textLabel!.text = self.model.objects[indexPath.row].name
		
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

