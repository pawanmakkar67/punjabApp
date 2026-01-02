//
//  PunjabAppNewApp.swift
//  PunjabAppNew
//
//  Created by pc on 29/10/25.
//
import SwiftUI
import FirebaseCore
import UIKit
// TODO: Uncomment after adding IQKeyboardManagerSwift package product to target
// import IQKeyboardManagerSwift


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
    
    // TODO: Uncomment after adding IQKeyboardManagerSwift package product to target
    // Configure IQKeyboardManager
//    IQKeyboardManager.shared.enable = true
//    IQKeyboardManager.shared.enableAutoToolbar = true
//    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//    IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
//    IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
    
    return true
  }
}

@main
struct PunjabAppNewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()

     var body: some Scene {
         WindowGroup {
             RootView()
                 .environmentObject(appState)
         }
     }
}



