//
//  EventViewController.swift
//  Days Pro
//
//  Created by Oliver Kulpakko on 2017-04-04.
//  Copyright © 2017 Oliver Kulpakko. All rights reserved.
//

import UIKit
import KDCircularProgress
@objc class EventViewController: UIViewController {
    var event: Event?
    var timer: Timer?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var progressView: KDCircularProgress!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let currentEvent = event {
            self.timer = Timer.scheduledTimer(timeInterval: 1 / 60, target: self, selector: #selector(self.setProgress), userInfo: nil, repeats: true)
            
            self.setProgress()
            self.view.backgroundColor = ThemeManager.getBackgroundColor()
            self.progressView.trackColor = ThemeManager.getThemeColor()
            self.progressView.progressColors = [ThemeManager.getCircleBackgroundColor()]
            
            if let imageView = self.imageView {
                imageView.image = currentEvent.image()
            }
            if let nameLabel = self.nameLabel {
                nameLabel.text = currentEvent.name
                nameLabel.textColor = UIColor.white
            }
            if let dateLabel = self.dateLabel {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                dateLabel.text = formatter.string(from: currentEvent.startDate)
                dateLabel.textColor = UIColor.white
            }
        }
    }
    
    func setProgress() {
        if let event = self.event {
            if let progressView = self.progressView {
                progressView.angle = Double(event.progress() * 360)
            }
        }
    }

    @IBAction func deleteEvent(_ sender: Any) {
        DataManager.shared().delete(self.event)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareEvent(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0)
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [self.event!.name, image!], applicationActivities: [])
        activityViewController.popoverPresentationController?.barButtonItem = shareButton
        self.present(activityViewController, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.timer?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editEvent" {
            let editViewController = ((segue.destination as? UINavigationController)?.topViewController as? EditViewController)
            editViewController?.event = self.event
            editViewController?.isEditing = true
        }
        
    }
    

}
