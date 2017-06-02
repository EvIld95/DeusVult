//
//  HistoryViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 18.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift


class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var runTypeSegmentedControl: UISegmentedControl!
    var label: UILabel?
    var runHistory : Results<Run>!
    var selectedRun : Run?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        //tableView.tableFooterView = UIView(frame: .zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let predicate = NSPredicate(format: "type = %@", "normal")
        runHistory = RealmManager.sharedInstance.realm!.objects(Run.self).filter(predicate)
        if(runHistory.count == 0) {
            label = UILabel(frame: CGRect(x: self.view.frame.width/2-100, y: self.view.frame.height/2, width: 200, height: 50.0))
            label!.textColor = UIColor.red
            label!.textAlignment = .center
            label!.text = "Empty Run History"
            self.view.addSubview(label!)
            
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM,yyyy"

        cell.textLabel!.text = dateFormatter.string(from: runHistory[indexPath.row].date)
        cell.detailTextLabel!.text = "Distance: \(runHistory[indexPath.row].distance )"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runHistory.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRun = runHistory[indexPath.row]
        performSegue(withIdentifier: "showRun", sender: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showRun" {
            return (selectedRun != nil)
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ShowRunViewController
        destinationVC.run = selectedRun!
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch runTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            let predicate = NSPredicate(format: "type = %@", "normal")
            runHistory = RealmManager.sharedInstance.realm!.objects(Run.self).filter(predicate)
            label?.isHidden = runHistory.count > 0
            tableView.reloadData()
        case 1:
            let predicate = NSPredicate(format: "type = %@", "interval")
            runHistory = RealmManager.sharedInstance.realm!.objects(Run.self).filter(predicate)
            label?.isHidden = runHistory.count > 0
            tableView.reloadData()
        default:
            print("Default")
        }
    }

}
