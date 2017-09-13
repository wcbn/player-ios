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

class TipJarTableViewController: UITableViewController {

  let products = TipJar.sharedInstance.products

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 1000;
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 || products == [] {
      return 1
    }
    return products.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Setting", for: indexPath)

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

      let numberFormatter = NumberFormatter()
      numberFormatter.formatterBehavior = .behavior10_4
      numberFormatter.numberStyle = .currency
      numberFormatter.locale = product.priceLocale
      cell.detailTextLabel?.text = numberFormatter.string(from: product.price)
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 { return "The Tip Jar" }
    return nil
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let label = labelForFooter(section)
    let v = UIView()
    v.preservesSuperviewLayoutMargins = true
    v.addSubview(label)

    label.topAnchor.constraint(equalTo: v.topAnchor, constant: 8).isActive = true
    label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: 0).isActive = true

    let guide = v.readableContentGuide
    label.translatesAutoresizingMaskIntoConstraints = false
    guide.leftAnchor.constraint(equalTo: label.leftAnchor).isActive = true
    guide.rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true

    return v
  }

  func labelForFooter(_ section: Int) -> UILabel {
    let label = UILabel()
    if section == 0 {
      label.text = "Thank you for your support. These one-time gifts will let the DJ know how much you appreciate them.\n"
    } else {
      label.text = "You may give any amount, and claim the donation as tax-exempt, by donating through the giving portal of the University of Michigan, a registered 501(c)(3) non-profit.\n\n"
    }
    if tableView.numberOfRows(inSection: section) > 0 {
      label.font = UIFont(name: "Lato-Regular", size: 14)
      label.textColor = UIColor.gray
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

  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return !(indexPath.section == 0 && products == [])
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 {
      let giftURL = URL(string: "https://leadersandbest.umich.edu/find/#!/give/basket/fund/361991")
      UIApplication.shared.openURL(giftURL!)
    } else if products != [] {
      let payment = SKPayment(product: products[indexPath.row])
      SKPaymentQueue.default().add(payment)
    }
    deselectSelectedRow()
  }

  func deselectSelectedRow() {
    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: selected, animated: true)
    }
  }
}
