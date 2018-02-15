//
//  ViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IHKeyboardAvoiding
import MBProgressHUD
import RealmSwift


class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    
    let soundPlayerManager = SoundPlayerManager()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        RealmManager.sharedInstance.logoutAllUsers()
        self.setupTouchGesture()
        self.playBackgroundMusic()
        
        KeyboardAvoiding.avoidingView = self.view
        let emailRx = emailTextField.rx.text.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            return (inputText?.characters.count ?? 0) > 0
        }
        let passwordRx = passwordTextField.rx.text.throttle(0.5, scheduler: MainScheduler.instance).map { (inputText) ->Bool in
            return (inputText?.characters.count ?? 0) > 0
        }
        
        emailTextField.text = "konto@gmail.com"
        passwordTextField.text = "qwerty"
        Observable.combineLatest(emailRx, passwordRx).subscribe(onNext: { (email, password) in
            if(email == true && password == true) {
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
            } else {
                self.loginButton.isEnabled = false
                self.loginButton.alpha = 0.5
            }
        }).addDisposableTo(disposeBag)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonTapped(sender: UIButton!) {
        hideKeyboard()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        RealmManager.sharedInstance.connectToRealmDatabase(username: emailTextField.text!, password: passwordTextField.text!, register: false, viewControllerHandler: self) { (_) in
            MBProgressHUD.hide(for: self.view, animated: true)

            let mapViewController = self.storyboard!.instantiateViewController(withIdentifier: "navigationController")
            self.show(mapViewController, sender: nil)
        }
    }
    
    func setupTouchGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func playBackgroundMusic() {
        self.soundPlayerManager.play(mp3Name: "protector", infiniteLoop: true, extensionFormat: "mp3")
    }
    
}

