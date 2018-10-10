//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
class WeatherViewController: UIViewController , CLLocationManagerDelegate , ChangeCityDelegate{
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d3975e2d52bcdb52bc758aa6cefb921f"
    

    //TODO: Declare instance variables here
    let locationManager=CLLocationManager()
    let weatherDataModel=WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var mySwitch: UISwitch!
    var selectorLabel:String="F"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        //TODO:Set up the location manager here.
        
        changeText()
        
        mySwitch.setOn(false, animated: true)
//
    }
    
   
    @IBAction func DegreeSwitch(_ sender: Any) {
        changeText()
        updateUIWithWeatherData()
    }
    
   func changeText(){
    if mySwitch.isOn{
        
        selectorLabel="C"
        weatherDataModel.temperature=weatherDataModel.temperature-Int(273.15)

      
    }else{
        
        selectorLabel="F"
        weatherDataModel.temperature=weatherDataModel.temperature+Int(273.15)
        
    }
    
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String,parameters:[String:String]){
        Alamofire.request(url,method: .get,parameters:parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Got the weather data!")
                
                let weatherJSON: JSON=JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else{
                print("Error \(response.result.error!)")
                self.cityLabel.text="Connection Issues"
                
            }
        }
        
    }

    
    
    func updateUIWithWeatherData(){
        cityLabel.text=weatherDataModel.city
        print(selectorLabel)
        temperatureLabel.text="\(weatherDataModel.temperature)°\(selectorLabel)"
        weatherIcon.image=UIImage(named: weatherDataModel.weatherIconName)
        
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateWeatherData(json:JSON){
        print(json)
        if let tempResult=json["main"]["temp"].double {
        weatherDataModel.temperature=Int(tempResult)
        let city=json["name"].stringValue
        weatherDataModel.city=city
        let weatherCondition=json["weather"][0]["id"].intValue
        weatherDataModel.condition=weatherCondition
        weatherDataModel.weatherIconName=weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIWithWeatherData()
        }
        else{
            cityLabel.text="Weather Not Available!"
        }
        
        
    }
    
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location=locations[locations.count-1]
        if location.horizontalAccuracy>0 {
            
            locationManager.stopUpdatingLocation()
            let latitude=String(location.coordinate.latitude)
            let longtitude=String(location.coordinate.longitude)
            let params:[String:String] = ["lat":latitude,"lon":longtitude,"appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text="Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {  //get triggered and text being passed
        
        let params:[String:String]=["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="changeCityName"{
           let VCDestination=segue.destination as! ChangeCityViewController
            VCDestination.delegate=self
        }
    }
    
    
    
    
}


