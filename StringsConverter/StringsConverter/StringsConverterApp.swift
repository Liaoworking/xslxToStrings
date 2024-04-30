//
//  StringsConverterApp.swift
//  StringsConverter
//
//  Created by liao on 2024/4/30.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
   @Binding
   var window: NSWindow?

   func makeNSView(context: Context) -> NSView {
      let view = NSView()
      DispatchQueue.main.async {
         self.window = view.window
      }
      return view
   }

   func updateNSView(_ nsView: NSView, context: Context) {}
}


@main
struct StringsConverterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var window: NSWindow?
    
    var body: some Scene {
        WindowGroup {
            ContentView().background(WindowAccessor(window: self.$window)).onChange(of: window) { oldValue, newValue in
                XSLXManager.showWindow = newValue
            }
        }.defaultSize(CGSize(width: 226, height: 251))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    
    
    
//    func application(_ application: NSApplication, configurationForConnecting connectingSceneSession: NSSceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
//        if connectingSceneSession.role == .windowApplication {
//            configuration.delegateClass = SceneDelegate.self
//        }
//        return configuration
//    }
}
