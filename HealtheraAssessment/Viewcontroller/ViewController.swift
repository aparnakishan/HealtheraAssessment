//
//  ViewController.swift
//  HealtheraAssessment
//
//  Created by Jithin Prakash on 6/6/19.
//  Copyright © 2019 Aparna kishan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "quiz@healthera.co.uk"
        passwordTextField.text = "Healthera01"
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginTapped(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            return
        }
        performLogin(email!,password!)
    }
    
    func performLogin(_ email:String,_ password:String) {
//        let parameters : [String : String] = ["username" : email, "user_password" : password]
//        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
//
//        var request = URLRequest(url: URL(string: LOGIN_URL)!)
//        request.httpMethod = HTTPMethod.post.rawValue
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue(CLIENT_ID, forHTTPHeaderField: "client-id")
//        request.httpBody = jsonData
        
        APIClient.login(user: email, user_password: password, completion: {result in
//        Alamofire.request(request).responseJSON { (response:DataResponse<Any>) in
            
            switch(result) {
            case .success(_):
                if let data = result.value{
                    let jsonData : JSON = JSON(data)
                    self.updateLoginDetails(with: jsonData)
                    print(jsonData)
                    self.performSegue(withIdentifier: "goToHome", sender: self.logInButton)
                }
                break
                
            case .failure(_):
                if let data = result.error{
                    print(data)
                }
                break
                
            }
        })
        
   //}
}

func updateLoginDetails(with data:JSON) {
    let token = data["data"][0]["token"].stringValue
    let patient_id = data["data"][0]["user"]["user_id"].stringValue
    let defaults = UserDefaults.standard
    defaults.set(token, forKey: "token")
    defaults.set(patient_id, forKey: "patient_id")

}

}
