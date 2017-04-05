//
//  ThemeViewController.swift
//  Days Pro
//
//  Created by Oliver Kulpakko on 2017-03-28.
//  Copyright © 2017 Oliver Kulpakko. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var lightBlueButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var restartNoticeLabel: UILabel!
    @IBOutlet weak var themeColorLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    var themeChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = hexStringToUIColor(hex: UserDefaults.standard.string(forKey: "backgroundColor")!)
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkMode")
        if UserDefaults.standard.bool(forKey: "darkMode") {
            themeColorLabel.textColor = UIColor.lightText
            restartNoticeLabel.textColor = UIColor.lightText
            darkModeLabel.textColor = UIColor.lightText
        } else {
            themeColorLabel.textColor = UIColor.darkText
            restartNoticeLabel.textColor = UIColor.darkText
            darkModeLabel.textColor = UIColor.darkText
        }
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeColor(_ sender: Any) {
        themeChanged = true
        switch sender as! UIButton {
        case redButton:
            UserDefaults.standard.set("FF3B30", forKey: "themeColor")
        case orangeButton:
            UserDefaults.standard.set("FF9500", forKey: "themeColor")
        case yellowButton:
            UserDefaults.standard.set("FFCC00", forKey: "themeColor")
        case greenButton:
            UserDefaults.standard.set("4CD964", forKey: "themeColor")
        case lightBlueButton:
            UserDefaults.standard.set("5AC8FA", forKey: "themeColor")
        case blueButton:
            UserDefaults.standard.set("007AFF", forKey: "themeColor")
        case purpleButton:
            UserDefaults.standard.set("5856D6", forKey: "themeColor")
        case pinkButton:
            UserDefaults.standard.set("FF2D55", forKey: "themeColor")
        default:
            UserDefaults.standard.set("FF9500", forKey: "themeColor")
        }
    }
    
    @IBAction func darkModeSwitched(_ sender: Any) {
        themeChanged = true
        if (sender as! UISwitch).isOn {
            UserDefaults.standard.set("202020", forKey: "backgroundColor")
            UserDefaults.standard.set("522A27", forKey: "circleBackgroundColor")
            UserDefaults.standard.set(true, forKey: "darkMode")
            if #available(iOS 10.3, *) {
                if UIApplication.shared.supportsAlternateIcons {
                    UIApplication.shared.setAlternateIconName(nil)
                }
            }
        } else {
            UserDefaults.standard.set("EBEBF1", forKey: "backgroundColor")
            UserDefaults.standard.set("BDC3C7", forKey: "circleBackgroundColor")
            UserDefaults.standard.set(false, forKey: "darkMode")
            if #available(iOS 10.3, *) {
                if UIApplication.shared.supportsAlternateIcons {
                    UIApplication.shared.setAlternateIconName("light")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if themeChanged {
            let alertController = UIAlertController(title: restartNoticeLabel.text, message: "", preferredStyle: .alert)
            let relaunchAction = UIAlertAction(title: NSLocalizedString("Relaunch", comment: ""), style: .cancel) { action in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                exit(0)
            }
            alertController.addAction(relaunchAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
        }
    }
}
