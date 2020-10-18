//
//  ResultTableCell.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit

protocol PDFSelectedDelegate: class {
    func openWebVC(with url: URL)
}

protocol StarSelectedDelegate: class {
    func starSelected(item: Item)
}

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var workPlaceLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    
    @IBAction func selectFavAction(_ sender: Any) {
        if let savedItem = item {
        starDelegate?.starSelected(item: savedItem)
        }
    }
    
    weak var delegate: PDFSelectedDelegate?
    weak var starDelegate: StarSelectedDelegate?
    
    private var item: Item?
    private var link: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        positionLabel.text = ""
        pdfButton.isHidden = true
        pdfButton.addTarget(self, action: #selector(openURL(_:)), for: .touchUpInside)
        commentLabel.text = ""
//        commentLabel.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(model: Item) {
        self.item = model
        if let name = model.firstname, let lastName = model.lastname {
        let nameString = NSMutableAttributedString().normal("\(lastName) \(name) ")
        fullNameLabel.attributedText = nameString
    }
        if let place = model.placeOfWork {
        let workPlaceString = NSMutableAttributedString().bold("Місце роботи: ").normal(place)
            workPlaceLabel.attributedText = workPlaceString
        }
        if let position = model.position, position != ""{
            positionLabel.attributedText = NSMutableAttributedString().bold("Позиція: ").normal(position)
        }
        if let link = model.linkPDF, link != "" {
            self.link = link
            pdfButton.isHidden = false
            pdfButton.isUserInteractionEnabled = true
        }
        if let comment = model.comment, comment != "" {
            commentLabel.attributedText = NSMutableAttributedString().bold("Комментар: ").normal(comment)
        }
        
       
        
    }
    
    @objc private func openURL(_ sender: UIButton) {
        
        print("PDF button pressed with link \(String(describing: link))")
        guard let stringLink = link , let url = URL(string: stringLink) else {return}
        delegate?.openWebVC(with: url)
    }
    
    override func prepareForReuse() {
        fullNameLabel.text = ""
        positionLabel.text = ""
        workPlaceLabel.text = ""
        commentLabel.text = ""
        pdfButton.isHidden = true
        pdfButton.isUserInteractionEnabled = false
    }

}
