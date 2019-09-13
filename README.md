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

The MSAL preview library for iOS and macOS gives your app the ability to begin using the [Microsoft Cloud](https://cloud.microsoft.com) by supporting [Azure B2C](https://azure.microsoft.com/en-us/services/active-directory-b2c/) using industry standard OAuth2 and OpenID Connect. This sample demonstrates all the normal lifecycles your application should experience, including:

* How to get a token
* How to refresh a token
* How to call your backend REST API service
* How to clear your user from your application

## Example

```swift
do {
    // Create an instance of MSALPublicClientApplication with proper config
    let authority = try MSALB2CAuthority(url: URL(string:kAuthority)!)
    let pcaConfig = MSALPublicClientApplicationConfig(clientId: <your-client-id-here>, redirectUri: nil, authority: authority)
    let application = try MSALPublicClientApplication(configuration: pcaConfig)
    
    application.acquireToken(forScopes: kScopes) { (result, error) in
    DispatchQueue.main.async {
    if result != nil {
    // Set up your application for the user
        } else {
            print(error)
        }
      }
    }
}

        catch {
            print(error)
        }
    }
```

## App Registration

You will need to have a B2C client application registered with Microsoft. Follow [the instructions here](https://docs.microsoft.com/azure/active-directory-b2c/active-directory-b2c-get-started). Make sure you make note of your `client ID`, and the name of the policies you create. Once done, you will need add the redirect URI of `msal<your-client-id-here>://auth`.


## Installation

We use [Carthage](https://github.com/Carthage/Carthage) for package management during the preview period of MSAL. This package manager integrates very nicely with XCode while maintaining our ability to make changes to the library. The sample is set up to use Carthage.

##### If you're building for iOS, tvOS, or watchOS

1. Install Carthage on your Mac using a download from their website or if using Homebrew `brew install carthage`.
1. We have already created a `Cartfile` that lists the MSAL library for this project on Github. We use the `/dev` branch.
1. Run `carthage bootstrap`. This will fetch dependencies into a `Carthage/Checkouts` folder, then build the MSAL library.
1. On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop the `MSAL.framework` from the `Carthage/Build` folder on disk.
1. On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell:

  ```sh
  /usr/local/bin/carthage copy-frameworks
  ```

  and add the paths to the frameworks you want to use under “Input Files”, e.g.:

  ```
  $(SRCROOT)/Carthage/Build/iOS/MSAL.framework
  ```
  This script works around an [App Store submission bug](http://www.openradar.me/radar?id=6409498411401216) triggered by universal binaries and ensures that necessary bitcode-related files and dSYMs are copied when archiving.

With the debug information copied into the built products directory, Xcode will be able to symbolicate the stack trace whenever you stop at a breakpoint. This will also enable you to step through third-party code in the debugger.

When archiving your application for submission to the App Store or TestFlight, Xcode will also copy these files into the dSYMs subdirectory of your application’s `.xcarchive` bundle.

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
    let kTenantName = "<tenant>.onmicrosoft.com" // Your tenant name
    let kClientID = "<your-client-id>" // Your client ID from the portal when you created your application
    let kSignupOrSigninPolicy = "<your-signin-policy>" // Your signup and sign-in policy you created in the portal
    let kEditProfilePolicy = "<your-edit-profile-policy>" // Your edit policy you created in the portal
    let kGraphURI = "<Your backend API>" // This is your backend API that you've configured to accept your app's tokens
    let kScopes: [String] = ["<Your backend API>/demo.read"] // This is a scope that you've configured your backend API to look for.
```




## Community Help and Support

We use Stack Overflow to provide support using [tag MSAL](http://stackoverflow.com/questions/tagged/msal) and [tag azure-ad-b2c](http://stackoverflow.com/questions/tagged/azure-ad-b2c). We highly recommend you ask your questions on Stack Overflow first and browse existing issues to see if someone has asked your question before.

If you find and bug or have a feature request, please raise the issue on [GitHub Issues](../../issues).

To provide a recommendation, visit our [User Voice page](https://feedback.azure.com/forums/169401-azure-active-directory).

## Contribute

We enthusiastically welcome contributions and feedback. You can clone the repo and start contributing now. Read our [Contribution Guide](Contributing.md) for more information.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


Copyright (c) Microsoft Corporation.  All rights reserved. Licensed under the MIT License (the "License");
