//
//  CouponDao.swift
//  Et3am
//
//  Created by Jets39 on 5/27/19.
//  Copyright © 2019 Ahmed M. Hassan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CouponDao {
    
    public static let shared = CouponDao()
    private init() {}
    
    public func getReceivedCoupons(completionHandler:@escaping (NSMutableArray, [Restaurant], NSMutableArray,APIResponse) -> Void) {
        let couponBarcode:NSMutableArray = []
        let useDate:NSMutableArray = []
        let restaurantObject = Restaurant()
        var restaurantArray = [Restaurant]()
        var urlComponents = URLComponents(string: Et3amAPI.baseCouponUrlString+CouponURLQueries.used_coupon.rawValue)
        urlComponents?.queryItems = [URLQueryItem(name: "userId", value:UserDao.shared.userDefaults.string(forKey: "userId"))]
        print(urlComponents!)
        Alamofire.request(urlComponents!).validate(statusCode: 200..<500).responseJSON
            { response in
                switch response.result {
                case .success:
                    guard let responseValue = response.result.value else {
                        return
                    }
                    let json = JSON(responseValue)
                    
                    print(json)
                    let codeDataDictionary:Int =  json["code"].int ?? 0
                    if(codeDataDictionary == 1)
                    {
                        guard let couponDataDictionary = json["Coupons"].array else {
                            return
                        }
                        
                        for i in 0 ..< couponDataDictionary.count {
                            let restaurantsJson = couponDataDictionary[i]["restaurants"]
                            restaurantObject.restaurantName = restaurantsJson["restaurantName"].string
                            restaurantObject.latitude = restaurantsJson["latitude"].double
                            restaurantObject.longitude = restaurantsJson["longitude"].double
                            restaurantArray.append(restaurantObject)
                            let barcode = couponDataDictionary[i]["userReserveCoupon"]["coupons"]["couponBarcode"].string
                            couponBarcode[i] = barcode?.substring(to:(barcode?.index((barcode?.startIndex)!, offsetBy: 3))!) ?? 0
                            useDate[i] =  (couponDataDictionary[i]["useDate"].double ?? 0) / 1000
                        }
                    }
                    completionHandler(useDate ,restaurantArray ,couponBarcode ,.success(codeDataDictionary))
                case .failure(let error):
                    
                    print(error.localizedDescription)
                    completionHandler([],[],[],.failure(error))
                }
        }
    }
    
    
    public func addCoupon(value_50:String, value_100:String, value_200:String, completionHandler:@escaping (Int)->Void) {
        
        var couponDonate : String = ""
        var urlComponents = URLComponents(string: Et3amAPI.baseCouponUrlString+CouponURLQueries.add.rawValue)
        urlComponents?.queryItems = [URLQueryItem(name: CouponURLQueries.user_idQuery.rawValue , value:
            UserHelper.getUser_Id()),
                                     URLQueryItem(name: CouponURLQueries.value_50Query.rawValue , value: value_50),
                                     URLQueryItem(name: CouponURLQueries.value_100Query.rawValue , value: value_100),
                                     URLQueryItem(name: CouponURLQueries.value_200Query.rawValue , value: value_200)]
        
        Alamofire.request((urlComponents?.url!)!).validate(statusCode: 200..<600).responseJSON{
            response in
            
            switch response.result {
            case .success:
                let sucessDataValue = response.result.value
                let returnedData = sucessDataValue as! NSDictionary
                print (returnedData)
                let statusDataDictionary = returnedData.value(forKey: "status") as? Int ?? 0
                
                completionHandler(statusDataDictionary)
                
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(0)
            }
        }
    }
    
    func getFreeCoupon(typeURL:String, handler:@escaping (Coupon?) -> Void)    {
        
        let couponObj:Coupon! = Coupon()
        
        Alamofire.request(typeURL).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let status  = json["status"]
                if status == 1  {
                    let barCode = json["coupon"]["coupons"]["couponBarcode"].string
                    let couopnValue = json["coupon"]["coupons"]["couponValue"].float
                    couponObj.barCode = barCode
                    couponObj.couponValue = couopnValue
                    handler(couponObj)
                }
                else {
                    handler(nil)
                }
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func getInBalanceCoupon(userId:String, inBalanceHandler:@escaping ([Coupon]) -> Void){
        
        var listCoupon = [Coupon]()
        var arrRes = [[String:AnyObject]]() //Array of dictionary
        Alamofire.request("https://et3am.herokuapp.com/coupon/get_inBalance_coupon", method: .get, parameters:["user_id": userId]).validate().responseJSON{ (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let code  = json["code"]
                if code == 1 {
                    guard let coupons = json["Coupons"].arrayObject else  {return}
                    arrRes = coupons as! [[String:AnyObject]]
                    for item in arrRes {
                        let coupon:Coupon = Coupon()
                        coupon.couponID = item["couponId"] as? String
                        coupon.barCode = item["couponBarcode"] as? String
                        coupon.couponValue = item["couponValue"] as? Float
                        coupon.creationDate = self.getCreationDate(milisecond: (item["creationDate"] as? Double)!)
                        listCoupon.append(coupon)
                    }
                    inBalanceHandler(listCoupon)
                }
                else {
                    inBalanceHandler([])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getUsedCoupon(userId:String, inBalanceHandler:@escaping ([Coupon]) -> Void){
        
        var listCoupon = [Coupon]()
        var arrRes = [[String:AnyObject]]() //Array of dictionary
        Alamofire.request("https://et3am.herokuapp.com/coupon/get_all_coupon", method: .get, parameters:["user_id": userId]).validate().responseJSON{ (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let code  = json["code"]
                if code == 1 {
                    guard let coupons = json["Coupons"].arrayObject else  {return}
                    arrRes = coupons as! [[String:AnyObject]]
                    for item in arrRes {
                        let coupon:Coupon = Coupon()
                        coupon.couponID = item["couponId"] as? String
                        coupon.barCode = item["couponBarcode"] as? String
                        coupon.couponValue = item["couponValue"] as? Float
                        coupon.creationDate = self.getCreationDate(milisecond: (item["creationDate"] as? Double)!)
                        listCoupon.append(coupon)
                    }
                    inBalanceHandler(listCoupon)
                }
                else {
                    inBalanceHandler([])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func publishCoupon(couponId:String, completedHandler:@escaping (Bool) -> Void) {
        Alamofire.request("https://et3am.herokuapp.com/coupon/publish_coupon", method: .get, parameters: ["coupon_id":couponId]).validate().responseJSON{
            (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let status  = json["status"]
                if status == 1 {
                    print("true")
                    completedHandler(true)
                }else{
                    print("false")
                    completedHandler(false)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getCreationDate(milisecond: Double) -> String {
        let dateVar = Date(timeIntervalSince1970: (milisecond / 1000.0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a dd/MM/yyyy"
        let date = dateFormatter.string(from: dateVar)
        print(date)
        return date
    }
    
}
