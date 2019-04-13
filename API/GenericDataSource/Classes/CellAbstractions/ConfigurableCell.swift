//
//  ConfigurableCell.swift
//  GenericDataSource
//
//  Created by Ashish on 20/11/18..
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit

public protocol ConfigurableCell: ReusableCell {
    associatedtype T

    func configure(_ item: T, at indexPath: IndexPath)
}
