//
//  Item.swift
//  Empat
//
//  Created by Богдан Воробйовський on 15.10.2020.
//

import Foundation

struct SearchResult: Codable {
    let page: Page?
    let items: [Item]?
}

struct Item: Codable {
    let id: String
    let firstname, lastname, placeOfWork: String?
    let position: String?
    let linkPDF: String?
    let comment: String?
    let lastUpdate: Date? 
}

struct Page: Codable {
    let batchSize,currentPage: Int?
    let totalItems: String?
    
    
}
