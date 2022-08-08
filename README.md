---
languages:
- swift
page_type: sample
description: "The MSAL preview library for iOS and macOS gives your app the ability to begin using the Microsoft Cloud by supporting Azure B2C."
products:
- azure
- azure-active-directory
urlFragment: microsoft-authentication-library-b2c-ios
---

# Microsoft Authentication Library B2C Sample for Apple iOS in Swift

| [Getting Started](https://docs.microsoft.com/azure/active-directory-b2c/active-directory-b2c-get-started)| [Library](https://github.com/AzureAD/microsoft-authentication-library-for-objc) | [Docs](https://aka.ms/aadb2c) | [Support](README.md#community-help-and-support)
| --- | --- | --- | --- |

The MSAL library for iOS and macOS gives your app the ability to begin using the [Microsoft identity platform](https://aka.ms/aaddev) by supporting [Azure B2C](https://azure.microsoft.com/en-us/services/active-directory-b2c/) using industry standard OAuth2 and OpenID Connect. This sample demonstrates all the normal lifecycles your application should experience, including:

* How to get a token
* How to refresh a token
* How to call your backend REST API service
* How to clear your user from your application

## Example

```swift
do {
	// Create an instance of MSALPublicClientApplication with proper config
	let authority = try MSALB2CAuthority(url: URL(string: "<your-authority-here>")!)
	let pcaConfig = MSALPublicClientApplicationConfig(clientId: "<your-client-id-here>", redirectUri: nil, authority: authority)
	let application = try MSALPublicClientApplication(configuration: pcaConfig)
            
	let viewController = self /*replace with your main presentation controller here */
	let webViewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
	let interactiveParameters = MSALInteractiveTokenParameters(scopes: ["<enter-your-scope-here>"], webviewParameters: webViewParameters)
            
	application.acquireToken(with: interactiveParameters) { (result, error) in
                
		guard let result = result else {
			print(error!) /* MSAL token acquisition failed, check error information */
			return
                }
                
                let accessToken = result.accessToken
                let account = result.account
                /* MSAL token acquisition succeeded, use access token or check account */
                
	}
}
catch {
	print(error) /* MSALPublicClientApplication creation failed, check error information */
}
```

## App Registration

You will need to have a B2C client application registered with Microsoft. Follow [the instructions here](https://docs.microsoft.com/en-us/azure/active-directory-b2c/add-native-application?tabs=app-reg-ga). Make sure you make note of your `client ID`, and the name of the policies you create. Once done, you will need add the redirect URI of `msal<your-client-id-here>://auth`.


## Installation

Load the podfile using cocoapods. This will create a new XCode Workspace you will load.

From terminal navigate to the directory where the podfile is located

```
$ pod install
...
$ open MSALiOSB2C.xcworkspace
```
:warning: **Note:** If using an ARM-based Mac (M1/M2) then `pod install` needs to be run in a Rosetta terminal window. For more information follow [the instructions here.](https://osxdaily.com/2020/11/18/how-run-homebrew-x86-terminal-apple-silicon-mac/) 

## Configure your application

1. Add your application's redirect URI scheme to added in the portal to your `info.plist` file. It will be in the format of `msal<client-id>`
```xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>msalyour-client-id-here</string>
            </array>
        </dict>
    </array>
```

2. Configure your application defaults

In the `ViewControler.swift` file, update the variables at the top of this file with the information for your tenant.

```swift
    let kTenantName = "fabrikamb2c.onmicrosoft.com" // Your tenant name
    let kAuthorityHostName = "fabrikamb2c.b2clogin.com" // Your authority host name
    let kClientID = "90c0fe63-bcf2-44d5-8fb7-b8bbc0b29dc6" // Your client ID from the portal when you created your application
    let kSignupOrSigninPolicy = "b2c_1_susi" // Your signup and sign-in policy you created in the portal
    let kEditProfilePolicy = "b2c_1_edit_profile" // Your edit policy you created in the portal
    let kResetPasswordPolicy = "b2c_1_reset" // Your reset password policy you created in the portal
    let kGraphURI = "https://fabrikamb2chello.azurewebsites.net/hello" // This is your backend API that you've configured to accept your app's tokens
    let kScopes: [String] = ["https://fabrikamb2c.onmicrosoft.com/helloapi/demo.read"] // This is a scope that you've configured your backend API to look for.
```
> [!NOTE]
>developers using the [Azure China Environment](https://docs.microsoft.com/en-us/azure/active-directory/develop/authentication-national-cloud), MUST use <your-tenant-name>.b2clogin.cn) authority, instead of `login.chinacloudapi.cn`.
>
> In order to use <your-tenant-name>.b2clogin.*, you will need to `setValidateAuthority(false)`. Learn more about using [b2clogin](https://docs.microsoft.com/en-us/azure/active-directory-b2c/b2clogin).
    
## Community Help and Support

We use Stack Overflow to provide support using [tag MSAL](http://stackoverflow.com/questions/tagged/msal) and [tag azure-ad-b2c](http://stackoverflow.com/questions/tagged/azure-ad-b2c). We highly recommend you ask your questions on Stack Overflow first and browse existing issues to see if someone has asked your question before.

If you find and bug or have a feature request, please raise the issue on [GitHub Issues](../../issues).

To provide a recommendation, visit our [User Voice page](https://feedback.azure.com/forums/169401-azure-active-directory).

## Contribute

We enthusiastically welcome contributions and feedback. You can clone the repo and start contributing now. 

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Security Library

This library controls how users sign-in and access services. We recommend you always take the latest version of our library in your app when possible. We use [semantic versioning](http://semver.org) so you can control the risk associated with updating your app. As an example, always downloading the latest minor version number (e.g. x.*y*.x) ensures you get the latest security and feature enhanements but our API surface remains the same. You can always see the latest version and release notes under the Releases tab of GitHub.

## Security Reporting

If you find a security issue with our libraries or services please report it to [secure@microsoft.com](mailto:secure@microsoft.com) with as much detail as possible. Your submission may be eligible for a bounty through the [Microsoft Bounty](http://aka.ms/bugbounty) program. Please do not post security issues to GitHub Issues or any other public site. We will contact you shortly upon receiving the information. We encourage you to get notifications of when security incidents occur by visiting [this page](https://technet.microsoft.com/en-us/security/dd252948) and subscribing to Security Advisory Alerts.

Copyright (c) Microsoft Corporation.  All rights reserved. Licensed under the MIT License (the "License");
