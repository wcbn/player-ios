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
      let defaults = NSUserDefaults.standardUserDefaults()
      if let savedUID = defaults.stringForKey("UID") {
        return savedUID
      }
      let newUID = UIDevice.currentDevice().identifierForVendor!.UUIDString
      defaults.setObject(newUID, forKey: "UID")
      return newUID
    }
  }

  override init() {
    super.init()

    let request = SKProductsRequest(productIdentifiers: TipJar.tipNames)
    request.delegate = self
    request.start()

    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }

  // MARK: - SKProductRequestDelegate

  var products: [SKProduct] = []

  static var tipNames = Set([
    "org.wcbn.tip1",
    "org.wcbn.tip2",
    "org.wcbn.tip5"
  ])

  @objc func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    products = response.products.sort { a, b in a.price.compare(b.price) == .OrderedAscending }
  }

  // MARK: - SKProductsRequestDelegate

  @objc func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .Purchased:
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        askForName(transaction)
      case .Failed:
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
      default:
        break
      }
    }
  }

  func askForName(transaction: SKPaymentTransaction) {
    let alert = UIAlertController(title: "Thank you!", message: "We’re so pleased you like what we’re doing. If you would like to let the DJ know who tipped, please give your name below.", preferredStyle: .Alert)

    let anonymize = UIAlertAction(title: "Keep it anonymous", style: .Cancel) { _ in
      self.recordDonation(transaction)
    }
    alert.addAction(anonymize)

    let shoutout = UIAlertAction(title: "Tell the DJ", style: .Default) { _ in
      let nameField = alert.textFields![0]
      let messageField = alert.textFields![1]
      self.recordDonation(transaction, name: nameField.text, message: messageField.text)
    }
    shoutout.enabled = false
    alert.addAction(shoutout)

    alert.addTextFieldWithConfigurationHandler { textField in
      textField.autocapitalizationType = .Words
      textField.autocorrectionType = .Yes
      textField.placeholder = "Name"
      NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
        shoutout.enabled = textField.text != ""
      }
    }
    alert.addTextFieldWithConfigurationHandler { textField in
      textField.autocapitalizationType = .Sentences
      textField.autocorrectionType = .Yes
      textField.placeholder = "Message"
    }

    let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
    let rVC = delegate?.window?.rootViewController
    rVC?.presentViewController(alert, animated: true, completion: nil)
  }

  func recordDonation(transaction: SKPaymentTransaction, name: String? = nil, message: String? = nil) {
    let receiptURL = NSBundle.mainBundle().appStoreReceiptURL!
    guard let receipt = NSData(contentsOfURL: receiptURL) else { return }
    let body: JSON = ["tip": [
                        "receipt_data": receipt.base64EncodedStringWithOptions(.Encoding64CharacterLineLength),
                        "product_id": transaction.payment.productIdentifier,
                        "uid": uid,
                        "name": name ?? "",
                        "message": message ?? ""]]
    let hdr = ["Content-Type": "application/json"]
    hit(NSURL(string: "https://app.wcbn.org/tips")!, containingBody: body, withHeaders: hdr, using: "POST") { _ in }
  }

}