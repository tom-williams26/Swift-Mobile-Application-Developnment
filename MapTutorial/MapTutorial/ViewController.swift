//
//  ViewController.swift
//  MapTutorial
//
//  Created by Williams T (FCES) on 28/02/2020.
//  Copyright © 2020 Williams T (FCES). All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func getButtonTapped(_ sender: UIButton) {
        getDirections()
    }
    @IBOutlet weak var addressLabelOutlet: UILabel!
    
    let locationManager = CLLocationManager()
    let regionMeters: Double = 0.5
    var previousLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
        mapView.delegate=self
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() { // Ask the location manager to see if location services enabled.
            // Set up location mananger.
            setUpLocationManager() // Set up the location manager as we know services are enabled.
            checkLocationAuth() // Check the location authorization or this app.
        }
        else {
            // Show alert to say turn on location
            let alert = UIAlertController(title: "Location Services", message: "The device's location servics are turned off. Please turn on to use this app", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // Authorized when this app is in the foreground.
            print("Showing location when in use")
            mapView.showsUserLocation = true
            startTrackingUserLocation()
            break
        case .denied: // Authorization to use location services for this app have been denied.
            break
        case .notDetermined: // The user has not set the permission.
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: // The user is not ble to set e.g., a child using a parental controlled device.
            break
        case .authorizedAlways: // Enabled always, even if the app is in the background.
            print("Showing location always")
            mapView.showsUserLocation = true
            startTrackingUserLocation()
            break
        @unknown default:
            break
        }
    }
    
    func setUpLocationManager() {
        locationManager.delegate=self // Tells the location manager where to recieve update events.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set the accuracy to best.
    }
    
    func centeriewOnUserLocation() {
        print("Centering view")
        if let location = locationManager.location?.coordinate {
            let span = MKCoordinateSpan.init(latitudeDelta: regionMeters, longitudeDelta: regionMeters)
            let region = MKCoordinateRegion.init(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Gets the center of the map
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Bundles up the code we are calling from the switch, to make the switch statement cleaner (NOTE: no harm in refactoring as ou go).
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centeriewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }

    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            //TODO : Show the user an error
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error ) in
            guard let response = response else { return }
            
            for route in response.routes {
                // Extra task, display all the steps in a table view
                // let steps = route.steps
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true )
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark:  destination)
        request.requestsAlternateRoutes = false
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel}
    }
}

// Class extensions are ways of moving specific code outside of the main class to keep it tidy. This is mainly used for writing delegate handlers.
extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        print("Did update location")
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        let span = MKCoordinateSpan.init(latitudeDelta: regionMeters, longitudeDelta: regionMeters)
//        let region = MKCoordinateRegion.init(center: center, span: span)
//        mapView.setRegion(region, animated: true)
//
//    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status:
        CLAuthorizationStatus) {
        print("Did local Auth")
        checkLocationAuth()
        
    }
}

// Changing the region of the map changes.
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region did change")
        // Getting the center location of the map and the point of the pin.
        let center = getCenterLocation(for: mapView)
        // Initialize the GeoCoder
        let geoCoder = CLGeocoder()
        
        // Guard statement to protect if previous location is empty.
        guard let previousLocation = self.previousLocation else { return }
        
        // Guard statement to stop the reverseGeo code firing is we have moved less than 50 meters.
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) {
            [weak self] (placemarks, error) in
            
            if let _ = error {
                //TODO: Show alert informing user.
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert for error.
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            // We are inside a completion handler (seperate thread) here, so to get back to the main thread do this: {
            DispatchQueue.main.async {
                self?.addressLabelOutlet.text = "\(streetNumber) \(streetName)"
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}
