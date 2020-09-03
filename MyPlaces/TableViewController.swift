//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 01.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {
    
    var places: Results<Place>! //отслеживание в реальном времени данных
    
    //var places = Place.getPlaces()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        places = realm.objects(Place.self) //именно тип, а не саму бд
        
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

//        if place.image == nil {
//            cell.imageOfPlace.image = UIImage(named: place.restaurantImage!)
//        } else {
//            cell.imageOfPlace.image = place.image
//        }

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //скругление image view
        cell.imageOfPlace.clipsToBounds = true //обрезка изображения

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) { //выход с экрана редактирования и сохранение данных
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        newPlaceVC.saveNewPlace()
      //  places.append(newPlaceVC.newPlace!) //передача данных с одного view  на другой
        tableView.reloadData()
    }
    
}
