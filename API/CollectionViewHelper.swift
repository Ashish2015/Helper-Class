//
//  CollectionViewHelper.swift
//  DexGreen
//
//  Created by Ashish Prajapati on 13/04/19.
//  Copyright © 2019 indianic. All rights reserved.
//

import Foundation

class CategoriesViewController {
    
    
    
}


extension CategoriesViewController : UICollectionViewDelegate {}

// MARK: - Data Source
class CategoryDataSource: CollectionArrayDataSource<Category, CategoryCell> {
    
}


// MARK: - Private Methods
fileprivate extension CategoriesViewController {
    func setUpDataSource() -> CategoryDataSource? {
        let dataSource = CategoryDataSource(collectionView: cvCategoryList, array: arrCategory)
        dataSource.collectionItemSelectionHandler = { [weak self] indexPath in
            guard let strongSelf = self else {
                return
            }
            
            let cell = strongSelf.cvCategoryList.cellForItem(at: indexPath) as? CategoryCell
            cell?.layer.borderColor = UIColor.gray.cgColor
            strongSelf.selectedIndexPath = indexPath
            strongSelf.performSegue(withIdentifier: SegueIdentifiers.showProduct.rawValue, sender: nil)
            cell?.layer.borderColor = UIColor.clear.cgColor
            
            Analytics.logEvent(FirebaseAnalytics.Event.product_category_selection, parameters: [
                FirebaseAnalytics.Parameter.selectedProductcategory:cell?.lblDesc.text ?? "",
                FirebaseAnalytics.Parameter.user_email: appDelegateSharedInstance.userInfo?.user?.email ?? K.Guest,
                FirebaseAnalytics.Parameter.user_name: appDelegateSharedInstance.userInfo?.user?.userName ?? K.Guest])
        }
        return dataSource
    }
}
