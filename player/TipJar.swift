//
//  TipJar.swift
//  player
//
//  Created by Cameron Bothner on 8/20/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import Foundation
import StoreKit

class TipJarTableViewController: UITableViewController, SKProductsRequestDelegate {
  var products: [SKProduct] = []

  override init() {
    super.init()
    var request = SKProductsRequest(productIdentifiers: tipNames)
    request.delegate = self
    request.start()
  }

  static var tipNames = Set([
    "org.wcbn.smallTip",
    "org.wcbn.mediumTip",
    "org.wcbn.largeTip"
  ])

  var tipSettings: [SettingsTableViewController.Setting] {
    get {
      return products.map { product in
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatterBehavior = .Behavior10_4
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = product.priceLocale

        return SettingsTableViewController.Setting(
          key: product.productIdentifier,
          message: product.localizedTitle,
          description: numberFormatter.stringFromNumber(product.price))
      }
    }
  }

  @objc func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    products = response.products
  }
}