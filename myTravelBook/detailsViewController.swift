//
//  detailsViewController.swift
//  myTravelBook
//
//  Created by Turan Çabuk on 25.07.2022.
//

import UIKit
import CoreData
import MapKit




class detailsViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedPlace = ""
    var selectedPlaceID : UUID?
    var annotationName = ""
    var annotationNote = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var noteText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedPlace != ""{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = selectedPlaceID?.uuidString
            fetchRequest.predicate = NSPredicate(format: " id = %@", idString!)
            
            do{
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        annotationName = name
                    }
                    if let note = result.value(forKey: "note") as? String{
                        annotationNote = note
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double{
                        annotationLatitude = latitude
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double{
                        annotationLongitude = longitude
                    }
                    
                    let annotation = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                    annotation.coordinate = coordinate
                    nameText.text = annotationName
                    noteText.text = annotationNote
                    mapView.addAnnotation(annotation)
                    annotation.title = annotationName
                    annotation.subtitle = annotationNote
                }
                
            }catch{
                
            }
            
            
            
            
            
            
            
        }
   
    
    
    }
    @objc func selectLocation(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            self.mapView.addAnnotation(annotation)
            annotation.title = nameText.text
            annotation.subtitle = noteText.text
        }
        
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        saveData.setValue(nameText.text, forKey: "name")
        saveData.setValue(noteText.text, forKey: "note")
        saveData.setValue(chosenLatitude, forKey: "latitude")
        saveData.setValue(chosenLongitude, forKey: "longitude")
        saveData.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("succes!")
        }catch{
            print("error!")
        }
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("New Data"), object: nil)
    }
    
}
