//
//  ShareViewController.swift
//  BriefShareExt
//
//  Created by Rachel Radford on 1/19/25.
//

//import Social
//
//class ShareViewController: SLComposeServiceViewController {
//    override func didSelectPost() {
//        guard let extensionContext = self.extensionContext else { return }
//
//        for item in extensionContext.inputItems as? [NSExtensionItem] ?? [] {
//            for attachment in item.attachments ?? [] {
//                if attachment.hasItemConformingToTypeIdentifier("public.url") {
//                    attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
//                        if let url = url as? URL {
//                            print("Received URL: \(url.absoluteString)")
//                            self.saveURLToAppGroup(url: url)
//                        }
//                    }
//                }
//            }
//        }
//        
//        extensionContext.completeRequest(returningItems: nil, completionHandler: nil)
//    }
//
//    private func saveURLToAppGroup(url: URL) {
//        let sharedDefaults = UserDefaults(suiteName: "group.com.brief.app")
//        sharedDefaults?.set(url.absoluteString, forKey: "sharedURL")
//        sharedDefaults?.synchronize()
//        print("Saved URL to App Group: \(url.absoluteString)")
//    }
//}
