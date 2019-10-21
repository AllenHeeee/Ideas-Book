//
//  TextTableViewCell.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/9.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
protocol CustomCellUpdater: class { // the name of the protocol you can put any
    func updateTableView()
}
class TextTableViewCell: UITableViewCell {
    weak var delegate: CustomCellUpdater?
    
    func yourFunctionWhichDoesNotHaveASender () {
            delegate?.updateTableView()
    }
    
    var indexpathRow:Int?;
    var alreadyReadMore = false;
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func readMoreTapped(_ sender: Any) {
        Helper.textShowMore[indexpathRow!] = true;
        yourFunctionWhichDoesNotHaveASender();
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func showMore(){
        alreadyReadMore = true;
        self.label.numberOfLines = 0;
        readMoreButton.alpha = 0;
        readMoreButton.isEnabled = false;
    }
    func showLess(){
        alreadyReadMore = false;
        self.label.numberOfLines = 7;
        readMoreButton.alpha = 1;
        readMoreButton.isEnabled = true;
    }
    
}
