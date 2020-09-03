//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 02.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?){
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
    
    
    
    
    //тесты
//    let restaurantNames = [
//        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
//        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
//        "Speak Easy", "Morris Pub", "Вкусные истории",
//        "Классик", "Love&Life", "Шок", "Бочка"
//    ]
//
//    func savePlaces() { //метод добавления данных в бд
//
//        for place in restaurantNames {
//            let image = UIImage(named: place)
//            guard let imageData = image?.pngData() else { return }
//
//            let newPlace = Place()
//
//            newPlace.name = place
//            newPlace.location = "Moscow"
//            newPlace.type = "Type"
//            newPlace.imageData = imageData
//
//            StorageManager.saveObject(newPlace)
//        }
//
//    }
    
}
