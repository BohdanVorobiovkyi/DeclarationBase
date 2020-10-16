//
//  ResultTableCell.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var workPlaceLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(model: Item) {
        print(model)
        
        let nameString = NSMutableAttributedString().normal("\(model.lastname) \(model.firstname) ")
        let workPlaceString = NSMutableAttributedString().bold("Місце роботи: ").normal(model.placeOfWork)
        if let position = model.position {
            positionLabel.attributedText = NSMutableAttributedString().bold("Позиція: ").normal(position)
        }
        fullNameLabel.attributedText = nameString
        workPlaceLabel.attributedText = workPlaceString
    }
    
    override func prepareForReuse() {
        fullNameLabel.text = ""
        positionLabel.text = ""
        workPlaceLabel.text = ""
    }

}
