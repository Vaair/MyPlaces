//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 02.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) { //добавление в бд
        try! realm.write {
            realm.add(place)
        }
    }
}
