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

  var profileImageURL: URL? {
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

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let guide = view.readableContentGuide
    djBio.translatesAutoresizingMaskIntoConstraints = false
    guide.leftAnchor.constraint(equalTo: djBio.leftAnchor).isActive = true
    guide.rightAnchor.constraint(equalTo: djBio.rightAnchor).isActive = true

    tableView.isScrollEnabled = false
    tableView.backgroundColor = UIColor.clear

    fetchDJProfile()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setTitleBarColor()
  }

  override func viewDidLayoutSubviews() {
    djBio.setContentOffset(CGPoint.zero, animated: false)
  }

  fileprivate func fetchDJProfile() {
    DispatchQueue.global(qos: .background).async {
      let playlist_api_url = URL( string: "http://app.wcbn.org\(self.dj_path).json")!
      if let data = try? Data(contentsOf: playlist_api_url) {
        DispatchQueue.main.async {
          guard let json = try? JSON(data: data) else { return }

          let dj = self.dj
          dj.id = json["id"].intValue
          self.profileImageURL = json["image_url"].url
          dj.dj_name = json["dj_name"].stringValue
          dj.real_name = json["real_name"].string
          dj.website = URL(string: json["website"].stringValue)
          dj.about = json["about"].stringValue

          if let formattedBio = MD.toAttributedString(
            dj.about, withBlackText: true
          ) {
            self.djBio.attributedText = formattedBio
          }

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

  func numberOfSections(in tableView: UITableView) -> Int {
    return showsBySemester.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return showsBySemester[section].semesters.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return showsBySemester[section].showName
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ShowBySemesterCell", for: indexPath)
    let row = showsBySemester[indexPath.section].semesters[indexPath.row]

    cell.textLabel?.text = row.semesterName
    cell.detailTextLabel?.text = row.show.timesWithWeekday

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let showVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowDetails") as! ShowDetailViewController
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
    tableView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
  }
}

// MARK: - Colored Title Bar
extension DJViewController: ColoredTitleBar {
  override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
  var titleBarColor: UIColor { return Colors.Light.black }
  var titleBarDark: Bool { return true }
}


struct DJShowsGroup {
  let showName: String
  let semesters: [DJShowsRow]
}

struct DJShowsRow {
  let show: Show
  let semesterStart: Date

  var semesterName: String { get {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMMM", options: 0, locale: Locale.current)
    return dateFormatter.string(from: semesterStart)
    } }
}
