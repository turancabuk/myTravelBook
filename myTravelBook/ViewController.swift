//
//  ViewController.swift
//  myTravelBook
//
//  Created by Turan Çabuk on 21.07.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var notText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectedLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    @objc func selectedLocation(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{
            let selectedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = mapView.convert(selectedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = notText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion (center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        saveData.setValue(nameText.text, forKey: "name")
        saveData.setValue(notText.text, forKey: "not")
        saveData.setValue(chosenLatitude, forKey: "latitude")
        saveData.setValue(chosenLongitude, forKey: "longitude")
        saveData.setValue(UUID(), forKey: "id")
        
        
        
        do{
            try context.save()
            print("Succes!")
        }catch{
            print("error!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("New Data"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

}

