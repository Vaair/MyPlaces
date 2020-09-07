//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 01.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil) //отображение результатов на том же view controller
    private var places: Results<Place>! //отслеживание в реальном времени данных
    private var filteredPlaces: Results<Place>! //для отфильтрованных записей
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool{
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //var places = Place.getPlaces()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        places = realm.objects(Place.self) //именно тип, а не саму бд
        
        //setup the search controller
        searchController.searchResultsUpdater = self //получатель результатов поиска
        searchController.obscuresBackgroundDuringPresentation = false //записи будут предоставлятся как на основном экране
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController //строка поиска будет интегрирована в навигешн
        definesPresentationContext = true //убирает стороку поиска при переходе на другой экран
        
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating
        
        //        if place.image == nil {
        //            cell.imageOfPlace.image = UIImage(named: place.restaurantImage!)
        //        } else {
        //            cell.imageOfPlace.image = place.image
        //        }
        
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 85
    //    }
    
    //    //избыточный способ (несколько действий)
    //    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? //действие при swipe справа налево
    //    {
    //        let place = places[indexPath.row]
    //
    //        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
    //            StorageManager.deleteObject(place)
    //            tableView.deleteRows(at: [indexPath], with: .automatic)
    //        }
    //        return UISwipeActionsConfiguration(actions: [deleteAction])
    //    }
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            let newPlacesVC = segue.destination as! NewPlaceTableViewController
            newPlacesVC.currentPlace = place
        }
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) { //выход с экрана редактирования и сохранение данных
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        newPlaceVC.savePlace()
        //  places.append(newPlaceVC.newPlace!) //передача данных с одного view  на другой
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle() //реверс значений
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension TableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_ searchText: String){
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ ", searchText, searchText) //не зависит от регистра
        tableView.reloadData()
    }
}
