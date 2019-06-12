//
//  AdherencesViewController.swift
//  HealtheraAssessment
//
//  Created by Jithin Prakash on 6/11/19.
//  Copyright © 2019 Aparna kishan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AdherencesViewController: UIViewController {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var adherencesTable: UITableView! {
        didSet {
            adherencesTable.tableFooterView = UIView(frame: .zero)
        }
    }
    var adherences: [AdherencesDataModel] = []
    
    //Since there is no data for today in the api response, hard coding the date with an available date
    var startInterval :Int = 1547164800
    var endInterval: Int = 1547251199

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var greetingString : String {
            get {
                let currentHour = Calendar.current.component(.hour, from: Date())
                switch currentHour {
                case 0...12:
                    return "Good Morning"
                case 12...17:
                    return "Good Afternoon"
                case 17...23:
                    return "Good Evening"
                default:
                    return "Good Evening"
                }
            }
        }
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.5568627451, blue: 0.2754863664, alpha: 1)
        self.dayLabel.text = Helper().getDayFrom(date: Date(timeIntervalSince1970: Double(startInterval)))
        self.greetingLabel.text = greetingString;
        self.adherencesTable.delegate = self
        self.adherencesTable.dataSource = self

        getAdherences()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getAdherences() {
        let defaults = UserDefaults.standard
        let patientId = defaults.string(forKey: "patient_id")
        APIClient.adherences(patient_id: patientId!,startDate:startInterval , endDate:endInterval, completion: { result in
            switch(result) {
            case .success(_):
                if let data = result.value{
                    let jsonData : JSON = JSON(data)
                    for (_, object) in jsonData["data"] {
                        APIClient.remedy(patient_id: patientId!, remedy_id: object["remedy_id"].stringValue, completion: { result in
                            switch(result) {
                            case .success(_):
                                if let data = result.value{
                                    let remedyData : JSON = JSON(data)
                                    self.parseDataAndUpdateUI(adherence: object, remedy: remedyData)
                                }
                                break
                            case .failure(_):
                                if let data = result.error{
                                    print(data)
                                }
                                break
                            }
                        })
                    }
                    //self.parseDataAndUpdateUI(data: jsonData)
                }
                break
                
            case .failure(_):
                if let data = result.error{
                    print(data)
                }
                break
                
            }
        })
        
    }
        
    func parseDataAndUpdateUI(adherence: JSON , remedy: JSON) {
//        for (_, object) in adherence["data"] {
            let adherenceModel = AdherencesDataModel()
            adherenceModel.remedy_id = adherence["remedy_id"].stringValue
            adherenceModel.adherence_id = adherence["adherence_id"].stringValue
            adherenceModel.alarm_time = adherence["alarm_time"].intValue
            adherenceModel.dose_quantity = adherence["dose_quantity"].intValue
            adherenceModel.note = adherence["note"].stringValue
            adherenceModel.action = adherence["action"].stringValue
            adherenceModel.medicine_name = remedy["data"][0]["medicine_name"].stringValue
            adherences.append(adherenceModel)
//        }
        self.adherencesTable.reloadData()
    }

    @IBAction func logoutButtonTapped(_ sender: Any) {
        APIClient.logout(completion: {result in
            //        Alamofire.request(request).responseJSON { (response:DataResponse<Any>) in
            
            switch(result) {
            case .success(_):
                if let data = result.value{
                    let jsonData : JSON = JSON(data)
                    print(jsonData)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                break
                
            case .failure(_):
                if let data = result.error{
                    print(data)
                }
                break
                
            }
        })
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

extension AdherencesViewController : UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate {
    // MARK: - Tableview Datasource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.adherences.count > 5 ? 5 : self.adherences.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdherenceCell", for: indexPath) as! AdherenceTableViewCell
        let adherence = self.adherences[indexPath.item]
        cell.medicineLabel.text = adherence.medicine_name
        cell.timeLabel.text = Helper().getTimeFromDate(timeStamp: Double(adherence.alarm_time!))
        cell.actionLabel.text = adherence.action
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adherence = self.adherences[indexPath.item]
        
        /* 2 */
        //Configure the presentation controller
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "PopOverViewController") as? PopOverViewController
        popoverContentController?.selectedAdherence = adherence
        popoverContentController?.modalPresentationStyle = .popover
        
        /* 3 */
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
//            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.minX + 50, y: self.view.bounds.minY + 370, width: 0, height: 0)
            popoverPresentationController.delegate = self

//            popoverPresentationController.sourceRect = buttonFrame
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    //UIPopoverPresentationControllerDelegate inherits from UIAdaptivePresentationControllerDelegate, we will use this method to define the presentation style for popover presentation controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
