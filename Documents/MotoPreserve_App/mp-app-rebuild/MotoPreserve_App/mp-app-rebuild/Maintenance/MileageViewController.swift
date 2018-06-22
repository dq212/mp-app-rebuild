//
//  MileageViewController.swift
//  MotoPreserve-App
//
//  Created by DANIEL I QUINTERO on 12/27/17.
//  Copyright © 2017 DANIEL I QUINTERO. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

protocol MileageViewControllerDelegate: class {
    func mileageViewControllerDidCancel(_ controller: MileageViewController)
    //func mileageViewController(_ controller:MileageViewController, didFinishAdding item: FB_TaskItem)
    func mileageViewControllerDidFinishEditing(_ controller: MileageViewController)
}

class MileageViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var bike:FB_Bike!
//    var taskToEdit: FB_MaintenanceItem?
    var selectedIndexPath:IndexPath!
    var maintenanceIndexPath:IndexPath?
    var observer: Any!
    
    var valueType:String = "Miles"
    var currentMileage:String?
    var currentHours:String?
    
    var dueDate:NSNumber?
    var stackView:UIStackView?
    var stackViewDate:UIStackView?
    var reminderDate:NSNumber?
    
    var buttonRow:Int?
    
    let dottedLineView1 = UIView()
    let dottedLineView2 = UIView()
    
    var bikes:[FB_Bike] = BikeData.sharedInstance.allBikes
    
    weak var delegate: MileageViewControllerDelegate?
    
    let hoursMilesLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Hours/Miles"
        return label
    }()
    
    let milesHoursToggleSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.tintColor = .mainRed()
        s.onTintColor = .mainRed()
        return s
    }()
    
    let milesHoursSegmentedControl: UISegmentedControl = {
        let items = ["Hours","Miles"]
        let sc = UISegmentedControl(items: items)
        sc.backgroundColor = UIColor.white
        sc.tintColor = UIColor.mainRed()
        
        sc.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControlState.normal)
        sc.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControlState.highlighted)
        sc.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControlState.focused)
        sc.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 12)!], for: UIControlState.disabled)

        return sc
    }()
    
    let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .veryLightGray()
        return view
    }()
    
    let middleDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let bottomDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let mileageTextField:UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.font = UIFont(name: "Avenir", size:14)
        tf.textColor = UIColor.darkGray
        tf.borderStyle = .roundedRect
        tf.layer.masksToBounds = true
        tf.attributedPlaceholder = NSAttributedString(string: "Enter Current Mileage", attributes: [NSAttributedStringKey.foregroundColor: UIColor.veryLightGray()])
        tf.text = ""
        tf.keyboardAppearance = .dark
        tf.keyboardType = .numberPad
        return tf
    }()
    
    let mileageTextView:UITextView = {
        let tv = UITextView()
        tv.textAlignment = .left
        tv.font = UIFont(name: "Avenir", size:14)
        tv.textColor = UIColor.black
        tv.isEditable = false
        tv.text = "Enter your mileage here.\n\nYou can set reminders to do particular maintenance based on past mileage entries, so you can always stay on top of things like oil changes, tune-ups, tire cable lubrication, etc..."
        return tv
    }()
    //
    let setReminderLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    let currentMileageLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 11)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.text = "current mileage".uppercased()
        return label
    }()
    
    let remindLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size:12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "set a reminder".uppercased()
        return label
    }()
    
    let dueDateLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir", size: 12)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.text = "Due date".uppercased()
        return label
    }()
    
    let shouldRemindSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        s.tintColor = .mainRed()
        s.onTintColor = .mainRed()
        return s
    }()
    
    let toolBar:UIToolbar = {
        let t = UIToolbar()
        t.backgroundColor = .veryLightGray()
        return t
    }()
    
    var titleBar:TitleBar = TitleBar()
    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    
    //var taskToEdit: FB_MaintenanceItem?
   // var delegate: MaintenanceDetailViewControllerDelegate?
    var selectedCategory: String = "Misc."
    var selectedNumber: String = "500"
    var selectedInt = 0
    var selectedNumInt = 0
    
    var numValues = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if bike.selectedValue == "Miles" {
            milesHoursSegmentedControl.selectedSegmentIndex = 1

            self.mileageTextField.text = bike.currentMileageString
        } else {
            milesHoursSegmentedControl.selectedSegmentIndex = 0

            self.mileageTextField.text = bike.currentHoursString
        }
        print("\(self.bike) + this is the bike that is passed over.")
        //BikeData.sharedInstance.bike = self.bike
        //BikeData.sharedInstance.allBikes = self.bikes
        if bike.selectedValue == "Miles" && bike.currentMileageString != nil {
            self.mileageTextField.text = bike.currentMileageString
        } else if bike.selectedValue == "Hours" && bike.currentHoursString != nil{
            self.mileageTextField.text = bike.currentHoursString
        }
        
        view.backgroundColor = .white
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        doneBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.normal)
        doneBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.disabled)
        doneBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.focused)
        doneBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.highlighted)

        
        doneBarButton?.isEnabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.normal)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.highlighted)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.disabled)
        cancelBarButton?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.focused)

        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        doneBarButton?.tintColor = .mainRed();
        cancelBarButton?.tintColor = .mainRed()
        titleBar.addTitleBarAndLabel(page: view, initialTitle:"Enter Mileage", ypos: 0, color:.mainRed())
        
        view.addSubview(mileageTextView)
        view.addSubview(mileageTextField)
        
        milesHoursSegmentedControl.addTarget(self, action: #selector(toggleMilesHours), for: .valueChanged)
        
       
       
        
        navigationItem.leftBarButtonItem?.tintColor = .mainRed()
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.disabled)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.highlighted)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.focused)

        
        
    
        view.addSubview(dottedLineView1)
        view.addSubview(dottedLineView2)
        view.addSubview(self.currentMileageLabel)
        view.addSubview(milesHoursSegmentedControl)
        view.addSubview(hoursMilesLabel)
        view.addSubview(mileageTextField)
        
        
        
       
        mileageTextField.returnKeyType = .done
        self.mileageTextField.delegate = self
        self.mileageTextField.addTarget(self, action: #selector(didStartEditing), for: .editingDidBegin)
        self.mileageTextField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        self.mileageTextField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEnd)
        
        self.mileageTextView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 120)
        
         self.dottedLineView1.anchor(top: mileageTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        
//        self.topDividerView.anchor(top: mileageTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        
        self.milesHoursSegmentedControl.anchor(top: dottedLineView1.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        self.currentMileageLabel.anchor(top: milesHoursSegmentedControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop:15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        self.mileageTextField.anchor(top: milesHoursSegmentedControl.bottomAnchor, left: currentMileageLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 200, height: 25 )
        
         self.dottedLineView2.anchor(top: mileageTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 0.5)
        

        
        shouldRemindSwitch.addTarget(self, action: #selector(switchChanged(_ :)), for: .valueChanged)
        
        let toolBar = UIToolbar()
        let barDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        barDoneButton.tintColor = .mainRed()
        barDoneButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.normal)
        barDoneButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.disabled)
        barDoneButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.focused)
        barDoneButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 18)!], for: UIControlState.highlighted)

        toolBar.setItems([flexibleSpace, barDoneButton], animated: true)
        toolBar.sizeToFit()
        mileageTextField.inputAccessoryView = toolBar
        
        drawDottedLines()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.numValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
            selectedNumber = numValues[row]
            selectedNumInt = row
            numberChanged(row: row)
//            doneBarButton?.isEnabled = true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numValues.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func switchChanged(_ switch: UISwitch) -> Bool {
        setReminderLabel.isHidden = !shouldRemindSwitch.isOn
        toggleMilesHours(sender: milesHoursSegmentedControl)
        return setReminderLabel.isHidden
    }
    
    func drawDottedLines() {
        //layer dashed line
        let layer1 = dottedLineView1.layer
        let layer2 = dottedLineView2.layer
        
        let lineDashPatterns: [[NSNumber]?]  = [[3,5]]
        for (index, lineDashPattern) in lineDashPatterns.enumerated() {
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = UIColor.veryLightGray().cgColor
            shapeLayer.lineWidth = 0.5
            shapeLayer.lineDashPattern = lineDashPattern
            
            let path = CGMutablePath()
            let y = CGFloat(index * 50)
            path.addLines(between: [CGPoint(x: 0, y: y), CGPoint(x: 640, y: y)])
            
            let shapeLayer2 = CAShapeLayer()
            shapeLayer2.strokeColor = UIColor.veryLightGray().cgColor
            shapeLayer2.lineWidth = 0.5
            shapeLayer2.lineDashPattern = lineDashPattern
            
            let path2 = CGMutablePath()
            let y2 = CGFloat(index * 50)
            path2.addLines(between: [CGPoint(x: 0, y: y2), CGPoint(x: 640, y: y2)])
            shapeLayer.path = path
            shapeLayer2.path = path2
            layer1.addSublayer(shapeLayer)
            layer2.addSublayer(shapeLayer2)
        }
    }
    
     @objc func done() {
        delegate?.mileageViewControllerDidFinishEditing(self)
    }
    
    @objc func toggleMilesHours(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            self.valueType = "Miles"
            self.selectedNumber = "100"
//            taskToEdit?.reminderNumber = 100
            mileageTextField.attributedPlaceholder = NSAttributedString(string: "Enter Current \(self.valueType)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.veryLightGray()])
//
            currentMileageLabel.text = "current mileage:".uppercased()
            
            updateNumberLabel()
            
            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
            if bike.currentMileageString == nil {
                mileageTextField.text = "0"
            } else {
                mileageTextField.text = bike.currentMileageString
            }
            
        default:
            self.valueType = "Hours"
            self.selectedNumber = "1"
//            taskToEdit?.reminderNumber = 1
            mileageTextField.attributedPlaceholder = NSAttributedString(string:  "Enter Current \(self.valueType)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.veryLightGray()])
//
            currentMileageLabel.text = "current hours:".uppercased()
            
            updateNumberLabel()
            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
            if bike.currentHoursString == nil {
                mileageTextField.text = "0"
            } else {
                mileageTextField.text = bike.currentHoursString
            }
        }
    }
    
    func getSelectedNumber(item: FB_MaintenanceItem, currentString:String) -> Int {
        if item.reminderNumber != nil {
//            print("the number I changed to \(item.reminderNumber)")
            for i in 0..<numValues.count {
                if String(describing: item.reminderNumber!) == numValues[i] {
                    return i
                }
            }
        }
        return 0
    }
    
    @objc func cancel() {
        print("cancelling")
        delegate?.mileageViewControllerDidCancel(self)
    }
    
    @objc func didStartEditing(textField:UITextField) {
        doneBarButton?.isEnabled = false
    }
    
    @objc func didChangeText(textField:UITextField) {
        let newText = self.mileageTextField.text! as NSString
        //doneBarButton?.isEnabled = ((newText.length) > 0)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //nameTextField.resignFirstResponder()
        doneBarButton?.isEnabled = true
        self.view.endEditing(true)
        return true
    }
    
    @objc func numberChanged(row: Int) {
        print("what is the new number?")
        self.updateNumberLabel()
    }
    
    func updateNumberLabel() {
            self.setReminderLabel.text = "Set for: \(self.selectedNumber) \(self.valueType)"
    }
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        _ = (keyboardFrame.height+50) * (show ? 1 : -1)
        //view.contentInset.bottom += adjustmentHeight
        //view.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    @objc func doneClicked(){
        print("done clicked")
       
        if valueType == "Miles" {
            bike.currentMileageString = mileageTextField.text!
        } else {
            bike.currentHoursString = mileageTextField.text!
        }
        bikes = []
        let savedBikes = loadUserBikes()
        bikes = savedBikes!
        bike.selectedValue = self.valueType
        print("what is the selected index path \(self.selectedIndexPath)")
        bikes[(self.buttonRow)!] = bike
            saveBikes()
            view.endEditing(true)
    }

    private func loadUserBikes() -> [FB_Bike]?  {
        //self.checkCoachMark()
        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
    }

    private func saveBikes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.bikes, toFile: FB_Bike.ArchiveURL.path)
        if isSuccessfulSave {
            print("successfully saved")
        } else {
            print("un-successfully saved")
        }
    }
    
    //Due Date
    func updateDueDateLabel() {
        //        let formatter = DateFormatter()
        //        formatter.dateStyle = .short
        //        formatter.timeStyle = .short
        let date = NSDate(timeIntervalSince1970: TimeInterval(truncating: self.reminderDate!)) as Date
        self.reminderDate = date.timeIntervalSince1970 as NSNumber
        setReminderLabel.text = date.toString(dateFormat: "MMM d, h:mm a")
    }
    
    //MARK: - Notification
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidEnterBackground,
            object: nil, queue: OperationQueue.main) {
                [weak self] _ in
                if let strongSelf = self {
                    if strongSelf.presentedViewController != nil {
                        strongSelf.dismiss(animated: false, completion: nil)
                    }
                    //strongSelf.notesTextView.resignFirstResponder()
                }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    private func loadUserBikes() -> [FB_Bike]?  {
//        //self.checkCoachMark()
//        return NSKeyedUnarchiver.unarchiveObject(withFile: FB_Bike.ArchiveURL.path) as? [FB_Bike]
//    }
//    
//    private func saveBikes() {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikes, toFile: FB_Bike.ArchiveURL.path)
//        if isSuccessfulSave {
//            print("successfully saved")
//        } else {
//            print("un-successfully saved")
//        }
//    }
    

        //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //
        //        if textField == mileageTextField {
        //            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        //            let compSepByCharInSet = string.components(separatedBy: aSet)
        //            let numberFiltered = compSepByCharInSet.joined(separator: "")
        //            return string == numberFiltered
        //        }
        //
        //        return true
        //    }
    //
}
