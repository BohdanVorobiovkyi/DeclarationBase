//
//  CollectionCell+Extension.swift
//  Empat
//
//  Created by Богдан Воробйовський on 15.10.2020.
//

import UIKit

extension UICollectionViewCell {
    func makeRound(view : UIView , cornerRadius : CGFloat , borderWidth : CGFloat , borderColor : UIColor){
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
    }
}

