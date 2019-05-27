//
//  RestaurantDetailsViewController.swift
//  Et3am
//
//  Created by Mohamed Korany Ali on 9/21/1440 AH.
//  Copyright © 1440 AH Ahmed M. Hassan. All rights reserved.
//

import UIKit

class RestaurantDetailsViewController: UIViewController {

    @IBAction func inviteFriend(_ sender: Any) {
    }
    
    @IBAction func getFreeCoupon(_ sender: Any) {
    }
    var restaurantName :String = ""
    var restaurantCountry :String = ""
    var restaurantCity:String = ""
    
    @IBOutlet weak var restuarantAndMealsTableView: UITableView!
    
    
    var restuarantObj = Restaurant()
    var mealsArray:Array<Meal> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restuarantObj.city = ""
        restuarantObj.country = ""
        restuarantObj.restaurantID=1
        restuarantObj.restaurantName = ""
        restuarantObj.image = "restaurant"
        restuarantAndMealsTableView.dataSource = self
        restuarantAndMealsTableView.delegate = self
        
        
        let restaurantDao:RestaurantDao = RestaurantDao()
        restaurantDao.fetchJsonForRestaurant(typeURL: "https://et3am.herokuapp.com/restaurant/rest/1", handler: {restuarant in
            DispatchQueue.main.async {
                self.restaurantName = restuarant.restaurantName!
                self.restaurantCountry =  restuarant.country!
                self.restaurantCity = restuarant.city!
                //let restuarantImg: UIImage = UIImage(named: restuarant.image!)!
                // self.restaurantImage.image = restuarantImg
            }
        })
        
        restaurantDao.fetchJsonForMeals(typeURL: "https://et3am.herokuapp.com/restaurant/1/meals") { fetchedArray in
            DispatchQueue.main.async {
                self.mealsArray = fetchedArray
                self.restuarantAndMealsTableView.reloadData()
            }
        }
        
        
        
        
    }
    
    
}

extension RestaurantDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "restCell", for: indexPath) as! RestaurantDetailsCell
            cell.restaurantName.text = restaurantName
            cell.restaurantCountyCity.text = restaurantCity + "," + restaurantCountry
            let image : UIImage = UIImage(named: "food")!
            cell.restaurantImage.image = image
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealCell
            cell.mealName.text = mealsArray[indexPath.row].mealName!
            let image : UIImage = UIImage(named: "food")!
            cell.mealImage.image = image
            return cell
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return mealsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "INFO"
        }
        else{
            return "Meals For You"
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 245
        } else {
            return 120
        }
    }
    
}
