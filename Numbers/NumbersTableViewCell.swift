//
//  NumbersTableViewCell.swift
//  Numbers
//
//  Created by Andrew Pontious on 7/30/17.
//  Copyright © 2017 Andrew Pontious. All rights reserved.
//

import UIKit

class NumbersTableViewCell: UITableViewCell {

	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.imageView!.image = UIImage(named: "empty")
	}
}
