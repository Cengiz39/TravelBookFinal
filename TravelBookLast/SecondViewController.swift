//
//  SecondViewController.swift
//  TravelBookLast
//
//  Created by Cengiz Baygın on 14.05.2020.
//  Copyright © 2020 Cengiz Baygın. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class SecondViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var saveButtonUI: UIButton!
    let locationManager = CLLocationManager()
    var titleString = String()
    var subTitleString = String()
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    var checkedVar = Bool()
    var storedIdVar = UUID()
    var checkSave = Bool()
    var navigationTitle = String()
    var navigationLatitude = Double()
    var navigationLongitude = Double()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let gestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(addAnnotation))
        gestureRecognizer.minimumPressDuration = 1.25
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        if checkedVar == true {
            getData()
            mapView.isUserInteractionEnabled = true
            saveButtonUI.isEnabled = false
        }else{
            mapView.isUserInteractionEnabled = true
            saveButtonUI.isEnabled = true
        }
    }
    @objc func addAnnotation(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let mapAnnotation = MKPointAnnotation()
            // Alert
            let alertMessage = UIAlertController.init(title: "PIN Ekleme Ünitesi", message: "PIN Eklemek için gerekli bilgileri doldurun.", preferredStyle: UIAlertController.Style.alert)
            alertMessage.addTextField { (UITextField) in
                UITextField.placeholder = "İsim:(Gerekli)"
                UITextField.clearButtonMode = .whileEditing
                UITextField.autocapitalizationType = .words
                UITextField.textAlignment = .center
            }
            alertMessage.addTextField { (UITextField) in
                UITextField.placeholder = "Konum:(Gerekli)"
                UITextField.clearButtonMode = .whileEditing
                UITextField.autocapitalizationType = .words
                UITextField.textAlignment = .center
            }
            let addButton = UIAlertAction.init(title: "Ekle", style: UIAlertAction.Style.default) { (UIAlertAction) in
                if alertMessage.textFields![0].text != nil && alertMessage.textFields![1].text != nil && alertMessage.textFields![0].text!.count >= 4 && alertMessage.textFields![1].text!.count >= 4 {
                    if let temporalTitle = alertMessage.textFields![0].text as? String {
                        if let temporalSubTitle = alertMessage.textFields![1].text as? String{
                            mapAnnotation.coordinate = touchCoordinate
                            mapAnnotation.title = temporalTitle
                            mapAnnotation.subtitle = temporalSubTitle
                            self.titleString = mapAnnotation.title!
                            self.subTitleString = mapAnnotation.subtitle!
                            self.annotationLatitude = touchCoordinate.latitude
                            self.annotationLongitude = touchCoordinate.longitude
                            self.mapView.addAnnotation(mapAnnotation)
                            print(self.titleString,self.subTitleString)
                            self.checkSave = true
                        }
                    }
                }else{
                    self.checkCorretFunction()
                } // check lastline
            }// addbutton lastline
            let cancelButton = UIAlertAction.init(title: "Vazgeç", style: UIAlertAction.Style.destructive, handler: nil)
            alertMessage.addAction(addButton)
            alertMessage.addAction(cancelButton)
            self.present(alertMessage, animated: true, completion: nil)
            // Alert Last
        } // if gesture lastline
    }// add annotation lastline
    func checkCorretFunction(){
        checkSave = false
        let failMessage = UIAlertController.init(title: "Hatalı Giriş!", message: "Girdiğiniz karakterler birbirinin aynısı olmaması ve 4 karakterden uzun olması gerekmektedir.", preferredStyle: UIAlertController.Style.actionSheet)
        let retryButton = UIAlertAction.init(title: "Yeniden Dene", style: UIAlertAction.Style.cancel, handler: nil)
        failMessage.addAction(retryButton)
        self.present(failMessage, animated: true, completion: nil)
    }// func bitiş
    func getData(){
        let appDelegateVar = UIApplication.shared.delegate as! AppDelegate
        let appContext = appDelegateVar.persistentContainer.viewContext
        let appFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationDb")
        let idString = storedIdVar.uuidString
        appFetchRequest.predicate = NSPredicate.init(format: "id = %@", idString)
        appFetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchResult = try appContext.fetch(appFetchRequest)
            for fetchResultsArray in fetchResult as! [NSManagedObject]{
                if let storedTitle = fetchResultsArray.value(forKey: "title")as? String{
                    if let storedSubtitle = fetchResultsArray.value(forKey: "subtitle") as? String{
                        if let storedLongitude = fetchResultsArray.value(forKey: "longitude")as? Double {
                            if let storedLatitude = fetchResultsArray.value(forKey: "latitude")as? Double{
                                let storedAnnotation = MKPointAnnotation()
                                storedAnnotation.title = storedTitle
                                storedAnnotation.subtitle = storedSubtitle
                                let coordinateVar = CLLocationCoordinate2DMake(storedLatitude, storedLongitude)
                                storedAnnotation.coordinate = coordinateVar
                                locationManager.stopUpdatingLocation()
                                let span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
                                let region = MKCoordinateRegion.init(center: coordinateVar, span: span)
                                mapView.setRegion(region, animated: true)
                                mapView.addAnnotation(storedAnnotation)
                                navigationTitle = storedTitle
                                navigationLatitude = storedLatitude
                                navigationLongitude = storedLongitude
                            }// storedLatitude
                        }// storedLongitude
                    }// storedSubtitle
                }// storedTitle
            }// for bitis
        } catch  {
            print("Error!")
        }
        
        
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        if checkSave == true {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let appContext = appDelegate.persistentContainer.viewContext
            let newLocation = NSEntityDescription.insertNewObject(forEntityName: "LocationDb", into: appContext)
            newLocation.setValue(titleString, forKey: "title")
            newLocation.setValue(subTitleString, forKey: "subtitle")
            newLocation.setValue(annotationLongitude, forKey: "longitude")
            newLocation.setValue(annotationLatitude, forKey: "latitude")
            newLocation.setValue(UUID(), forKey: "id")
            do {
                try appContext.save()
            } catch  {
                print("Error!")
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            checkCorretFunction()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2DMake(locations[0].coordinate.latitude, locations[0].coordinate.longitude)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion.init(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reusableId = "annotations"
        var pinview = mapView.dequeueReusableAnnotationView(withIdentifier: reusableId) as? MKPinAnnotationView
        
        if pinview == nil{
            pinview = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: reusableId)
            pinview?.canShowCallout = true
            pinview?.tintColor = .red
            let button = UIButton.init(type: UIButton.ButtonType.detailDisclosure)
            pinview?.rightCalloutAccessoryView = button
        }else{
            pinview?.annotation = annotation
        }
        return pinview
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let requestLocation = CLLocation(latitude: navigationLatitude, longitude: navigationLongitude)
        
        
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
            //closure
            
            if let placemark = placemarks {
                if placemark.count > 0 {
                    
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.navigationTitle
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                    
                }
            }
        }
        
    }
} // bitiş
