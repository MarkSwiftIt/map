//
//  ViewController.swift
//  map
//
//  Created by Mark Goncharov on 20.07.2022.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController {

    var annotationsArray = [MKPointAnnotation]()

//MARK: - MK MapView
    
    let mapView: MKMapView = {
        let mapV = MKMapView()
        mapV.translatesAutoresizingMaskIntoConstraints = false
        return mapV
    }()
    
//MARK: - Button
    
    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addAdressButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "routeButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "resetButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
//MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setConstraints()
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTupped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTupped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTupped), for: .touchUpInside)
        
        mapView.delegate = self
    }
    
//MARK: - @objc func

    @objc func addAdressButtonTupped() {
        
        alertAddAdress(title: "Add", placeholder: "Enter address") { [self] (text) in
            setupPlaceMark(adressPlace: text)
        }
    }
    
    @objc func routeButtonTupped() {
        
        for index in 0...annotationsArray.count - 2 {
            
            createDirectRequest(startCoordinate: annotationsArray[index].coordinate, destionCoordinate: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func resetButtonTupped() {
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
//MARK: - Setup PlaceMark

    private func setupPlaceMark(adressPlace: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] placeMarks, error in
            
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Server is not available")
                return
            }
            guard let placeMarks = placeMarks else { return }
            let placeMark = placeMarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            
            guard let placeMarkLocation = placeMark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 1 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
//MARK: - create Request

    private func createDirectRequest(startCoordinate: CLLocationCoordinate2D, destionCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destionLocation = MKPlacemark(coordinate: destionCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destionLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let diraction = MKDirections(request: request)
        diraction.calculate { (responce, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let responce = responce else {
                self.alertError(title: "error", message: "Route unavailable")
                return
            }
            var miniRoute = responce.routes[0]
            for route in responce.routes {
                miniRoute = (route.distance < miniRoute.distance) ? route : miniRoute
            }
            self.mapView.addOverlay(miniRoute.polyline)
        }
    }
}

//MARK: - extension

extension ViewController {
    
    func setConstraints() {
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 70),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 50),
            addAdressButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}

//MARK: - extension MK MapVie wDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay as!  MKPolyline)
        render.strokeColor = .black
        return render
    }
}

