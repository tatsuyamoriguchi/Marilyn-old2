//
//  SOMDetailsViewController.swift
//  Marilyn
//
//  Created by Tatsuya Moriguchi on 5/11/19.
//  Copyright © 2019 Becko's Inc. All rights reserved.
//

import UIKit

class SOMDetailsViewController: UIViewController {

    var wordToSwipe: StateOfMind?
    
    @IBOutlet weak var StateOfMindLabel: UILabel!
    @IBOutlet weak var StateOfMindRateLabel: UILabel!
    
    @IBOutlet weak var CauseDescLabel: UILabel!
    @IBOutlet weak var CauseTypeLabel: UILabel!
    @IBOutlet weak var TimeStampLabel: UILabel!
    @IBOutlet weak var LocationNameLabel: UILabel!
    @IBOutlet weak var LocationAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StateOfMindLabel.text = wordToSwipe?.stateOfMindDesc?.adjective
        let rateString = String(wordToSwipe!.stateOfMindDesc!.rate)
        StateOfMindRateLabel.text = rateString
        CauseDescLabel.text = wordToSwipe?.cause?.causeDesc
        CauseTypeLabel.text = wordToSwipe?.causeType?.type
        LocationNameLabel.text = wordToSwipe?.location?.locationName
        LocationAddressLabel.text = wordToSwipe?.location?.address
        
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
