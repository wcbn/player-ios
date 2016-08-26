//
//  TipJarTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 8/20/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyJSON

class TipJarTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

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

  override func viewDidLoad() {
    super.viewDidLoad()

    let request = SKProductsRequest(productIdentifiers: TipJarTableViewController.tipNames)
    request.delegate = self
    request.start()

    SKPaymentQueue.defaultQueue().addTransactionObserver(self)

    tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 1000;
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
    tableView.reloadData()
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 || products == [] {
      return 1
    }
    return products.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Setting", forIndexPath: indexPath)

    if indexPath.section == 1 {
      cell.textLabel?.text = "Make a tax-exempt gift of any amount"
      cell.detailTextLabel?.text = ""
    }
    else if products == [] {
      cell.textLabel?.text = "Loading..."
      cell.detailTextLabel?.text = ""
    } else {
      let product = products[indexPath.row]
      cell.textLabel?.text = products[indexPath.row].localizedDescription

      let numberFormatter = NSNumberFormatter()
      numberFormatter.formatterBehavior = .Behavior10_4
      numberFormatter.numberStyle = .CurrencyStyle
      numberFormatter.locale = product.priceLocale
      cell.detailTextLabel?.text = numberFormatter.stringFromNumber(product.price)
    }

    return cell
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 { return "The Tip Jar" }
    return nil
  }

  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let label = labelForFooter(section)
    let v = UIView()
    v.preservesSuperviewLayoutMargins = true
    v.addSubview(label)

    label.topAnchor.constraintEqualToAnchor(v.topAnchor, constant: 8).active = true
    label.bottomAnchor.constraintEqualToAnchor(v.bottomAnchor, constant: 0).active = true

    let guide = v.readableContentGuide
    label.translatesAutoresizingMaskIntoConstraints = false
    guide.leftAnchor.constraintEqualToAnchor(label.leftAnchor).active = true
    guide.rightAnchor.constraintEqualToAnchor(label.rightAnchor).active = true

    return v
  }

  func labelForFooter(section: Int) -> UILabel {
    let label = UILabel()
    if section == 0 {
      label.text = "Thank you for your support. These one-time gifts will let the DJ know how much you appreciate them.\n"
    } else {
      label.text = "You may give any amount, and claim the donation as tax-exempt, by donating through the giving portal of the University of Michigan, a registered 501(c)(3) non-profit.\n\n"
    }
    if tableView.numberOfRowsInSection(section) > 0 {
      label.font = UIFont(name: "Lato-Regular", size: 14)
      label.textColor = UIColor.grayColor()
    } else {
      label.font = UIFont(name: "Lato-Regular", size: 16)
    }
    label.allowsDefaultTighteningForTruncation = true
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.9
    label.numberOfLines = 0
    label.preservesSuperviewLayoutMargins = true
    return label
  }

  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return !(indexPath.section == 0 && products == [])
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 {
      let giftURL = NSURL(string: "https://leadersandbest.umich.edu/find/#!/give/basket/fund/361991")
      UIApplication.sharedApplication().openURL(giftURL!)
      deselectSelectedRow()
    } else if products != [] {
      let payment = SKPayment(product: products[indexPath.row])
      SKPaymentQueue.defaultQueue().addPayment(payment)
    }
  }

  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .Purchased:
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        askForName(transaction)
      case .Failed:
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        deselectSelectedRow()
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

    presentViewController(alert, animated: true, completion: deselectSelectedRow)
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

  func deselectSelectedRow() {
    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRowAtIndexPath(selected, animated: true)
    }
  }
}
