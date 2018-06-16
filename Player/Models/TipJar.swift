//
//  TipJar.swift
//  player
//
//  Created by Cameron Bothner on 8/20/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyJSON

class TipJar: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

  static var sharedInstance = TipJar()

  var uid: String {
    get {
      let defaults = UserDefaults.standard
      if let savedUID = defaults.string(forKey: UserDefaultsKeys.uid) {
        return savedUID
      }
      let newUID = UIDevice.current.identifierForVendor!.uuidString
      defaults.set(newUID, forKey: UserDefaultsKeys.uid)
      return newUID
    }
  }

  override init() {
    super.init()

    let request = SKProductsRequest(productIdentifiers: TipJar.tipNames)
    request.delegate = self
    request.start()

    SKPaymentQueue.default().add(self)
  }

  // MARK: - SKProductRequestDelegate

  var products: [SKProduct] = []

  static var tipNames = Set([
    "org.wcbn.tip1",
    "org.wcbn.tip2",
    "org.wcbn.tip5"
  ])

  @objc func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    products = response.products.sorted { a, b in a.price.compare(b.price) == .orderedAscending }
  }

  // MARK: - SKProductsRequestDelegate

  @objc func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        SKPaymentQueue.default().finishTransaction(transaction)
        askForName(transaction)
      case .failed:
        SKPaymentQueue.default().finishTransaction(transaction)
      default:
        break
      }
    }
  }

  func askForName(_ transaction: SKPaymentTransaction) {
    let alert = UIAlertController(title: "Thank you!", message: "We’re so pleased you like what we’re doing. If you would like to let the DJ know who tipped, please give your name below.", preferredStyle: .alert)

    let anonymize = UIAlertAction(title: "Keep it anonymous", style: .cancel) { _ in
      self.recordDonation(transaction)
    }
    alert.addAction(anonymize)

    let shoutout = UIAlertAction(title: "Tell the DJ", style: .default) { _ in
      let nameField = alert.textFields![0]
      let messageField = alert.textFields![1]
      self.recordDonation(transaction, name: nameField.text, message: messageField.text)
    }
    shoutout.isEnabled = false
    alert.addAction(shoutout)

    alert.addTextField { textField in
      textField.autocapitalizationType = .words
      textField.autocorrectionType = .yes
      textField.placeholder = "Name"
      NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
        shoutout.isEnabled = textField.text != ""
      }
    }
    alert.addTextField { textField in
      textField.autocapitalizationType = .sentences
      textField.autocorrectionType = .yes
      textField.placeholder = "Message"
    }

    let delegate = UIApplication.shared.delegate as? AppDelegate
    let rVC = delegate?.window?.rootViewController
    rVC?.present(alert, animated: true, completion: nil)
  }

  func recordDonation(_ transaction: SKPaymentTransaction, name: String? = nil, message: String? = nil) {
    let receiptURL = Bundle.main.appStoreReceiptURL!
    guard let receipt = try? Data(contentsOf: receiptURL) else { return }
    let body: JSON = ["tip": [
      "receipt_data": receipt.base64EncodedString(options: .lineLength64Characters),
      "product_id": transaction.payment.productIdentifier,
      "uid": uid,
      "name": name ?? "",
      "message": message ?? ""]]
    let hdr = ["Content-Type": "application/json"]
    hit(URL(string: "https://app.wcbn.org/tips")!, containingBody: body, using: "POST", withHeaders: hdr) { _ in }
  }

}
