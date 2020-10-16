//
//  DateFormatter+Extension.swift
//  Empat
//
//  Created by Богдан Воробйовський on 15.10.2020.
//

import Foundation

extension DateFormatter {

    func getStringDate(date: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
