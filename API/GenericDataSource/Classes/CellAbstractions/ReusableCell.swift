//
//  ReusableCell.swift
//  GenericDataSource
//
//  Created by Ashish on 20/11/18..
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit

public protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

public extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
