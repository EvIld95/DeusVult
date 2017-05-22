//
//  ShowRunViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 19.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import MapKit
import Charts

class ShowRunViewController: UIViewController {

    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    var run: Run!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 3.0
        
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.legend.enabled = false
        
        lineChartView.xAxis.drawLimitLinesBehindDataEnabled = false
        lineChartView.drawMarkers = false
        
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInCubic)
        
    
        var runEntries = [ChartDataEntry]()
        
        
        
        for (i,location) in run.locations.enumerated() {
            let entry = ChartDataEntry(x: Double(i), y: location.speed)
            runEntries.append(entry)
        }
        
        let chartDataSet = LineChartDataSet(values: runEntries, label: "Speed")
        chartDataSet.mode = .cubicBezier
        chartDataSet.cubicIntensity = 0.2
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.lineWidth = 2.0
        chartDataSet.circleRadius = 2.0
        chartDataSet.circleColors = [UIColor.red]
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = UIColor.green
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = [UIColor.red]
    
     
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        
        self.chartTitleLabel.text = "Your run pace"
        
        self.mapView.delegate = self
        loadMap()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ShowRunViewController : MKMapViewDelegate {
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations.first!
        
        var minLat = initialLoc.location.coordinate.latitude
        var minLng = initialLoc.location.coordinate.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        for locationRM in run.locations {
            minLat = min(minLat, locationRM.location.coordinate.latitude)
            minLng = min(minLng, locationRM.location.coordinate.longitude)
            maxLat = max(maxLat, locationRM.location.coordinate.latitude)
            maxLng = max(maxLng, locationRM.location.coordinate.longitude)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2, longitude: (minLng + maxLng)/2),span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.2, longitudeDelta: (maxLng - minLng)*1.2))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MulticolorPolylineSegment
        //let polyline = overlay as! MKPolyline
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        //renderer.strokeColor = UIColor.red
        renderer.lineCap = .round
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 5
        
        return renderer
    }
    
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        let locations = run.locations
        for locationRM in locations {
            coords.append(locationRM.location.coordinate)
        }
        return MKPolyline(coordinates: &coords, count: locations.count)
    }
    
    
    func loadMap() {
        if run.locations.count > 0 {
            mapView.region = mapRegion()
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: Array(run.locations))
            mapView.addOverlays(colorSegments)
            //mapView.add(polyline())
        } else {
            print("ERROR with map")
        }
    }

}

