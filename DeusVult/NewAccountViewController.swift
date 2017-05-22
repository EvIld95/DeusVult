//
//  NewAccountViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 15.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import IHKeyboardAvoiding
import MBProgressHUD


class NewAccountViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var newAccountButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        KeyboardAvoiding.avoidingView = self.view
        self.setupRx()
        self.setupTouchGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func newAccountButtonTouched(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        RealmManager.sharedInstance.connectToRealmDatabase(username: emailTextField.text!, password: passwordTextField.text!, register: true, viewControllerHandler: self) { 
            let personalInfo = PersonalInfo()
            personalInfo.height = Float(self.heightTextField.text!)!
            personalInfo.weight = Float(self.weightTextField.text!)!
            personalInfo.name = self.nameTextField.text!
            try! RealmManager.sharedInstance.realm!.write {
                RealmManager.sharedInstance.realm!.add(personalInfo)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            let mapViewController = self.storyboard!.instantiateViewController(withIdentifier: "navigationController")
            self.show(mapViewController, sender: nil)
            
        }
    }
   
    func setupRx() {
        let emailRx = emailTextField.rx.text.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            return (inputText!.contains("@gmail.com"))
        }
        emailRx.skip(1).subscribe(onNext: { (correct) in
            self.emailTextField.backgroundColor = (correct == true) ? UIColor.deusVultGreen : UIColor.red
        }).addDisposableTo(disposeBag)
        
        let passRx = passwordTextField.rx.text.throttle(0.5, scheduler: MainScheduler.instance).map { (inputText) ->Bool in
            return (inputText?.characters.count ?? 3) > 0
        }
        passRx.skip(1).subscribe(onNext: { (correct) in
            self.passwordTextField.backgroundColor = (correct == true) ? UIColor.deusVultGreen : UIColor.red
        }).addDisposableTo(disposeBag)

        let passCorrect = Observable.combineLatest(passwordTextField.rx.text.asObservable(), passwordCheckTextField.rx.text.asObservable()).map { (pass, passCheck) -> Bool in
            if !pass!.isEmpty && !passCheck!.isEmpty {
                return pass == passCheck
            } else {
                return false
            }
        }
        
        passCorrect.skip(1).subscribe(onNext: { (correct) in
            self.passwordCheckTextField.backgroundColor = (correct == true) ? UIColor.deusVultGreen : UIColor.red
        }).addDisposableTo(disposeBag)

        
        let nameRx = nameTextField.rx.text.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            return (inputText?.characters.count ?? 3) > 0
        }
        nameRx.skip(1).subscribe(onNext: { (correct) in
            self.nameTextField.backgroundColor = (correct == true) ? UIColor.deusVultGreen : UIColor.red
        }).addDisposableTo(disposeBag)

        
        let weightRx = weightTextField.rx.text.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            if let text = inputText, let _ = Double(text) {
                return true
            } else {
                return false
            }
        }
        weightRx.skip(1).subscribe(onNext: { (correct) in
            self.weightTextField.backgroundColor = (correct == true) ? UIColor.deusVultGreen : UIColor.red
        }).addDisposableTo(disposeBag)

        
        let heightRx = heightTextField.rx.text.throttle(0.5,scheduler:MainScheduler.instance).map { (inputText) -> Bool in
            if let text = inputText, let _ = Double(text) {
                return true
            } else {
                return false
            }
        }
        heightRx.skip(1).subscribe(onNext: { (correct) in
            self.heightTextField.backgroundColor = (correct == true) ? UIColor.deusVultGreen : UIColor.red
        }).addDisposableTo(disposeBag)
        
        Observable.combineLatest([emailRx,passCorrect,nameRx,weightRx,heightRx]).map { (boolArray) -> Bool in
            print("BOOLARRAY: ",boolArray)
            return !boolArray.contains(false)
            }.subscribe(onNext: { (success) in
                self.newAccountButton.isEnabled = success
                self.newAccountButton.alpha = (success == true) ? 1.0 : 0.5
            }).addDisposableTo(disposeBag)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func setupTouchGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

}
