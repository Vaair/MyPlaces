 //
 //  MapManager.swift
 //  MyPlaces
 //
 //  Created by Лера Тарасенко on 10.09.2020.
 //  Copyright © 2020 Лера Тарасенко. All rights reserved.
 //
 
 import UIKit
 import MapKit
 
 class MapManager {
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinates: CLLocationCoordinate2D?
    
    //Маркер заведения
    func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinates = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            chechLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are disabled",
                               message: "To enable it go: Setting -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    //Проверка авторизации приложения для использования сервисов геолокации
    func chechLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //когда доступны
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    //Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    
    //Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in responce.routes {
                mapView.addOverlay(route.polyline) //геометрия
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) //маршрут целиком
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Distance: \(distance) km.")
                print("Time in road: \(timeInterval ) sec.")
            }
        }
    }
    
    //Настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
           guard let destinationCoordinate = placeCoordinates else { return nil }
           let startingLocation = MKPlacemark(coordinate: coordinate)
           let destination = MKPlacemark(coordinate: destinationCoordinate)
           
           let request = MKDirections.Request()
           request.source = MKMapItem(placemark: startingLocation)
           request.destination = MKMapItem(placemark: destination)
           request.transportType = .automobile
           request.requestsAlternateRoutes = true //альтернативы
           
           return request
       }
    
      
    
    //Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
        
//        self.previousLocation = center
//
//        
        
    }
    
    //сброс ранее построенных маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView){
           mapView.removeOverlays(mapView.overlays)
           directionsArray.append(directions)
           let _ = directionsArray.map { $0.cancel() }
           directionsArray.removeAll()
       }
    
    //определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
              let latitude = mapView.centerCoordinate.latitude //широта
              let longitude = mapView.centerCoordinate.longitude //долгота
              
              return CLLocation(latitude: latitude, longitude: longitude)
          }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert,animated: true)
    }
    
    
 }
