//
//  MapViewController.swift
//  ScavengerHunt
//
//  Created by Debbie Hirshson on 1/19/25.
//
import UIKit
import MapKit
import PhotosUI

class MapViewController: UIViewController {
    @IBOutlet private weak var completedLabelView: UILabel! //Task completeness (complete/incomplete)
    @IBOutlet private weak var completedImageView: UIImageView! //Circle for task (filled == done, empty == not
    @IBOutlet weak var titleLabel: UILabel! //task title
    @IBOutlet weak var descriptionLabel: UILabel! //task description
    @IBOutlet weak var photoButton: UIButton! //attach photo
    @IBOutlet private weak var mapView: MKMapView!
    
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(MapAnnotation.self, forAnnotationViewWithReuseIdentifier: MapAnnotation.identifier)
        //                mapView.translatesAutoresizingMaskIntoConstraints = false
        //                view.addSubview(mapView)
        //
        //
        //
        //                // Set the region for the entire US
        //                let centerCoordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795)
        //                let span = MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0)  // Adjust these values for zoom level
        //                let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        //
        //                mapView.setRegion(region, animated: true)
        mapView.delegate = self
        mapView.layer.cornerRadius = 12
        updateUI()
        setDefaultRegion()
    }
    private func setDefaultRegion(){
        let coordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795) // U.S. center
                let span = MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0)  // Large span for the whole U.S.
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                // Set the region on the map view
                mapView.setRegion(region, animated: true)
    }
    private func updateUI(){
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        
        let completedImage = UIImage(systemName: task.isComplete ? "circle.badge.checkmark" : "circle")
        let color: UIColor = task.isComplete ? .systemGreen : .systemOrange
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedImageView.tintColor = color
        
        //let completeLabel = UILabel(systemName: task.isComplete ? "Completed" : "Incomplete")
        var completeLabel = ""
        if(task.isComplete){
            completeLabel = "Completed"
        }
        else{
            completeLabel = "Incomplete"
        }
        completedLabelView.text = completeLabel
        mapView.isHidden = false
        photoButton.isHidden = task.isComplete
        
    }
    private func updateMapView(){
        var coordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795) //location for US
        let span = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)  // should be zoomed out view of US
        var region = MKCoordinateRegion(center:  coordinate, span: span)
        print("task location: \(String(describing: task.imageLocation))")
        print("task hidden? \(String(describing: mapView.isHidden))")
        
        if let imageLocation = task.imageLocation {
                coordinate = imageLocation.coordinate
            region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }

        mapView.setRegion(region, animated:true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    @IBAction func didTapAttachPhotoButton(_ sender: Any) {

        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            // Request photo library access
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        // Helper method to show settings alert
                        self?.presentGoToSettings()
                    }
                }
            }
        } else {
            // Show photo picker
            presentImagePicker()
        }
    }
    private func presentImagePicker(){
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
}
extension MapViewController{
    func presentGoToSettings(){
        let alertController = UIAlertController(
            title: "Photo Access Required",
            message: "In order attach a photo to your task",
            preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            else {return }
            if UIApplication.shared.canOpenURL(settingsUrl){
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

extension MapViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]){
        picker.dismiss(animated: true)
        
        let result = results.first
        
        
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        
        print("Image location coordinate: \(location.coordinate)")
        
        guard let provider = result?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            if let error = error {
                DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
            }
            
            guard let image = object as? UIImage else { return }
            print("We have an image!")
            
            DispatchQueue.main.async { [weak self] in
                
                self?.task.set(image, with: location)
                self?.updateUI()
                self?.updateMapView()
            }
        }
    }
}
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapAnnotation.identifier, for: annotation) as?
                MapAnnotation else{ fatalError("Unable to dequeue MapAnnotationView")
        }
        annotationView.configure(with: task.image)
        return annotationView
    }
}
