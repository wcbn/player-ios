//
//  TipJarTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 8/20/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit
import StoreKit

class TipJarTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

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
    "org.wcbn.smallTip",
    "org.wcbn.mediumTip",
    "org.wcbn.largeTip"
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
    if section == 1 {
      return 1
    }
    return products.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Setting", forIndexPath: indexPath)

    if indexPath.section == 1 {
      cell.textLabel?.text = "Make a tax-exempt gift of any amount"
      cell.detailTextLabel?.text = ""
    } else {
      let product = products[indexPath.row]
      cell.textLabel?.text = products[indexPath.row].localizedTitle

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

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 {
      let giftURL = NSURL(string: "https://leadersandbest.umich.edu/find/#!/give/basket/fund/361991")
      UIApplication.sharedApplication().openURL(giftURL!)
      deselectSelectedRow()
    } else {
        let alert = UIAlertController(title: "Payments disabled in Beta", message: "Thanks for your diligent testing, though!", preferredStyle: .Alert)
        let dismiss = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(dismiss)
        presentViewController(alert, animated: true, completion: deselectSelectedRow)
//      let payment = SKPayment(product: products[indexPath.row])
//      SKPaymentQueue.defaultQueue().addPayment(payment)
    }
  }

  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .Purchased:
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        let alert = UIAlertController(title: "Payment Succeeded", message: transaction.transactionIdentifier, preferredStyle: .Alert)
        let dismiss = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(dismiss)
        presentViewController(alert, animated: true, completion: deselectSelectedRow)
      case .Failed:
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        let alert = UIAlertController(title: "Payment Failed", message: transaction.error?.localizedFailureReason, preferredStyle: .Alert)
        let dismiss = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(dismiss)
        presentViewController(alert, animated: true, completion: deselectSelectedRow)
      default:
        break
      }
    }
  }

  func deselectSelectedRow() {
    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRowAtIndexPath(selected, animated: true)
    }
  }
}