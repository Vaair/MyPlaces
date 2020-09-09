//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 08.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegete {
    func getAddress(_ address: String)
}

class MapViewController: UIViewController {
    
    var place = Place()
    let locationId = "locationId"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    var incomeSegueId = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    
    @IBAction func centerViewUserLocation() {
        showUserLocation()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
    }
    
    private func setupMapView() {
        if incomeSegueId == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            chechLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are disabled",
                               message: "To enable it go: Setting -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func chechLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //когда доступны
            mapView.showsUserLocation = true
            if incomeSegueId == "getAddress" {
                showUserLocation()
            }
            break
        case .denied: //отказано использование служб
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location"
                )
            }
            break
        case .notDetermined: //неопределенность
            locationManager.requestWhenInUseAuthorization()
        case .restricted: //не авторизовано для служб геолокации
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude //широта
        let longitude = mapView.centerCoordinate.longitude //долгота
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert,animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "locationId") as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "locationId")
            annotationView?.canShowCallout = true //баннер
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let bildNumber = placemark?.subThoroughfare
            
            
            DispatchQueue.main.async {
                if streetName != nil && bildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(bildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
            
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        chechLocationAuthorization()
    }
}
