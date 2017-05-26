
//
//  UserStatsViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 25.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import RealmSwift
import M13ProgressSuite

class UserStatsViewController: UIViewController {
    @IBOutlet weak var conditionProgressBarView: UIView!
    @IBOutlet weak var strengthProgressBarView: UIView!
    @IBOutlet weak var lifeProgressBarView: UIView!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    var conditionProgressBorderedBarView : M13ProgressViewBorderedBar!
    var strengthProgressBorderedBarView : M13ProgressViewBorderedBar!
    var lifeProgressBorderedBarView : M13ProgressViewBorderedBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let runs = RealmManager.sharedInstance.realm!.objects(Run.self)
        let items = RealmManager.sharedInstance.realm!.objects(UserItems.self)
        let predicate = NSPredicate(format: "userId = %@", RealmManager.sharedInstance.currentLoggedUser!.identity!)
        let user = RealmManager.sharedInstance.realmPublic!.objects(Users.self).filter(predicate).first!
        
        let totalDistance = runs.reduce(0.0) { (result, run) -> Double in
            return result + run.distance
        }
        let totalTime = runs.reduce(0) { (result, run) -> Int in
            return result + run.time
        }
        let totalMoney = items.reduce(0) { (result, item) -> Int in
            return result + item.money
        }
        let totalPoints = items.reduce(0) { (result, item) -> Int in
            return result + item.points
        }
        
        totalDistanceLabel.text = "\(totalDistance)"
        totalTimeLabel.text = "\(totalTime)"
        pointsLabel.text = "\(totalPoints)"
        moneyLabel.text = "\(totalMoney)"
        levelLabel.text = "\(user.level)"
        
        let calendar =  Calendar(identifier: .gregorian)
        var dateComponent = DateComponents()
        dateComponent.day = -3
        let date3DaysBefore = calendar.date(byAdding: dateComponent, to: Date())!
        print(date3DaysBefore)
        
        let predicateRunsFrom3Days = NSPredicate(format: "date > %@", date3DaysBefore as NSDate)
        let runsFromLast3Days = runs.filter(predicateRunsFrom3Days)
        let distance3Days = runsFromLast3Days.reduce(0.0) { (result, run) -> Double in
            return result + run.distance
        }
        
        
        var dateComponent2 = DateComponents()
        dateComponent2.day = -7
        let date7DaysBefore = calendar.date(byAdding: dateComponent2, to: Date())!
        
        let predicateRunsFrom7Days = NSPredicate(format: "date > %@", date7DaysBefore as NSDate)
        let runsFromLast7Days = runs.filter(predicateRunsFrom7Days)
        let distance7Days = runsFromLast7Days.reduce(0.0) { (result, run) -> Double in
            return result + run.distance
        }
        
        
        
        let distanceRatio = distance3Days * 2 / distance7Days
        
        
        conditionProgressBorderedBarView = M13ProgressViewBorderedBar(frame: CGRect(x: 0, y: self.conditionProgressBarView.frame.height/4, width: self.conditionProgressBarView.frame.width, height: self.conditionProgressBarView.frame.height/2))
        conditionProgressBorderedBarView.setProgress((CGFloat(distanceRatio > 1.0 ? 1.0 : distanceRatio)), animated: true)
        conditionProgressBorderedBarView.cornerType = M13ProgressViewBorderedBarCornerTypeRounded
        conditionProgressBorderedBarView.cornerRadius = 8.0
        conditionProgressBorderedBarView.animationDuration = 1.5
        self.conditionProgressBarView.addSubview(conditionProgressBorderedBarView)
        
        strengthProgressBorderedBarView = M13ProgressViewBorderedBar(frame: CGRect(x: 0, y: self.strengthProgressBarView.frame.height/4, width: self.strengthProgressBarView.frame.width, height: self.strengthProgressBarView.frame.height/2))
        strengthProgressBorderedBarView.setProgress((CGFloat(totalPoints) / 10000.0) + 0.05, animated: true)
        strengthProgressBorderedBarView.cornerType = M13ProgressViewBorderedBarCornerTypeRounded
        strengthProgressBorderedBarView.cornerRadius = 8.0
        strengthProgressBorderedBarView.animationDuration = 1.5
        strengthProgressBorderedBarView.secondaryColor = UIColor.green
        strengthProgressBorderedBarView.primaryColor = UIColor.green
        self.strengthProgressBarView.addSubview(strengthProgressBorderedBarView)
        
        lifeProgressBorderedBarView = M13ProgressViewBorderedBar(frame: CGRect(x: 0, y: self.lifeProgressBarView.frame.height/4, width: self.lifeProgressBarView.frame.width, height: self.lifeProgressBarView.frame.height/2))
        lifeProgressBorderedBarView.setProgress(CGFloat(user.life)/100, animated: true)
        lifeProgressBorderedBarView.cornerType = M13ProgressViewBorderedBarCornerTypeRounded
        lifeProgressBorderedBarView.cornerRadius = 8.0
        lifeProgressBorderedBarView.animationDuration = 1.5
        lifeProgressBorderedBarView.secondaryColor = UIColor.red
        lifeProgressBorderedBarView.primaryColor = UIColor.red
        self.lifeProgressBarView.addSubview(lifeProgressBorderedBarView)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
