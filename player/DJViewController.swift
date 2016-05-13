//
//  DJViewController.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/11.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import UIKit
import SwiftyJSON

class DJViewController: UIViewController {

  var dj_path = ""
  var dj = DJ()

  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var djBio: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let bar = self.navigationController?.navigationBar
    bar?.translucent = false
    bar?.barTintColor = Colors.Dark.white
    bar?.tintColor = UIColor.blackColor()
    bar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Lato-Black", size: 17)!,
      NSForegroundColorAttributeName: UIColor.blackColor()
    ]
    if let navController = self.navigationController as? LightStatusBarNavigationController {
      navController.light = false
    }

    let layer = profileImage.layer
    layer.cornerRadius = profileImage.bounds.width / 2
    layer.masksToBounds = true;
    layer.borderColor = UIColor.whiteColor().CGColor
    layer.borderWidth = 2.0

    fetchDJProfile()
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

  private func fetchDJProfile() {
    let background_qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(background_qos, 0)) {
      let playlist_api_url = NSURL( string: "http://app.wcbn.org\(self.dj_path).json")!
      if let data = NSData(contentsOfURL: playlist_api_url) {
        dispatch_async(dispatch_get_main_queue()) {
          let json = JSON(data: data)

          let dj = self.dj
          dj.id = json["id"].intValue
          dj.dj_name = json["dj_name"].stringValue
          dj.real_name = json["real_name"].string
          dj.website = NSURL(string: json["website"].stringValue)
          dj.about = json["about"].stringValue
          self.djBio.attributedText = NSAttributedString(string: dj.about, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 14)!])
        }
      }
    }
  }
}
