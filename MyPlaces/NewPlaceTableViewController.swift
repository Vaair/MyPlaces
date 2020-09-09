//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 02.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    //var newPlace = Place()
    
    var currentPlace: Place!
    var imageIsChanched = false
    var currentRating = 0.0
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: RetingControl!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        DispatchQueue.main.async { //загрузка в фоновом режиме
        //            self.newPlace.savePlaces()
        //        }
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1)) //убираем разлиновку пустых строк
        
        saveButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setupEditScreen()
        
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera) //$(PRODUCT_NAME) photo use в info.plist (privacy - camera...)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier, let mapVC = segue.destination as? MapViewController  else { return }
        
        //        guard segue.identifier == "showMap" else { return }
        
        mapVC.incomeSegueId = id
        //        let mapVC = segue.destination as! MapViewController
        
        if id == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text!
            mapVC.place.type = placeType.text!
            mapVC.place.imageData = placeImage.image?.pngData()
        }
        
    }
    
    func savePlace() {
        
        let image = imageIsChanched ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData() //конвертирование типа
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: currentRating)
        //rating: Double(ratingControl.rating)) //for first version
        
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        
        //        newPlace = Place(name: placeName.text!, //когда была структурой
        //                         location: placeLocation.text,
        //                         type: placeType.text,
        //                         image: image,
        //                         restaurantImage: nil)
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanched = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill //устранение проблем с изображением при переходе
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
            //ratingControl.rating = Int(currentPlace.rating) //for first version
            
        }
    }
    
    private func setupNavigationBar(){
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension NewPlaceTableViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию на done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(){
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: Work with image
extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true //разрешение масштабирования
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true //обрезка изображения
        
        imageIsChanched = true
        
        dismiss(animated: true)
    }
}
