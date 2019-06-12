//
//  PopOverViewController.swift
//  HealtheraAssessment
//
//  Created by Jithin Prakash on 6/12/19.
//  Copyright © 2019 Aparna kishan. All rights reserved.
//

import UIKit

class PopOverViewController: UIViewController {

    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var medicineLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    var selectedAdherence:AdherencesDataModel? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        if let time = self.selectedAdherence?.alarm_time, let medicine = self.selectedAdherence?.medicine_name {
            self.scheduleLabel.text = "Scheduled for \(Helper().getTimeFromDate(timeStamp: Double(time)) ?? "") \(Helper().getDayFrom(date: Date(timeIntervalSince1970: TimeInterval(time))) ?? "")"
            self.medicineLabel.text = medicine
            self.actionLabel.text = self.selectedAdherence?.action
        }

        // Do any additional setup after loading the view.
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
