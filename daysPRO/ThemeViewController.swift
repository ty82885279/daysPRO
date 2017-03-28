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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func changeColor(_ sender: Any) {
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
        
        let alertController = UIAlertController(title: restartNoticeLabel.text, message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("Relaunch", comment: ""), style: .cancel) { action in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            exit(0)
        }
        alertController.addAction(cancel)
        self.present(alertController, animated: true)
    }
}
