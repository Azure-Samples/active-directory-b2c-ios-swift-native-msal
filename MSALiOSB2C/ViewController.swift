//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

import UIKit
import MSAL

/// 😃 A View Controller that will respond to the events of the Storyboard.


class ViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate  {
    
    let kTenantName = "fabrikamb2c.onmicrosoft.com" // Your tenant name
    let kClientID = "90c0fe63-bcf2-44d5-8fb7-b8bbc0b29dc6" // Your client ID from the portal when you created your application
    let kSignupOrSigninPolicy = "b2c_1_susi" // Your signup and sign-in policy you created in the portal
    let kEditProfilePolicy = "b2c_1_edit_profile" // Your edit policy you created in the portal
    let kGraphURI = "https://fabrikamb2chello.azurewebsites.net/hello" // This is your backend API that you've configured to accept your app's tokens
    let kScopes: [String] = ["https://fabrikamb2c.onmicrosoft.com/helloapi/demo.read"] // This is a scope that you've configured your backend API to look for.

    // DO NOT CHANGE - This is the format of OIDC Token and Authorization endpoints for Azure AD B2C.
    let kEndpoint = "https://login.microsoftonline.com/tfp/%@/%@"
    
    var accessToken = String()
    
    @IBOutlet weak var loggingText: UITextView!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var callGraphApiButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var refreshTokenButton: UIButton!
    
    
    /**
     This button will invoke the authorization flow and send the policy specified to the B2C server.
     Here we are using the `kSignupOrSignInPolicy` to sign the user in to the app. We will store this 
     accessToken for subsequent calls.
     */
    
    @IBAction func authorizationButton(_ sender: UIButton) {
        /**
         
         Initialize a MSALPublicClientApplication with a given clientID and authority
         
         - clientId:     The clientID of your application, you should get this from the app portal.
         - authority:    A URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
         it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
         directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
         identifier within the directory itself (e.g. a domain associated to the
         tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
         use for the current user flow.
         - error:       The error that occurred creating the application object, if any, if you're
         not interested in the specific error pass in nil.
         
         */
        
        do {
            let kAuthority = try self.getAuthority(forPolicy: self.kSignupOrSigninPolicy)
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            /**
             Acquire a token for a new user using interactive authentication
             
             - forScopes: Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             - completionBlock: The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
        
            
            application.acquireToken(forScopes: kScopes) { (result, error) in
                    if  error == nil {
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Access token is \(self.accessToken)"
                        self.signoutButton.isEnabled = true;
                        self.callGraphApiButton.isEnabled = true;
                        self.editProfileButton.isEnabled = true;
                        self.refreshTokenButton.isEnabled = true;
                        
                        
                    } else {
                        self.loggingText.text = "Could not acquire token: \(error ?? "No error informarion" as! Error)"
                    }
            }
        } catch {
            self.loggingText.text = "Unable to create application \(error)"
        }
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        do {
            
            /**
             
             Initialize a MSALPublicClientApplication with a given clientID and authority
             
             - clientId:     The clientID of your application, you should get this from the app portal.
             - authority:    A URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
             it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
             directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
             use for the current user flow.
             - error:       The error that occurred creating the application object, if any, if you're
             not interested in the specific error pass in nil.
             
             */

            let kAuthority = try self.getAuthority(forPolicy: self.kEditProfilePolicy)
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            /**
             Acquire a token for a new user using interactive authentication
             
             - forScopes: Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             - completionBlock: The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
            
            let thisUser = try self.getUserByPolicy(withUsers: application.allAccounts(), forPolicy: kEditProfilePolicy)
            
            application.acquireToken(forScopes: kScopes, account:thisUser ) { (result, error) in
                    if error == nil {
                        self.loggingText.text = "Successfully edited profile"
                        
                        
                    } else {
                        self.loggingText.text = "Could not edit profile: \(error ?? "No error informarion" as! Error)"
                    }
            }
        } catch {
            self.loggingText.text = "Unable to create application \(error)"
        }
    }

    @IBAction func refreshToken(_ sender: UIButton) {
        do {
            let kAuthority = try self.getAuthority(forPolicy: self.kSignupOrSigninPolicy)
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            /**
             
             Acquire a token for an existing user silently
             
             - forScopes: Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             - User: A user object that we retrieved from the application object before that the
             authentication flow will be locked down to.
             - completionBlock: The completion block that will be called when the authentication
             flow completes, or encounters an error.
             
             Note the fact that we also look for `InteractionRequired` as an error code and
             prompt the user interactively. Often times the inability to use a refresh token
             is from either a password change, refersh token expiring, or other event that
             can be remedied by the user signing in again. This shouldn't be necessary at every
             `AcquireTokenSilent()`. If you are experiencing that in your application, make
             sure you are using the cache correctly and using the same authority.
             */
            
            let thisUser = try self.getUserByPolicy(withUsers: application.allAccounts(), forPolicy: kSignupOrSigninPolicy)
            
            guard (thisUser != nil) else {
                return
            }
    
            application.acquireTokenSilent(forScopes: kScopes, account: thisUser! ) { (result, error) in
                    if error == nil {
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Refreshing token silently"
                        self.loggingText.text = "Refreshed Access token is \(self.accessToken)"
                        
                    }  else if (error! as NSError).code == MSALErrorCode.interactionRequired.rawValue {
                        
                        // Notice we supply the user here. This ensures we acquire token for the same user
                        // as we originally authenticated.
                        
                        application.acquireToken(forScopes: self.kScopes, account: thisUser!) { (result, error) in
                                if error == nil {
                                    self.accessToken = (result?.accessToken)!
                                    self.loggingText.text = "Access token is \(self.accessToken)"
                                    
                                } else  {
                                    self.loggingText.text = "Could not acquire new token: \(error ?? "No error informarion" as! Error)"
                                }
                        }
                    } else {
                        self.loggingText.text = "Could not acquire token: \(error ?? "No error informarion" as! Error)"
                    }
            }
            } catch {
            self.loggingText.text = "Unable to create application \(error)"
            
            }
    }
    
    @IBAction func callApi(_ sender: UIButton) {
            
            
            let sessionConfig = URLSessionConfiguration.default
            let url = URL(string: self.kGraphURI)
            var request = URLRequest(url: url!)
            request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
            let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
            
            urlSession.dataTask(with: request) { data, response, error in
                
                if error == nil {
                    let result = try? JSONSerialization.jsonObject(with: data!, options: [])
                        if result != nil {
                            self.loggingText.text = "API response: \(result.debugDescription)"
                        } else {
                            self.loggingText.text = "Nothing returned from API"
                        }
                } else {
                    self.loggingText.text = "Could not call API: \(error ?? "No error informarion" as! Error)"
                }
                }.resume()
        
    }
    
    @IBAction func signoutButton(_ sender: UIButton) {
        do {
            
            /**
             
             Initialize a MSALPublicClientApplication with a given clientID and authority
             
             - clientId:     The clientID of your application, you should get this from the app portal.
             - authority:    A URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
             it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
             directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
             use for the current user flow.
             - error:       The error that occurred creating the application object, if any, if you're
             not interested in the specific error pass in nil.
             */
            
            let kAuthority = try self.getAuthority(forPolicy: self.kSignupOrSigninPolicy)
            let application = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
            
            /**
             Removes all tokens from the cache for this application for the provided user
             
             - user:    The user to remove from the cache
             */
            
            let thisUser = try self.getUserByPolicy(withUsers: application.allAccounts(), forPolicy: kSignupOrSigninPolicy)
            
            if (thisUser != nil) {
                try application.remove(thisUser!)
            }
            self.signoutButton.isEnabled = false;
            self.callGraphApiButton.isEnabled = false;
            self.editProfileButton.isEnabled = false;
            self.refreshTokenButton.isEnabled = false;
            
        } catch  {
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
        
        if self.accessToken.isEmpty {
            
            signoutButton.isEnabled = false;
            callGraphApiButton.isEnabled = false;
            editProfileButton.isEnabled = false;
            refreshTokenButton.isEnabled = false;
            
            
        }
    }
    
    /**
     The way B2C knows what actions to perform for the user of the app is through the use of `Authority URL`,
     a URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
     it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
     directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
     identifier within the directory itself (e.g. a domain associated to the
     tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
     use for the current user flow.
     */
    func getAuthority(forPolicy: String) throws -> MSALAuthority {
        return try MSALAuthority(url: URL(string: String(format: self.kEndpoint, self.kTenantName, forPolicy))!)
    }
    
    func getUserByPolicy (withUsers: [MSALAccount], forPolicy: String) throws -> MSALAccount? {
        
        for user in withUsers {
            if (user.homeAccountId?.objectId?.components(separatedBy: ".")[0].hasSuffix(forPolicy.lowercased()) ?? false) {
                return user
            }
    }
        return nil
   }


}

