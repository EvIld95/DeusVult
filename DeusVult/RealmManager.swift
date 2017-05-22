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
    var realmPublic: Realm?
    var currentLoggedUser: SyncUser?
    //40.68.240.132
    //127.0.0.1
    private let serverAddress = "http://40.68.240.132:9080"
    
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
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://40.68.240.132:9080/~/deusvult")!)
                )
                
                self.realm = try! Realm(configuration: configuration)
                
                //completion()
                self.connectToRealmPublicDatabase(viewControllerHandler: viewControllerHandler, mainUser: user, completion: completion)
            }
        }
    }
    
    private func connectToRealmPublicDatabase(viewControllerHandler: UIViewController!, mainUser: SyncUser, completion: @escaping () -> ()) {
        SyncUser.logIn(with: .usernamePassword(username: "pablo.szudrowicz@gmail.com", password: "deus", register: false), server: URL(string: serverAddress)!) { user, error in
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
            
            
            self.currentLoggedUser = mainUser
            
            DispatchQueue.main.async {
                
                
                let configurationPublic = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://40.68.240.132:9080/globalFinalDatabase")!)
                    
                )
                
                
                self.realmPublic = try! Realm(configuration: configurationPublic)
                
              
                //let managementRealm = try! user.managementRealm()
                
               
                //try! managementRealm.write {
                //    let permissionChange = SyncPermissionChange(realmURL:"realm://192.168.250.96:9080/6029bd99185f3370095ff3f34dec947e/globalFinalDatabase",
                //        userID: mainUser.identity!, // The user ID for which these permission changes should be applied
                //        mayRead: true,         // Grant read access
                //        mayWrite: true,        // Grant write access
                //        mayManage: false)      // Grant management access
                //    managementRealm.add(permissionChange)
                //}
                
                //user.logOut()
                //let configurationPublicSpecificUser = Realm.Configuration(
                //    syncConfiguration: SyncConfiguration(user: mainUser, realmURL: URL(string: "realm://192.168.250.96:9080/6029bd99185f3370095ff3f34dec947e/globalFinalDatabase")!)
                //)
                
                //self.realmPublic = try! Realm(configuration: configurationPublicSpecificUser)
                
                
                completion()
            }
        }
    }
    
    func logoutAllUsers() {
        for user in SyncUser.all {
            user.value.logOut()
        }
    }
}
