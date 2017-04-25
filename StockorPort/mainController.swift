//
//  mainController.swift
//  StockorPort
//
//  Created by Vicky D on 12/25/16.
//  Copyright © 2016 Ocho. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class mainController: UIViewController {
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet var timed: UIButton!
    @IBOutlet var relaxed: UIButton!
    @IBOutlet var about: UIButton!
    @IBOutlet var credits1: UILabel!
    @IBOutlet var credits2: UILabel!
    @IBOutlet var credits3: UILabel!
    @IBOutlet var credits4: UILabel!
    
    var aboutTitle = false
    var gameControl: UIViewController!
    var stockLines : [String]!
    var portLines : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = "ca-app-pub-1460536254113860/2301119436"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        about.addTarget(self, action: #selector(mainController.aboutGame), for: .touchUpInside)
        timed.addTarget(self, action: #selector(mainController.startGame(_:)), for: .touchUpInside)
        relaxed.addTarget(self, action: #selector(mainController.startGame(_:)), for: .touchUpInside)
        
        if gameControl == nil {
            gameControl = (self.storyboard?.instantiateViewController(withIdentifier: "game"))!
        }
        
        let stockFileURL = Bundle.main.path(forResource: "stocks", ofType: "txt")
        var readStocks = ""
        do {
            readStocks = try String(contentsOfFile: stockFileURL!, encoding: String.Encoding.utf8)
            stockLines = readStocks.components(separatedBy: "\r")
        } catch let error as NSError {
            print("Failed reading, Error: " + error.localizedDescription)
        }
        
        let portFileURL = Bundle.main.path(forResource: "airports", ofType: "txt")
        var readPorts = ""
        do {
            readPorts = try String(contentsOfFile: portFileURL!, encoding: String.Encoding.utf8)
            portLines = readPorts.components(separatedBy: "\n")
        } catch let error as NSError {
            print("Failed reading, Error: " + error.localizedDescription)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func aboutGame() {
        if !aboutTitle {
            credits1.textColor = UIColor.white
            credits2.textColor = UIColor.white
            credits3.textColor = UIColor.white
            credits4.textColor = UIColor.white
            timed.backgroundColor = UIColor.black
            timed.isEnabled = false
            relaxed.backgroundColor = UIColor.black
            relaxed.isEnabled = false
            about.setTitle("Back", for: .normal)
            
            aboutTitle = true
        } else {
            credits1.textColor = UIColor.black
            credits2.textColor = UIColor.black
            credits3.textColor = UIColor.black
            credits4.textColor = UIColor.black
            timed.backgroundColor = UIColor.white
            timed.isEnabled = true
            relaxed.backgroundColor = UIColor.white
            relaxed.isEnabled = true
            about.setTitle("About", for: .normal)
            
            aboutTitle = false
        }
    }
    
    func startGame(_ sender: AnyObject?) {
        slideRight(fromView: self, toView: gameControl)
        if sender === timed {
            (gameControl as! gameController).type = 0
        } else {
            (gameControl as! gameController).type = 1
        }
        (gameControl as! gameController).mainControl = self
        (gameControl as! gameController).tickers = stockLines
        (gameControl as! gameController).ports = portLines
        (gameControl as! gameController).newGame()
        
        //self.present(gameControl, animated: false, completion: nil)
    }
    
    func slideRight(fromView source : UIViewController, toView destination : UIViewController) {
        let window = UIApplication.shared.windows[0] as UIWindow;
        
        window.addSubview(destination.view)
        destination.view.frame = CGRect(x: source.view.frame.size.width ,y: 0, width: source.view.frame.size.width, height: source.view.frame.size.height)
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
            source.view.frame = CGRect(x: -source.view.frame.size.width,y: 0, width: source.view.frame.size.width, height: source.view.frame.size.height)
            destination.view.frame = CGRect(x: 0,y: 0, width: source.view.frame.size.width, height: source.view.frame.size.height)
        }) { (Bool) -> Void in
            window.rootViewController = destination
        }
    }
    
    func slideLeft(fromView source : UIViewController, toView destination : UIViewController) {
        let window = UIApplication.shared.windows[0] as UIWindow;
        
        window.addSubview(destination.view)
        destination.view.frame = CGRect(x: -source.view.frame.size.width ,y: 0, width: source.view.frame.size.width, height: source.view.frame.size.height)
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
            source.view.frame = CGRect(x: source.view.frame.size.width,y: 0, width: source.view.frame.size.width, height: source.view.frame.size.height)
            destination.view.frame = CGRect(x: 0,y: 0, width: source.view.frame.size.width, height: source.view.frame.size.height)
        }) { (Bool) -> Void in
            window.rootViewController = destination
        }
    }
}

