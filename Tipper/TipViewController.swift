//
//  TipViewController.swift
//  Tipper
//
//  Created by Yang Ruan on 9/28/15.
//  Copyright © 2015 Yang Ji. All rights reserved.
//

import UIKit

class TipViewController: UIViewController {
    
    var billAmount = 0.00
    var curTip = 0.15
    var numOfPeople = 1.00

    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var resultView: UIView!
    
    @IBOutlet weak var numPeopleTextField: UITextField!
    @IBOutlet weak var tipShowLabel: UILabel!
    @IBOutlet weak var tipControlValue: UISegmentedControl!
    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var eachPersonLabel: UILabel!
    
    //tip view attributes
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var tipfixeLabel: UILabel!
    @IBOutlet weak var numOfPeopleFixLabel: UILabel!
    
    //result attributes
    @IBOutlet weak var fixTipLabel: UILabel!
    @IBOutlet weak var fixTotalLabel: UILabel!
    @IBOutlet weak var fixEachPersonLabel: UILabel!
    
    
    //initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
    
    }
    
    deinit {
        // Remove the application life-cycle observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    func onApplicationDidBecomeActive() {
        // Get the date at which the application last became inactive
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let lastBillDate : NSDate = defaults.valueForKey("last_bill_date") as! NSDate
        let now : NSDate = NSDate()
        
        // Figure out how long it's been since the application became inactive last
        let interval : NSTimeInterval = now.timeIntervalSinceDate(lastBillDate)
        
        // If it's been less than 1 minutes, resume the last bill amount and tip percentage.
        // Otherwise, clear the bill amount field.
        if (interval < 10) {
            self.billAmountTextField.text = defaults.valueForKey("last_bill_amount") as? String
            self.tipControlValue.selectedSegmentIndex = defaults.valueForKey("last_tip_segment_index") as! Int
        } else {
            self.billAmountTextField.text = ""
        }
        
        // Update the values in the UI.
        updateValues()
        
        // Update the view to either input-only or results, based on the newly set bill value.
        updateViewWithAnimation()

    }
    
    func onApplicationWillResignActive() {
        // Save the current bill amount, tip percentage, and the current time.
        // If the user comes back to the app before 10 minutes, we restore these values.
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.billAmountTextField.text, forKey: "last_bill_date")
        defaults.setObject(NSDate(), forKey: "last_bill_date")
        defaults.setInteger(self.tipControlValue.selectedSegmentIndex, forKey: "last_tip_segment_index")
        defaults.synchronize()

    }
    
    @IBAction func changePeople(sender: UITextField) {
        //when change the people, update the values in the UI
        self.updateValues()
    }
    
    @IBAction func tipControl(sender: UISegmentedControl) {
        // When the segement changes, update the values in the UI
        var tipValues = [0.1, 0.15, 0.2]
        curTip = tipValues[tipControlValue.selectedSegmentIndex]
        //let showTip = Int(curTip * 100)
        tipShowLabel.text = "\(Int(curTip*100))%"
    
        //update amount
        self.updateValues()
    }
    
    @IBAction func tipMinusOnePercent(sender: UIButton) {
        //press minus sign to decrease the tip
        curTip -= 0.01
        tipShowLabel.text = "\(Int(curTip*100))%"
        
        //update amount
        self.updateValues()
    }
    
    @IBAction func tipPlusOnePercent(sender: UIButton) {
        //press minus sign to decrease the tip
        curTip += 0.01
        tipShowLabel.text = "\(Int(curTip*100))%"
        
        //update amount
        self.updateValues()
    }
    
    @IBAction func editBillAmountTextField(sender: UITextField) {
        
        // When the bill value changes, update the values in the UI
        self.updateValues()
        
        // Changing the bill value may cause a view animation. Bill value 0 shows
        // the input-only view, and bill value > 0 shows the results view.
        self.updateViewWithAnimation()
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tipView.hidden = true
        
        //create a setting button on the navigation right side
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "onSettingsButton")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 247/255, green: 0, blue: 148/255, alpha: 1)
        
        billAmountTextField.adjustsFontSizeToFitWidth = true
        tipLabel.adjustsFontSizeToFitWidth = true
        totalAmountLabel.adjustsFontSizeToFitWidth = true
        eachPersonLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let tipDefault = NSUserDefaults.standardUserDefaults()
        let defaultTipSegmentIndex = tipDefault.integerForKey("default_tip_segment_index")
        tipControlValue.selectedSegmentIndex = defaultTipSegmentIndex

        var tipValues = [0.1, 0.15, 0.2]
        curTip = tipValues[tipControlValue.selectedSegmentIndex]
        //let showTip = Int(curTip * 100)
        tipShowLabel.text = "\(Int(curTip*100))%"
        
        // Update values since the tip percentage may have changed
        updateValues()
        
        //check default color theme
        let defaultDark = NSUserDefaults.standardUserDefaults()
        if (defaultDark.boolForKey("Default_Dark_Setting")) {
            setDarkAttribute()
        } else {
            setLightAttribute()
        }
        
        // Put focus on the text field to make sure the keyboard shows
        billAmountTextField.becomeFirstResponder()
        
        updateViewWithAnimation()
        
        super.viewWillAppear(animated)
    }
    
    func updateValues() {
        
        //obtain the bill amount input
        if (billAmountTextField.text != nil){
            billAmount = (billAmountTextField.text! as NSString).doubleValue
            
        }

        
        //obtain the number of people
        if (numPeopleTextField != nil) {
            numOfPeople = (numPeopleTextField.text! as NSString).doubleValue
        }
        
        if (numOfPeople == 0.0) {
            numOfPeople = 1.0
        }
        
        //Calculate the amount
        let tips = curTip * billAmount
        let totalAmount = tips + billAmount
        let eachPerson = totalAmount / numOfPeople
        
        
        //display on UI
        
        // Use the user's locale to format the currency and set the tip and total labels
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle =  NSNumberFormatterStyle.CurrencyStyle
        
        self.tipLabel.text = numberFormatter.stringFromNumber(tips)
        self.totalAmountLabel.text = numberFormatter.stringFromNumber(totalAmount)
        self.eachPersonLabel.text = numberFormatter.stringFromNumber(eachPerson)

    }
    
    func updateViewWithAnimation() {
        
        if (billAmountTextField.text != nil){
            billAmount = (billAmountTextField.text! as NSString).doubleValue
            
        }
        
        // If bill value is 0, show the input-only view.
        // If bill value > 0, show the results view.
        if (billAmount == 0) {
            self.showBillAmountTextFieldOnlyWithAnimation()
        } else {
            self.showDetailResultViewWithAnimation()
        }
    }
    
    func showBillAmountTextFieldOnlyWithAnimation() {
        
        UIView.animateWithDuration(0.2, animations: self.showBillAmountTextFieldCenter, completion: nil)

    }
    
    func showDetailResultViewWithAnimation() {
        UIView.animateWithDuration(0.2, animations: self.showDetailResultView, completion: nil)
    }
    
    func showBillAmountTextFieldCenter() {
        
        // Slide down the bill text field
        var billAmountTextFrame = self.billAmountTextField.frame
        billAmountTextFrame.origin.y = self.view.center.y;
        self.billAmountTextField.frame = billAmountTextFrame
        
        tipView.hidden = true
        resultView.hidden = true
        
//        // Slide down the tip value and total fields
//        var resultFrame = resultView.frame
//        resultFrame.origin.y = 500
//        resultView.frame = resultFrame
        
        
    }
    
    func showDetailResultView() {
        
        // Slide up the bill value field
        var billAmountTextFrame = self.billAmountTextField.frame
        billAmountTextFrame.origin.y = (self.navigationController?.navigationBar.frame.origin.y)! + 50
        self.billAmountTextField.frame = billAmountTextFrame
        
        tipView.hidden = false
        resultView.hidden = false
        
//        // Slide up the tip value and total fields
//        var resultFrame = resultView.frame
//        resultFrame.origin.y = 200
//        resultView.frame = resultFrame
        
    }
    
    //Dismiss the keyboard when touch begin
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //press the right top setting button
    func onSettingsButton() {
        self.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    func setLightAttribute() {
        let darkPink = UIColor(red: 247/255, green: 0, blue: 148/255, alpha: 1)
        let lightPink = UIColor(red: 1, green: 184/255, blue: 225/255, alpha: 1)
        
        //result view attribute
        resultView.backgroundColor = darkPink
        tipLabel.textColor = lightPink
        totalAmountLabel.textColor = lightPink
        eachPersonLabel.textColor = lightPink
        fixEachPersonLabel.textColor = lightPink
        fixTipLabel.textColor = lightPink
        fixTotalLabel.textColor = lightPink
        
        //tip view attribute
        tipView.backgroundColor = lightPink
        tipfixeLabel.textColor = darkPink
        numOfPeopleFixLabel.textColor = darkPink
        minusButton.setTitleColor(darkPink, forState: UIControlState.Normal)
        plusButton.setTitleColor(darkPink, forState: UIControlState.Normal)
        tipShowLabel.textColor = darkPink
        tipControlValue.tintColor = darkPink
        numPeopleTextField.textColor = darkPink
        numPeopleTextField.tintColor = darkPink
        
        //view attribute
        view.backgroundColor = lightPink
        billAmountTextField.textColor = darkPink
        billAmountTextField.tintColor = darkPink
        navigationItem.rightBarButtonItem?.tintColor = darkPink
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : darkPink]
    }
    
    func setDarkAttribute() {
        let darkBlue = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1)
        let lightBlue =  UIColor(red: 102/255, green: 204/255, blue: 1, alpha: 1)
        
        //result view attribute
        resultView.backgroundColor = darkBlue
        tipLabel.textColor = lightBlue
        totalAmountLabel.textColor = lightBlue
        eachPersonLabel.textColor = lightBlue
        fixEachPersonLabel.textColor = lightBlue
        fixTipLabel.textColor = lightBlue
        fixTotalLabel.textColor = lightBlue
        
        //tip view attribute
        tipView.backgroundColor = lightBlue
        tipfixeLabel.textColor = darkBlue
        numOfPeopleFixLabel.textColor = darkBlue
        minusButton.setTitleColor(darkBlue, forState: UIControlState.Normal)
        plusButton.setTitleColor(darkBlue, forState: UIControlState.Normal)
        tipShowLabel.textColor = darkBlue
        tipControlValue.tintColor = darkBlue
        numPeopleTextField.textColor = darkBlue
        numPeopleTextField.tintColor = darkBlue
        
        
        //view attribute
        self.view.backgroundColor = lightBlue
        billAmountTextField.textColor = darkBlue
        billAmountTextField.tintColor = darkBlue
        navigationItem.rightBarButtonItem?.tintColor = darkBlue
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : darkBlue]
        
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    



}
