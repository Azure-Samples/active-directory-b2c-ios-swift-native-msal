//
//  ViewController.swift
//  MSALiOSB2C
//
//  Created by Brandon Werner on 5/1/17.
//  Copyright © 2017 Brandon Werner. All rights reserved.
//

import UIKit
import MSAL




class ViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate  {
    
    let kTenantName = "fabrikamb2c.onmicrosoft.com"
    let kClientID = "90c0fe63-bcf2-44d5-8fb7-b8bbc0b29dc6"
    let kRedirectURI = "x-msauth-com-microsoft-identity-client-sample-MSALiOSB2C://"
    let kSignupOrSigninPolicy = "b2c_1_susi"
    let kEditProfilePolicy = "b2c_1_edit_profile"
    let kGraphURI = "https://fabrikamb2chello.azurewebsites.net/hello"
    let kScopes: [String] = ["https://fabrikamb2c.onmicrosoft.com/demoapi/demo.read"]

    // DO NOT CHANGE - This is the format of OIDC Token and Authorization endpoints for Azure AD B2C
    let kEndpoint = "https://login.microsoftonline.com/tfp/%@/%@"
    
    var msalResult =  MSALResult.init()
    
    @IBOutlet weak var loggingText: UITextView!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var callGraphApiButton: UIButton!
    
    @IBAction func authorizationButton(_ sender: UIButton) {
        
        let kAuthority = String(format: kEndpoint, kTenantName, kSignupOrSigninPolicy)
        
        
        
        do {
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            /*!
             Acquire a token for a new user using interactive authentication
             
             @param  kScopes Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             @param  completionBlock The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
            application.acquireToken(forScopes: kScopes) { (result, error) in
                DispatchQueue.main.async {
                    if result != nil {
                        self.msalResult = result!
                        self.loggingText.text = "Access token is \(self.msalResult.accessToken!)"
                        self.signoutButton.isEnabled = true;
                        self.callGraphApiButton.isEnabled = true;
                        //  self.silentRefreshButton.isEnabled = true;
                        
                        
                    } else {
                        self.loggingText.text = "Could not acquire token: \(error?.localizedDescription ?? "No Error provided")"
                    }
                }
            }
        }
            
        catch {
            self.loggingText.text = "Unable to create application \(error)"
        }
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        
        let kAuthority = String(format: kEndpoint, kTenantName, kEditProfilePolicy)
        
        do {
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            application.acquireToken(forScopes: kScopes) { (result, error) in
                
                if result != nil {
                    let sessionConfig = URLSessionConfiguration.default
                    let url = URL(string: self.kGraphURI)
                    var request = URLRequest(url: url!)
                    request.setValue("Bearer \(result!.accessToken)", forHTTPHeaderField: "Authorization")
                    let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
                    
                    urlSession.dataTask(with: request) { data, response, error in
                        
                        let result = try? JSONSerialization.jsonObject(with: data!, options: [])
                        DispatchQueue.main.async {
                            if result != nil {
                                
                                self.loggingText.text = result.debugDescription
                                
                                
                            }
                        }
                        }.resume() }
                else {
                    self.loggingText.text = "Could not acquire token: \(error?.localizedDescription ?? "No Error provided")"
                    
                }
            }
        }
        catch {
            self.loggingText.text = "Unable to create application: \(error)"
        }
        
    }
    
    @IBAction func signoutButton(_ sender: UIButton) {
        
         let kAuthority = String(format: kEndpoint, kTenantName, kSignupOrSigninPolicy)
        
        do {
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            
            try application.remove(self.msalResult.user)
            self.signoutButton.isEnabled = false;
            self.callGraphApiButton.isEnabled = false;
            
        }
        catch  {
            self.loggingText.text = "Received error signing user out: \(error)"
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.msalResult.accessToken == nil {
            
            signoutButton.isEnabled = false;
            callGraphApiButton.isEnabled = false;
            
            
        }
    }


}

