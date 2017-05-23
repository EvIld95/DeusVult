//
//  MapViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxCocoa
import RxSwift
import MBProgressHUD
import RealmSwift

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var startButton: DeusVultButton!
    @IBOutlet weak var viewWithButtons: UIView!
    @IBOutlet weak var viewWithStats: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stopButton: DeusVultButton!
    
    var firstView: UIView!
    var lastView: UIView!
    var savedLocations = [CLLocation]()
    var timer = Timer()
    var timerUpdatesAllUserPosition = Timer()
    var timerGenerateItems = Timer()
    var locationManager = CLLocationManager()
    var run : Run!
    var finish = Variable<Bool>(false)
    var running = false
    var isSignalStrength = Variable<Bool>(false)
    let gpsSignalAccuracy = 20.0
    let checkForGoodGPSSignal = false
    var hud: MBProgressHUD!
    var userPositionDict = Dictionary<String, CLLocation>()
    var userAnnotationDict = Dictionary<String, MKAnnotation>()
    let disposeBag = DisposeBag()
    var realmUserLocation: Results<UserLocations>!
    var followUserLocation = false
    var userWeight: Float?
    var timeForAnnotation = Dictionary<ItemPointAnnotation, Int>()

    var seconds = 0 {
        didSet {
            let (hours, minutes, sec) = secondsToHoursMinutesSeconds(seconds: self.seconds)
            self.timeLabel.text = self.getTimeCorrectFormat(hours: hours, minutes: minutes, sec: sec)
        }
    }
    
    var distance = 0.0 {
        didSet {
            distanceLabel.text = "\(distance.roundTo(places: 2)) m"
        }
    }
    
    var pace = 0.0 {
        didSet {
            paceLabel.text = "\(pace.roundTo(places: 2)) km/h"
        }
    }
    
    var currentSpeed = 0.0 {
        didSet {
            speedLabel.text = "\(currentSpeed.roundTo(places: 2)) km/h"
        }
    }
    
    var calories = 0.0 {
        didSet {
            caloriesLabel.text = "\(calories.roundTo(places: 1)) cal"
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        run = Run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.realmUserLocation = RealmManager.sharedInstance.realmPublic!.objects(UserLocations.self)
        self.userWeight = RealmManager.sharedInstance.realm!.objects(PersonalInfo.self).first?.weight
        self.initSetup()
        self.setupRx()
        self.setupViews()
        self.setupLocationManager()
        
        mapView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewTransition() {
        UIView.transition(from: self.firstView, to: self.lastView, duration: 0.5, options: .transitionFlipFromLeft) { (_) in
            let tempView = self.lastView
            self.lastView = self.firstView
            self.firstView = tempView
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 3.0
        locationManager.requestAlwaysAuthorization()
    }
    
    func setupViews() {
        self.firstView = viewWithButtons
        self.lastView = viewWithStats
        self.stopButton.borderButtonColor = UIColor.darkGray
        self.stopButton.backgroundColor = UIColor.red
        isSignalStrength.value = false
    }
    
    func initSetup() {
        seconds = 0
        distance = 0.0
        pace = 0.0
        currentSpeed = 0.0
        calories = 0.0
        savedLocations.removeAll(keepingCapacity: false)
    }
    
    func setupRx() {
        finish.asObservable().subscribe(onNext: { (finished) in
            if(finished == true) {
                self.timer.invalidate()
                self.timerUpdatesAllUserPosition.invalidate()
                self.locationManager.stopUpdatingLocation()
            }
        }).addDisposableTo(disposeBag)
        
        if(checkForGoodGPSSignal) {
            isSignalStrength.asObservable().subscribe(onNext: { (strength) in
                if(strength == true) {
                    self.startButton.isEnabled = true
                    self.startButton.alpha = 1.0
                    self.hud.isHidden = true
                } else {
                    if(self.running == false) {
                        if(self.hud == nil) {
                            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            self.hud.label.text = "Searching for GPS signal"
                        }
                        
                        self.startButton.isEnabled = false
                        self.startButton.alpha = 0.5
                        self.hud.isHidden = false
                    }
                }
            }).addDisposableTo(disposeBag)
        }
        
    }
    
    func eachSecond(timer: Timer) {
        self.seconds+=1
        self.pace = (self.distance / Double(self.seconds)) * 3.6
        self.calories = calculateBurnedCalories(avgSpeed: self.pace, seconds: self.seconds, weight: Double(self.userWeight ?? 72.0))
        
        for (key, value) in timeForAnnotation {
            if value < 0 {
                mapView.removeAnnotation(key)
                timeForAnnotation.removeValue(forKey: key)
            } else {
                timeForAnnotation[key] = value - 1
            }
        }
    }
    
    func updatesAllUsersPosition() {
        //print("updateAllUserPosition")
        //print(RealmManager.sharedInstance.realmPublic!.objects(UserLocations.self))
        //print(realmUserLocation);
        getUsersLocation()
        addUsersPositionToMapView()
    }
    
    func generateItems() {
        let randTime = Int(arc4random_uniform(UInt32(15)))
        print("RandTime: \(randTime)")
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(randTime)) {
          
            let annotation = ItemPointAnnotation()
            let maxDistance = 20
            let randPlus = Double(arc4random_uniform(UInt32(maxDistance))) + 1.0
            let randMinus = Double(arc4random_uniform(UInt32(maxDistance)))
            
            let randPlus2 = Double(arc4random_uniform(UInt32(maxDistance))) + 1.0
            let randMinus2 = Double(arc4random_uniform(UInt32(maxDistance)))
        
            let coordinateLatitude = self.mapView.userLocation.coordinate.latitude * ((Double(100000.0 + randPlus - randMinus) / 100000.0))
            let coordinateLongitude = self.mapView.userLocation.coordinate.longitude * ((Double(100000.0 + randPlus2 - randMinus2) / 100000.0))
            let location = CLLocation(latitude: coordinateLatitude, longitude: coordinateLongitude)
            annotation.coordinate = location.coordinate
        
            let distance = self.mapView.userLocation.location!.distance(from: location)
        
            annotation.title = "Item"
            
            annotation.image = (arc4random_uniform(UInt32(2)) % 2 == 0) ? "sword" : "treasure"
            annotation.points = 100
            annotation.money = 100
        
            let assumeSpeed = 1.0//5.0
            print("Distance \(distance)")
            let time = Double(distance) / (assumeSpeed / 3.6)
        
            self.timeForAnnotation[annotation] = Int(time)
            self.mapView.addAnnotation(annotation)
            
        }
        
    }
    
    func getUsersLocation() {
        let userID = RealmManager.sharedInstance.currentLoggedUser!.identity! //SyncUser.current!.identity!
        let predicate = NSPredicate(format: "userID != %@", userID)
        let userLocations = realmUserLocation.filter(predicate)
        print(userLocations)
        for userLocation in userLocations {
            userPositionDict[userLocation.userID] = userLocation.location
        }
    }
    
    func addUsersPositionToMapView() {
        for position in userPositionDict {
            if let dvAnnotation = getUserAnnotationFromMapView(userID: position.key) {
                dvAnnotation.coordinate = position.value.coordinate
            } else {
                let annotation = DeusVultPointAnnotation()
                annotation.coordinate = position.value.coordinate
                annotation.title = "Location of User"
                annotation.id = position.key
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func getUserAnnotationFromMapView(userID: String) -> DeusVultPointAnnotation? {
        let annotations = mapView.annotations
        return annotations.filter { (pointAnnotation) -> Bool in
            guard let dvPointAnnotation = pointAnnotation as? DeusVultPointAnnotation else {
                return false
            }
            
            if dvPointAnnotation.id == nil {
                return false
            }
            else {
                return dvPointAnnotation.id == userID
            }
        }.first as? DeusVultPointAnnotation
    }
    
    @IBAction func startButtonTapped(sender: UIButton!) {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(eachSecond(timer:)),
                                     userInfo: nil,
                                     repeats: true)
        
        
        timerUpdatesAllUserPosition = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(updatesAllUsersPosition),
                                     userInfo: nil,
                                     repeats: true)
        
        timerGenerateItems = Timer.scheduledTimer(timeInterval: 20,
                                                           target: self,
                                                           selector: #selector(generateItems),
                                                           userInfo: nil,
                                                           repeats: true)
        
        stopButton.isHidden = false
        viewTransition()
        running = true
    }
    
    @IBAction func stopButtonTapped(sender: UIButton!) {
        finish.value = true
        running = false
        if(savedLocations.count > 0) {
            self.loadMap()
        
            try! RealmManager.sharedInstance.realm!.write {
                run.averageSpeed = pace
                run.date = Date()
                run.distance = distance
                run.time = seconds
                run.maxSpeed = 10
                RealmManager.sharedInstance.realm!.add(run)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func getTimeCorrectFormat(hours: Int, minutes: Int, sec: Int) -> String {
        var displayTimeText = (hours > 0) ? "\(hours) h " : ""
        displayTimeText += (minutes > 0) ? "\(minutes) min " : ""
        displayTimeText += "\(sec) sec"
        return displayTimeText
    }
    
}






extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("DidChangeAuthorization")
        if status == .authorizedAlways {
            print("AuthorizationAlways")
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let gpsAccuracy = checkForGoodGPSSignal == true ? gpsSignalAccuracy : 1000.0
        let newLocation = locations.last!
        
        if followUserLocation == true {
            let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
        }
        
        print("\(newLocation.horizontalAccuracy) | \(locationManager.desiredAccuracy)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if newLocation.speed < 0 {
            return
        }
        
        if newLocation.horizontalAccuracy < gpsAccuracy {
            if running {
                
                if self.savedLocations.count > 0 {
                    distance += newLocation.distance(from: self.savedLocations.last!)
                }
                print("Saved location")
                if(newLocation.speed > 0) {
                    self.currentSpeed = newLocation.speed * 3.6
                }
                let locationRM = LocationRM()
                locationRM.latitude = newLocation.coordinate.latitude
                locationRM.longitude = newLocation.coordinate.longitude
                locationRM.speed = newLocation.speed
                
                
                let userID = RealmManager.sharedInstance.currentLoggedUser!.identity!//SyncUser.current!.identity
                let predicate = NSPredicate(format: "userID == %@", userID)
                let userPos = realmUserLocation.filter(predicate).first
                if let userLoc = userPos {
                    try! RealmManager.sharedInstance.realmPublic!.write {
                        userLoc.latitude = newLocation.coordinate.latitude
                        userLoc.longitude = newLocation.coordinate.longitude
                    }
                } else {
                    try! RealmManager.sharedInstance.realmPublic!.write {
                        let userLocation = UserLocations()
                        userLocation.userID = userID
                        userLocation.longitude = newLocation.coordinate.longitude
                        userLocation.latitude = newLocation.coordinate.latitude
                        RealmManager.sharedInstance.realmPublic!.add(userLocation)
                    }
                }
                
                run.locations.append(locationRM)
                self.savedLocations.append(newLocation)
            }
            
            isSignalStrength.value = true
        } else {
            isSignalStrength.value = false
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}






extension MapViewController: MKMapViewDelegate {
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = savedLocations.first!
        
        var minLat = initialLoc.coordinate.latitude
        var minLng = initialLoc.coordinate.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for location in savedLocations {
            minLat = min(minLat, location.coordinate.latitude)
            minLng = min(minLng, location.coordinate.longitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            maxLng = max(maxLng, location.coordinate.longitude)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2, longitude: (minLng + maxLng)/2),span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1, longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.red
        renderer.lineCap = .round
        
        renderer.lineWidth = 2
        return renderer
    }
    
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        for location in savedLocations {
            coords.append(location.coordinate)
        }
        
        return MKPolyline(coordinates: &coords, count: savedLocations.count)
    }
    
    func loadMap() {
        if savedLocations.count > 0 {
            mapView.region = mapRegion()
            mapView.add(polyline())
        } else {
            print("ERROR with map")
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is ItemPointAnnotation else {
            return nil
        }
        var reuseIdentifier = ""
        //if annotation is ItemPointAnnotation {
            print("Muslim")
        reuseIdentifier = "pinItem"
        //}
        //else {
        //    reuseIdentifier = "pinStandard"
        //}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView!.canShowCallout = true
            annotationView!.isEnabled = true
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
            label.text = "Time"
            
            annotationView!.rightCalloutAccessoryView = label
            
        } else {
            annotationView?.annotation = annotation
        }
        
        if annotation is ItemPointAnnotation {
            let itemPointAnnotation = annotation as! ItemPointAnnotation
            
            
            let image = UIImage(named: itemPointAnnotation.image)
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContext(size)
            image!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            annotationView!.image = resizedImage
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("Did update user location")
        
        for key in timeForAnnotation.keys {
            if(userLocation.location!.distance(from: CLLocation(latitude: key.coordinate.latitude, longitude: key.coordinate.longitude)) < 20) {
                print("YEAH POINTS")
                mapView.removeAnnotation(key)
                timeForAnnotation.removeValue(forKey: key)
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is ItemPointAnnotation {
            let time = timeForAnnotation[view.annotation! as! ItemPointAnnotation]
            let label = view.rightCalloutAccessoryView! as! UILabel
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: time!)
            label.text = self.getTimeCorrectFormat(hours: h, minutes: m, sec: s)
        }
    }
    
}






