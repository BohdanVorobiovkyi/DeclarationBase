//
//  ResultTableCell.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit

protocol PDFSelected: class {
    func openWebVC(with url: URL)
}

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var workPlaceLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    weak var delegate: PDFSelected?
    
    private var link: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pdfButton.isHidden = true
        pdfButton.addTarget(self, action: #selector(openURL(_:)), for: .touchUpInside)
        commentLabel.text = ""
//        commentLabel.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(model: Item) {

        if let name = model.firstname, let lastName = model.lastname {
        let nameString = NSMutableAttributedString().normal("\(lastName) \(name) ")
        fullNameLabel.attributedText = nameString
    }
        if let place = model.placeOfWork {
        let workPlaceString = NSMutableAttributedString().bold("Місце роботи: ").normal(place)
            workPlaceLabel.attributedText = workPlaceString
        }
        if let position = model.position {
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
        
        print("PDF button pressed with link \(link)")
        guard let stringLink = link , let url = URL(string: stringLink) else {return}
        delegate?.openWebVC(with: url)
//        UIApplication.shared.open(url)
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
