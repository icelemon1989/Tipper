//
//  SettingsViewController.swift
//  Tipper
//
//  Created by Yang Ruan on 9/29/15.
//  Copyright © 2015 Yang Ji. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var defaultTipControl: UISegmentedControl!
    
    @IBOutlet weak var switchValue: UISwitch!
    
    //Set dark color theme
    @IBAction func turnSwitch(sender: UISwitch) {
        
        updateDefaultColor()
    }
    
    func updateDefaultColor() {
        //save the default color
        let defaultDarkSetting = NSUserDefaults.standardUserDefaults()
        
        if switchValue.on {
            defaultDarkSetting.setBool(true, forKey: "Default_Dark_Setting")
        } else {
            defaultDarkSetting.setBool(false, forKey: "Default_Dark_Setting")
        }
    }
    
    func updateDefaulTip() {
        // Save the default tip percentage
        let tipDefault = NSUserDefaults.standardUserDefaults()
        tipDefault.setInteger(defaultTipControl.selectedSegmentIndex, forKey: "default_tip_segment_index")
        tipDefault.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //change the navigationbar tint color
        self.navigationController?.navigationBar.tintColor = UIColor(red: 247/255, green: 0, blue: 148/255, alpha: 1)
        
        // Initialize the view with the current default tip percentage
        let tipDefault = NSUserDefaults.standardUserDefaults()
        let defaultTipSegmentIndex = tipDefault.integerForKey("default_tip_segment_index")
        defaultTipControl.selectedSegmentIndex = defaultTipSegmentIndex
        
        //Initialize the swtich with current default switch
        let colorDefault = NSUserDefaults.standardUserDefaults()
        if colorDefault.boolForKey("Default_Dark_Setting") {
            switchValue.setOn(true, animated: false)
        } else {
            switchValue.setOn(false, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        updateDefaulTip()
        
        updateDefaultColor()
        
        super.viewWillDisappear(animated)
    }

    @IBAction func defaultTipControlChange(sender: UISegmentedControl) {
        
        //update default tip control
        updateDefaulTip()
        
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

}
