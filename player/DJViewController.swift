//
//  DJViewController.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/11.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import UIKit
import SwiftyJSON

class DJViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource {

  var dj_path = ""
  var dj = DJ()

  var profileImageURL: NSURL? {
    didSet {
      if profileImageURL != nil {
        fetch(dataFrom: profileImageURL!) { r in
          self.profileImage.image = UIImage(data: r)
        }
      }
    }
  }

  var showsBySemester : [DJShowsGroup] = [] {
    didSet {
      tableView.reloadData()
      resizeTableView()
    }
  }

  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var djBio: UITextView!

  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let guide = view.readableContentGuide
    djBio.translatesAutoresizingMaskIntoConstraints = false
    guide.leftAnchor.constraintEqualToAnchor(djBio.leftAnchor).active = true
    guide.rightAnchor.constraintEqualToAnchor(djBio.rightAnchor).active = true

    tableView.scrollEnabled = false
    tableView.backgroundColor = UIColor.clearColor()

    fetchDJProfile()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    let bar = self.navigationController?.navigationBar
    bar?.translucent = false
    bar?.barTintColor = UIColor(rgba: "#EBEBF1FF")
    bar?.tintColor = UIColor.blackColor()
    bar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Lato-Black", size: 17)!,
      NSForegroundColorAttributeName: UIColor.blackColor()
    ]
    if let navController = self.navigationController as? LightStatusBarNavigationController {
      navController.light = false
    }
  }

  override func viewDidLayoutSubviews() {
    djBio.setContentOffset(CGPointZero, animated: false)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

  struct DJShowsGroup {
    let showName: String
    let semesters: [DJShowsRow]
  }

  struct DJShowsRow {
    let show: Show
    let semesterStart: NSDate

    var semesterName: String { get {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyyMMMM", options: 0, locale: NSLocale.currentLocale())
      return dateFormatter.stringFromDate(semesterStart)
    } }
  }

  private func fetchDJProfile() {
    let background_qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(background_qos, 0)) {
      let playlist_api_url = NSURL( string: "http://app.wcbn.org\(self.dj_path).json")!
      if let data = NSData(contentsOfURL: playlist_api_url) {
        dispatch_async(dispatch_get_main_queue()) {
          let json = JSON(data: data)

          let dj = self.dj
          dj.id = json["id"].intValue
          self.profileImageURL = json["image_url"].URL
          dj.dj_name = json["dj_name"].stringValue
          dj.real_name = json["real_name"].string
          dj.website = NSURL(string: json["website"].stringValue)
          dj.about = json["about"].stringValue
          self.djBio.attributedText = NSAttributedString(string: dj.about, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 14)!])

          self.showsBySemester = json["shows"].arrayValue.map { show in
            let showName = show["name"].stringValue
            let semesters = show["semesters"].arrayValue.map { semester in
              return DJShowsRow(show: Show(fromJSON: semester),
                        semesterStart: semester["semester_beginning"].dateTime!)
            }
            return DJShowsGroup(showName: showName, semesters: semesters)
          }
        }
      }
    }
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return showsBySemester.count
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return showsBySemester[section].semesters.count
  }

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return showsBySemester[section].showName
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ShowBySemesterCell", forIndexPath: indexPath)
    let row = showsBySemester[indexPath.section].semesters[indexPath.row]

    cell.textLabel?.text = row.semesterName
    cell.detailTextLabel?.text = row.show.timesWithWeekday

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let showVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowDetails") as! ShowDetailViewController
    let row = showsBySemester[indexPath.section].semesters[indexPath.row]
    showVC.show = row.show
    showVC.title = row.show.name

    let back = UIBarButtonItem()
    back.title = dj.dj_name
    self.navigationItem.backBarButtonItem = back

    self.navigationController?.pushViewController(showVC, animated: true)
  }

  func resizeTableView() {
    tableView.layoutIfNeeded()
    let size = tableView.contentSize
    tableView.heightAnchor.constraintEqualToConstant(size.height).active = true
  }
}
