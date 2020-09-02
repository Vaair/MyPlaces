//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 02.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView() //убираем разлиновку пустых строк
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }
   

}

extension NewPlaceTableViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию на done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
