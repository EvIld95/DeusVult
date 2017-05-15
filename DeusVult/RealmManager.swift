//
//  RealmManager.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift
import MBProgressHUD

class RealmManager {
    static let sharedInstance = RealmManager()
    var realm : Realm?
    private let serverAddress = "http://192.168.1.65:9080"
    
    func connectToRealmDatabase(username:String, password: String, register: Bool, viewControllerHandler: UIViewController!, completion: @escaping () -> ()) {
        SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: register), server: URL(string: serverAddress)!) { user, error in
            guard let user = user else {
                DispatchQueue.main.sync {
                    MBProgressHUD.hide(for: viewControllerHandler.view, animated: true)
                }
                print(error?.localizedDescription as Any)
                let alertController = UIAlertController(title: "Error!", message: "Problem with connection to database server", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                viewControllerHandler.present(alertController, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://192.168.1.65:9080/~/deusvult")!)
                )
                self.realm = try! Realm(configuration: configuration)
                completion()
            }
        }
    }
    
}
