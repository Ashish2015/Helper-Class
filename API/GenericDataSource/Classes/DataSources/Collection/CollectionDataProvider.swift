//
//  CollectionDataProvider.swift
//  GenericDataSource
//
//  Created by Ashish on 20/11/18..
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit

public protocol CollectionDataProvider {
    associatedtype T

    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> T?

    func updateItem(at indexPath: IndexPath, value: T)
}
