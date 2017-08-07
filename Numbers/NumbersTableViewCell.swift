//
//  NumbersTableViewCell.swift
//  Numbers http://github.com/apontious/Numbers
//
//  Created by Andrew Pontious on 7/30/17.
//  Copyright © 2017 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

import UIKit

class NumbersTableViewCell: UITableViewCell {

	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.imageView!.image = UIImage(named: "empty")
	}
}
