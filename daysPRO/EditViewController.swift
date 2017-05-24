//
//  EditViewController.swift
//  Days Pro
//
//  Created by Oliver Kulpakko on 2017-05-24.
//  Copyright © 2017 Oliver Kulpakko. All rights reserved.
//

import UIKit
import SVProgressHUD
import ImagePicker

class EditViewController: UIViewController, ImagePickerDelegate {
    var event: Event?
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTimeSwitch: UISegmentedControl!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageViewButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        if let currentEvent = self.event {
            self.datePicker.date = currentEvent.date()
            self.timePicker.date = self.time(date: currentEvent.date())
            
            self.nameTextField.text = currentEvent.name
            self.descriptionTextField.text = currentEvent.details
            self.title = currentEvent.name
            
            self.imageView.image = currentEvent.image()
        }
    }
    
    @IBAction func changeBetweenDateAndTime(_ sender: Any) {
        self.datePicker.isHidden = !self.datePicker.isHidden
        self.timePicker.isHidden = !self.timePicker.isHidden
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        if self.nameTextField.text == nil {
            SVProgressHUD.showError(withStatus: NSLocalizedString("No Name", comment: ""))
            return
        }
        if (self.event != nil) {
            DataManager.shared().update(event, withName: nameTextField.text, date: self.combinedDate(), details: self.descriptionTextField.text, image: self.imageView.image)
            DataManager.shared().saveContext()
        } else {
            DataManager.shared().createEvent(withName: nameTextField.text, date: self.combinedDate(), details: self.descriptionTextField.text, image: self.imageView.image)
            DataManager.shared().saveContext()
        }
        self.cancel(sender)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func combinedDate() -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self.datePicker.date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self.timePicker.date)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
    
    func time(date: Date) -> Date {
        let calendar = Calendar.current

        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: date)
        dateComponents.minute = calendar.component(.minute, from: date)
        dateComponents.second = calendar.component(.second, from: date)

        return calendar.date(from: dateComponents)!
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.imageView.image = images.first
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.imageView.image = images.first
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
