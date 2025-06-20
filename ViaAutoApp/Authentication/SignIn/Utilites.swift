//
//  Utilites.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 28.06.25.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    private init() { }
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            return topViewController(controller: tabController)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
