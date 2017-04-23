//
//  MapViewController.swift
//  FlatironGo
//
//  Created by You on 7/15/16.
//  Copyright © 2016 Gamesmith, LLC. All rights reserved.
//

import UIKit
import Mapbox

final class MapViewController: UIViewController  {
    
    var annotations: [String: Treasure] = [:]
    var mapView: MGLMapView!
    
    let captureSession = AVCaptureSession()
    let motionManager = CMMotionManager()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // The following four are already created for you!
    var treasure: Treasure!
    var foundImageView: UIImageView!
    var dismissButton: UIButton!
    var foundTreasure = false
    
    // The following two are not--make sure to copy/paste them into Xcode
    var quaternionX: Double = 0.0 {
        didSet {
            if !foundTreasure { treasure.item.center.y = (CGFloat(quaternionX) * view.bounds.size.width - 180) * 4.0 }
        }
    }
    
    var quaternionY: Double = 0.0 {
        didSet {
            if !foundTreasure { treasure.item.center.x = (CGFloat(quaternionY) * view.bounds.size.height + 100) * 4.0 }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        setupMapView()
        setCenterCoordinateOnMapView()
        generateDummyData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupMainComponents()
    }
    
    private func setupMainComponents() {
        setupCaptureCameraDevice()
        setupPreviewLayer()
        setupMotionManager()
        setupGestureRecognizer()
        setupDismissButton()
    }
    
}

// MARK: - Dummy Data
extension MapViewController {
    
    fileprivate func generateDummyData() {
        // let buzzLocation = GPSLocation(latitude: 40.7032775878906, longitude: -74.0170288085938)
        let bullLocation = GPSLocation(latitude: 40.7033342590332, longitude: -74.0139770507812)
        let funnyLocation = GPSLocation(latitude: 40.7082803039551, longitude: -74.0140228271484)
        let nyseLocation = GPSLocation(latitude: 40.7056159973145, longitude: -74.0184048461914)
        let polarLocation = GPSLocation(latitude: 40.7068748474121, longitude: -74.0112686157227)
        
        // let buzz = Treasure(location: buzzLocation, name: "Buzz Lightyear", imageURLString: "")
        let bull = Treasure(location: bullLocation, name: "Charging Bull", imageURLString: "")
        let funny = Treasure(location: funnyLocation, name: "Not Snorlax", imageURLString: "")
        let nyse = Treasure(location: nyseLocation, name: "NYSE", imageURLString: "")
        let polar = Treasure(location: polarLocation, name: "Hairy Harry", imageURLString: "")
        
        // buzz.image = UIImage(imageLiteral: "BuzzLightyear")
        
        // buzz.imageLiteral = #imageLiteral(resourceName: "BuzzLightyear")
        bull.image = #imageLiteral(resourceName: "ChargingBull")
        funny.image = #imageLiteral(resourceName: "FunnyPhoto")
        nyse.image = #imageLiteral(resourceName: "NYSE")
        polar.image = #imageLiteral(resourceName: "PolarBear")
        
        
        let treasureObjects = [bull, funny, nyse, polar]
        
        for treasure in treasureObjects {
            treasure.createItem()
            generateAnnotationWithTreasure(treasure)
        }
        
    }
    
}

// MARK: - Map View Methods
extension MapViewController {
    
    fileprivate func setupMapView() {
        mapView = MGLMapView(frame: view.bounds, styleURL: URL(string: "mapbox://styles/ianrahman/ciqodpgxe000681nm8xi1u1o9"))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.isPitchEnabled = true
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    fileprivate func setCenterCoordinateOnMapView() {
        let lat: CLLocationDegrees = 40.706697302800182
        let lng: CLLocationDegrees = -74.014699650804047
        let downtownManhattan = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mapView.setCenter(downtownManhattan, zoomLevel: 15, direction: 25.0, animated: false)
    }
    
}

// MARK: - MapView Delegate Methods
extension MapViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        guard annotation is MGLPointAnnotation else { return nil }
        
        let reuseIdentifier = String(annotation.coordinate.longitude)
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? TreasureAnnotationView
        
        if annotationView == nil {
            annotationView = TreasureAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            annotationView!.scalesWithViewingDistance = false
            annotationView!.isEnabled = true
            
            let imageView = UIImageView(image: UIImage(named: "treasure"))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            annotationView!.addSubview(imageView)
            imageView.topAnchor.constraint(equalTo: (annotationView?.topAnchor)!).isActive = true
            imageView.bottomAnchor.constraint(equalTo: (annotationView?.bottomAnchor)!).isActive = true
            imageView.leftAnchor.constraint(equalTo: (annotationView?.leftAnchor)!).isActive = true
            imageView.rightAnchor.constraint(equalTo: (annotationView?.rightAnchor)!).isActive = true
        }
        
        let key = String(annotation.coordinate.latitude) + String(annotation.coordinate.longitude)
        if let associatedTreasure = annotations[key] {
            annotationView?.treasure = associatedTreasure
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        handleTapOfAnnotationView(annotationView)
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        // TODO: User is in radius of tapped treasure.
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 200, pitch: 60, heading: 0)
        mapView.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        mapView.resetNorth()
    }
    
}

// MARK: - Annotation Methods
extension MapViewController {
    
    fileprivate func generateAnnotationWithTreasure(_ treasure: Treasure) {
        let newAnnotation = MGLPointAnnotation()
        let lat = Double(treasure.location.latitude)
        let long = Double(treasure.location.longitude)
        newAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        newAnnotation.title = treasure.name
        let key = String(newAnnotation.coordinate.latitude) + String(newAnnotation.coordinate.longitude)
        annotations[key] = treasure
        mapView.addAnnotation(newAnnotation)
        
    }
    
}

// MARK: - Segue Method
extension MapViewController {
    
    fileprivate func handleTapOfAnnotationView(_ annotationView: MGLAnnotationView) {
        if let annotation = annotationView as? TreasureAnnotationView {
            performSegue(withIdentifier: "TreasureSegue", sender: annotation)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "TreasureSegue" else { return }
        guard let destVC = segue.destination as? ViewController else { return }
        
        if let annotation = sender as? TreasureAnnotationView {
            destVC.treasure = annotation.treasure
        }
    }
}



