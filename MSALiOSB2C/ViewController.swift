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
    let kAuthorityHostName = "fabrikamb2c.b2clogin.com" // Your authority host name
    let kClientID = "90c0fe63-bcf2-44d5-8fb7-b8bbc0b29dc6" // Your client ID from the portal when you created your application
    let kRedirectUri = "msauth.com.microsoft.identity.client.sample.MSALiOSB2C://auth" // Your application's redirect URI
    let kSignupOrSigninPolicy = "b2c_1_susi" // Your signup and sign-in policy you created in the portal
    let kEditProfilePolicy = "b2c_1_edit_profile" // Your edit policy you created in the portal
    let kResetPasswordPolicy = "b2c_1_reset" // Your reset password policy you created in the portal
    let kGraphURI = "https://fabrikamb2chello.azurewebsites.net/hello" // This is your backend API that you've configured to accept your app's tokens
    let kScopes: [String] = ["https://fabrikamb2c.onmicrosoft.com/helloapi/demo.read"] // This is a scope that you've configured your backend API to look for.
    
    // DO NOT CHANGE - This is the format of OIDC Token and Authorization endpoints for Azure AD B2C.
    let kEndpoint = "https://%@/tfp/%@/%@"
    
    var application: MSALPublicClientApplication!
    
    var accessToken: String?
    
    @IBOutlet weak var loggingText: UITextView!
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var callGraphApiButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var refreshTokenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            /**
             
             Initialize a MSALPublicClientApplication with a MSALPublicClientApplicationConfig.
             MSALPublicClientApplicationConfig can be initialized with client id, redirect uri and authority.
             */
            
            let siginPolicyAuthority = try self.getAuthority(forPolicy: self.kSignupOrSigninPolicy)
            let editProfileAuthority = try self.getAuthority(forPolicy: self.kEditProfilePolicy)

            // Provide configuration for MSALPublicClientApplication
            // MSAL will use default redirect uri when you provide nil
            let pcaConfig = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: kRedirectUri, authority: siginPolicyAuthority)
            pcaConfig.knownAuthorities = [siginPolicyAuthority, editProfileAuthority]
            self.application = try MSALPublicClientApplication(configuration: pcaConfig)
        } catch {
            self.updateLoggingText(text: "Unable to create application \(error)")
        }
    }
    
    /**
     This button will invoke the authorization flow and send the policy specified to the B2C server.
     Here we are using the `kSignupOrSignInPolicy` to sign the user in to the app. We will store this 
     accessToken for subsequent calls.
     */
    
    @IBAction func authorizationButton(_ sender: UIButton) {
        do {
            /**
             
             authority is a URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
             it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
             directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
             use for the current user flow.
             
             */
            
            let authority = try self.getAuthority(forPolicy: self.kSignupOrSigninPolicy)
            
            /**
             Acquire a token for a new account using interactive authentication
             
             - scopes: Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             - completionBlock: The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
            
            let webViewParameters = MSALWebviewParameters(parentViewController: self)
            let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
            parameters.promptType = .selectAccount
            parameters.authority = authority
            application.acquireToken(with: parameters) { (result, error) in
                
                guard let result = result else {
                    self.updateLoggingText(text: "Could not acquire token: \(error ?? "No error informarion" as! Error)")
                    return
                }
                
                self.accessToken = result.accessToken
                self.updateLoggingText(text: "Access token is \(self.accessToken ?? "Empty")")
                self.signoutButton.isEnabled = true
                self.callGraphApiButton.isEnabled = true
                self.editProfileButton.isEnabled = true
                self.refreshTokenButton.isEnabled = true
            }
        } catch {
            self.updateLoggingText(text: "Unable to create authority \(error)")
        }
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        do {
            
            /**
             
             authority is a URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
             it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
             directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
             use for the current user flow.
             
             */
            
            let authority = try self.getAuthority(forPolicy: self.kEditProfilePolicy)
            
            /**
             Acquire a token for a new account using interactive authentication
             
             - scopes: Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             - completionBlock: The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
            
            let thisAccount = try self.getAccountByPolicy(withAccounts: application.allAccounts(), policy: kEditProfilePolicy)
            let webViewParameters = MSALWebviewParameters(parentViewController: self)
            let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
            parameters.authority = authority
            parameters.account = thisAccount
            
            application.acquireToken(with: parameters) { (result, error) in
                if let error = error {
                    self.updateLoggingText(text: "Could not edit profile: \(error)")
                } else {
                    self.updateLoggingText(text: "Successfully edited profile")
                }
            }
        } catch {
            self.updateLoggingText(text: "Unable to construct parameters before calling acquire token \(error)")
        }
    }
    
    @IBAction func refreshToken(_ sender: UIButton) {
        
        do {
            /**
             
             authority is a URL indicating a directory that MSAL can use to obtain tokens. In Azure B2C
             it is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
             directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
             use for the current user flow.
             
             */
            
            let authority = try self.getAuthority(forPolicy: self.kSignupOrSigninPolicy)
            
            /**
             
             Acquire a token for an existing account silently
             
             - scopes: Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             gauranteed to be included in the access token returned.
             - account: An account object that we retrieved from the application object before that the
             authentication flow will be locked down to.
             - completionBlock: The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
            
            guard let thisAccount = try self.getAccountByPolicy(withAccounts: application.allAccounts(), policy: kSignupOrSigninPolicy) else {
                self.updateLoggingText(text: "There is no account available!")
                return
            }
            
            let parameters = MSALSilentTokenParameters(scopes: kScopes, account:thisAccount)
            parameters.authority = authority
            self.application.acquireTokenSilent(with: parameters) { (result, error) in
                if let error = error {
                    
                    let nsError = error as NSError
                    
                    // interactionRequired means we need to ask the user to sign-in. This usually happens
                    // when the user's Refresh Token is expired or if the user has changed their password
                    // among other possible reasons.
                    
                    if (nsError.domain == MSALErrorDomain) {
                        
                        if (nsError.code == MSALError.interactionRequired.rawValue) {
                            
                            // Notice we supply the account here. This ensures we acquire token for the same account
                            // as we originally authenticated.
                            
                            let webviewParameters = MSALWebviewParameters(parentViewController: self)
                            let parameters = MSALInteractiveTokenParameters(scopes: self.kScopes, webviewParameters: webviewParameters)
                            parameters.account = thisAccount
                            
                            self.application.acquireToken(with: parameters) { (result, error) in
                                
                                guard let result = result else {
                                    self.updateLoggingText(text: "Could not acquire new token: \(error ?? "No error informarion" as! Error)")
                                    return
                                }
                                
                                self.accessToken = result.accessToken
                                self.updateLoggingText(text: "Access token is \(self.accessToken ?? "empty")")
                            }
                            return
                        }
                    }
                    
                    self.updateLoggingText(text: "Could not acquire token: \(error)")
                    return
                }
                
                guard let result = result else {
                    
                    self.updateLoggingText(text: "Could not acquire token: No result returned")
                    return
                }
                
                self.accessToken = result.accessToken
                self.updateLoggingText(text: "Refreshing token silently")
                self.updateLoggingText(text: "Refreshed access token is \(self.accessToken ?? "empty")")
            }
        } catch {
            self.updateLoggingText(text: "Unable to construct parameters before calling acquire token \(error)")
        }
    }
    
    @IBAction func callApi(_ sender: UIButton) {
        guard let accessToken = self.accessToken else {
            self.updateLoggingText(text: "Operation failed because could not find an access token!")
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        let url = URL(string: self.kGraphURI)
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        self.updateLoggingText(text: "Calling the API....")
        
        urlSession.dataTask(with: request) { data, response, error in
            guard let validData = data else {
                self.updateLoggingText(text: "Could not call API: \(error ?? "No error informarion" as! Error)")
                return
            }
            
            let result = try? JSONSerialization.jsonObject(with: validData, options: [])
            
            guard let validResult = result as? [String: Any] else {
                self.updateLoggingText(text: "Nothing returned from API")
                return
            }
            
            self.updateLoggingText(text: "API response: \(validResult.debugDescription)")
            }.resume()
    }
    
    @IBAction func signoutButton(_ sender: UIButton) {
        do {
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            let thisAccount = try self.getAccountByPolicy(withAccounts: application.allAccounts(), policy: kSignupOrSigninPolicy)
            
            if let accountToRemove = thisAccount {
                try application.remove(accountToRemove)
            } else {
                self.updateLoggingText(text: "There is no account to signing out!")
            }
            
            self.signoutButton.isEnabled = false
            self.callGraphApiButton.isEnabled = false
            self.editProfileButton.isEnabled = false
            self.refreshTokenButton.isEnabled = false
            
            self.updateLoggingText(text: "Signed out")
            
        } catch  {
            self.updateLoggingText(text: "Received error signing out: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.accessToken == nil {
            signoutButton.isEnabled = false
            callGraphApiButton.isEnabled = false
            editProfileButton.isEnabled = false
            refreshTokenButton.isEnabled = false
        }
    }
    
    func getAccountByPolicy (withAccounts accounts: [MSALAccount], policy: String) throws -> MSALAccount? {
        
        for account in accounts {
            // This is a single account sample, so we only check the suffic part of the object id,
            // where object id is in the form of <object id>-<policy>.
            // For multi-account apps, the whole object id needs to be checked.
            if let homeAccountId = account.homeAccountId, let objectId = homeAccountId.objectId {
                if objectId.hasSuffix(policy.lowercased()) {
                    return account
                }
            }
        }
        return nil
    }
    
    /**
     
     The way B2C knows what actions to perform for the user of the app is through the use of `Authority URL`.
     It is of the form `https://<instance/tfp/<tenant>/<policy>`, where `<instance>` is the
     directory host (e.g. https://login.microsoftonline.com), `<tenant>` is a
     identifier within the directory itself (e.g. a domain associated to the
     tenant, such as contoso.onmicrosoft.com), and `<policy>` is the policy you wish to
     use for the current user flow.
     */
    func getAuthority(forPolicy policy: String) throws -> MSALB2CAuthority {
        guard let authorityURL = URL(string: String(format: self.kEndpoint, self.kAuthorityHostName, self.kTenantName, policy)) else {
            throw NSError(domain: "SomeDomain",
                          code: 1,
                          userInfo: ["errorDescription": "Unable to create authority URL!"])
        }
        return try MSALB2CAuthority(url: authorityURL)
    }
    
    func updateLoggingText(text: String) {
        DispatchQueue.main.async{
            self.loggingText.text = text
        }
    }
}

