//
//  StoreProduct.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import StoreKit

struct StoreProduct: Identifiable {

    let id = UUID()
    let product: Product?
    let shopItem: ShopItem
}
