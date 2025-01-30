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
    @IBOutlet weak var descriptionLabel: UILabel! //task description
    @IBOutlet weak var photoButton: UIButton! //attach photo
    @IBOutlet private weak var mapView: MKMapView!
    
    
    @IBOutlet weak var navTitle: UINavigationItem!
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(MapAnnotation.self, forAnnotationViewWithReuseIdentifier: MapAnnotation.identifier)
        mapView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        

        
        mapView.delegate = self
        mapView.layer.cornerRadius = 12
        navTitle.title = task.title
        mapView.isHidden = false
        setDefaultRegion()
        updateUI()
    }
    private func setDefaultRegion(){
        let coordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795) // U.S. center
                let span = MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0)  // Large span for the whole U.S.
                let region = MKCoordinateRegion(center: coordinate, span: span)
                
                // Set the region on the map view
                mapView.setRegion(region, animated: true)
        mapView.isHidden = false
    }
    private func updateUI(){
        
        descriptionLabel.text = task.description
        
        let completedImage = UIImage(systemName: task.isComplete ? "circle.badge.checkmark" : "circle")
        let color: UIColor = task.isComplete ? .systemGreen : .systemOrange
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedImageView.tintColor = color
               
        completedLabelView.text = task.title
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
                case .authorized, .limited:
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert
                    DispatchQueue.main.async {
                        self?.presentPhotoAcessOptions()
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
} //end class
extension MapViewController{
    func presentPhotoAcessOptions(){
        let alertController = UIAlertController(
            title: "Photo Access Required",
            message: "In order attach a photo to your task, we need access to your photo library",
            preferredStyle: .alert)
        
        let somePhotosAction = UIAlertAction(title: "Access some Photos", style: .default) { _ in
                self.requestPhotoLibraryPermission() { success in
                    if success {
                            if let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(appSettingsUrl) {
                                    UIApplication.shared.open(appSettingsUrl)
                                }
                            }
                        print("Limited access granted.")
                        }
                    else {
                        print("Limited access denied.")
                    }
                }
            }

            let allPhotosAction = UIAlertAction(title: "All Photo Access", style: .default) { _ in
                self.requestPhotoLibraryPermission() { success in
                    if success {
                        self.presentImagePicker()
                        print("Full access granted.")
                    } else {
                        print("Full access denied.")
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Don't Allow", style: .default) { _ in
                    print("Access denied.")
            }
            
            alertController.addAction(somePhotosAction)
            alertController.addAction(allPhotosAction)
            alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
       // switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
       // case .authorized:
         //   completion(true)
            
       // case .denied, .restricted, .notDetermined:
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite ) { status in
                switch status {
                case .authorized:
                    completion(true)
                case .denied, .restricted, .notDetermined:
                    completion(false)
                case .limited:
                    completion(true)
                @unknown default:
                    completion(false)
                }
            }
     //   case .limited:
   //         completion(true)
   //     @unknown default:
     //       completion(false)
      // }
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
