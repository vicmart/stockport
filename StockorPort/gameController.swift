//
//  ViewController.swift
//  StockorPort
//
//  Created by Vicky D on 12/24/16.
//  Copyright © 2016 Ocho. All rights reserved.
//

import UIKit
import GoogleMobileAds

class gameController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet var progLabel: UILabel!
    @IBOutlet var stock: UIButton!
    @IBOutlet var airport: UIButton!
    @IBOutlet var pause: UIButton!

    @IBAction func pressDownStock(sender: UIButton) {
        if !paused {
            sender.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.75)
        }
    }
    
    @IBAction func pressUpStock(sender: UIButton) {
        if !paused {
            sender.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        }
    }
    
    @IBAction func pressDownAirport(sender: UIButton) {
        if done == 0 {
            sender.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        }
    }
    
    @IBAction func pressUpAirport(sender: UIButton) {
        if done == 0 {
            sender.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var tickers = ["APL", "HPQ", "TXN", "TGT", "DOW", "SFO"]
    var ports = ["SFO", "EWR", "JFK", "LAX", "LGA"]

    var timeTaken = 0.0
    var timeUnaltered = 0.0
    let shapeLayer = CAShapeLayer()
    var radius = CGFloat(100)
    var correct = 0.75
    var incorrect = 0.75
    var done = 0
    var paused = false
    var pausedText = ""
    var flashing = false
    
    var type = 0
    var numCorrect = 0
    var numIncorrect = 0
    var currentBound = 20
    var level = 1
    
    var mainControl: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = "ca-app-pub-1460536254113860/2301119436"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        stock.addTarget(self, action: #selector(gameController.buttonClicked(_:)), for: .touchUpInside)
        airport.addTarget(self, action: #selector(gameController.buttonClicked(_:)), for: .touchUpInside)
        pause.addTarget(self, action: #selector(gameController.pausedGame(_:)), for: .touchUpInside)

        _ = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(update), userInfo: nil, repeats: true);
        

        let xPos = textLabel.frame.origin.x + (textLabel.frame.size.width/2)
        let yPos = textLabel.frame.origin.y + (textLabel.frame.size.height/2)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: xPos,y: yPos), radius: radius, startAngle: CGFloat(M_PI * 1.5), endAngle:CGFloat(M_PI * 1.5), clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2.0

        view.layer.addSublayer(shapeLayer)
        
        timerLabel.textColor = UIColor.clear
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonClicked(_ sender: AnyObject?) {
        if done == 0 && !paused {
            if sender === stock {
                if tickers.contains(textLabel.text!) {
                    flashGreen()
                } else {
                    flashRed()
                }
            } else if sender === airport {
                if ports.contains(textLabel.text!) {
                    flashGreen()
                } else {
                    flashRed()
                }
            }
            
            let type = randomInt(min: 0, max: 1)
            if type == 0 {
                var index = randomInt(min: 0, max: min(currentBound, tickers.count - 1))
                while ports.contains(tickers[index]) {
                    index = randomInt(min: 0, max: min(currentBound, tickers.count - 1))
                }
                textLabel.text = tickers[index]
            } else {
                var index = randomInt(min: 0, max: min(currentBound, ports.count - 1))
                while tickers.contains(ports[index]) {
                    index = randomInt(min: 0, max: min(currentBound, ports.count - 1))
                }
                textLabel.text = ports[index]
            }
        } else if done == 0 && paused {
            if sender === stock {
                paused = false
                textLabel.text = pausedText
                
                stock.setTitle("Stock", for: .normal)
                airport.setTitle("Airport", for: .normal)
                
                stock.backgroundColor = UIColor.green
                pause.isEnabled = true
                pause.setTitleColor(UIColor .white, for: UIControlState.normal)
            } else {
                quit()
                //self.dismiss(animated: false, completion: nil)
            }
        } else {
            if sender === stock {
                newGame()
            } else {
                quit()
                //self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func flashGreen() {
        timeTaken -= correct
        currentBound += 1
        if (currentBound % 10) == 0 {
            level += 1
        }
        numCorrect += 1
        
        if !flashing {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
                self.view.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)
            }) { (Bool) -> Void in
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
                    self.view.backgroundColor = UIColor.black
                }, completion: nil)
            }
        }
    }
    
    func flashRed() {
        timeTaken += incorrect
        numIncorrect += 1
        
        if !flashing {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
                self.view.backgroundColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1.0)
            }) { (Bool) -> Void in
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
                    self.view.backgroundColor = UIColor.black
                }, completion: nil)
            }
        }
    }
    
    func flashYellow() {
        flashing = true
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
            self.view.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0, alpha: 0.75)
        }) { (Bool) -> Void in
            UIView.animate(withDuration: 0.35, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
                self.view.backgroundColor = UIColor.black
            }) { (Bool) -> Void in
                self.flashing = false
            }
        }
    }
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func update() {
        let xPos = textLabel.frame.origin.x + (textLabel.frame.size.width/2)
        let yPos = textLabel.frame.origin.y + (textLabel.frame.size.height/2)
        
        if type == 0 {
            if !paused {
                timeTaken = timeTaken + 0.025
                timeUnaltered = timeUnaltered + 0.025
            }
            
            
            if done == 0 {
                let current = (M_PI * 0.75) + (Double(timeTaken) / M_PI)
            
                if current > M_PI * 1.25 && !paused {
                    if !flashing {
                        flashYellow()
                    }
                }
                
                if current < M_PI * -0.5 {
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: xPos,y: yPos), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
                    
                    shapeLayer.path = circlePath.cgPath

                    finished()
                    done = 1
                } else if current < M_PI * 1.5 {
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: xPos,y: yPos), radius: radius, startAngle: CGFloat(current), endAngle:CGFloat(M_PI * 1.5), clockwise: true)
                    
                    shapeLayer.path = circlePath.cgPath
                } else {
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: xPos,y: yPos), radius: radius, startAngle: CGFloat(M_PI * 1.5), endAngle:CGFloat(M_PI * 1.5), clockwise: true)
                    
                    shapeLayer.path = circlePath.cgPath

                    finished()
                    done = -1
                }
            }
        } else if type == 1 {
            let percent = Double(numCorrect) / Double(numCorrect + numIncorrect)
            let current = (M_PI * 1.5) - ((M_PI * 2.0) * percent)
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: xPos,y: yPos), radius: radius, startAngle: CGFloat(current), endAngle:CGFloat(M_PI * 1.5), clockwise: true)
            
            shapeLayer.path = circlePath.cgPath
        }
        progLabel.text = String(format: " Level %d", level)
    }
    
    func finished() {
        let actualTime = Int(timeUnaltered * 2)
        let min = actualTime / 60
        let sec = actualTime % 60
        
        textLabel.text = String(format: "%.2d:%.2d", min, sec)
        stock.setTitle("Play Again", for: .normal)
        airport.setTitle("Quit", for: .normal)
        stock.backgroundColor = UIColor.white
        timerLabel.textColor = UIColor.white
        pause.isEnabled = false
        pause.setTitleColor(UIColor .black, for: UIControlState.normal)
    }
    
    func pausedGame(_ sender: AnyObject?) {
        actualPause()
    }
    
    func actualPause() {
        if done == 0 && !paused {
            paused = true
            pausedText = textLabel.text!
            textLabel.text = "Paused"
            airport.setTitle("Quit", for: .normal)
            stock.setTitle("Resume", for: .normal)
            stock.backgroundColor = UIColor.white
            pause.isEnabled = false
            pause.setTitleColor(UIColor .black, for: UIControlState.normal)
        }
    }
    
    func isDone() -> Bool {
        if done == 0 {
            return false
        } else {
            return true
        }
    }
    
    func newGame() {
        done = 0
        timeTaken = 0
        timeUnaltered = 0
        numCorrect = 0
        numIncorrect = 0
        paused = false
        currentBound = 20
        level = 1
        
        stock.setTitle("Stock", for: .normal)
        airport.setTitle("Airport", for: .normal)
        
        stock.backgroundColor = UIColor.green
        timerLabel.textColor = UIColor.clear
        
        let type = randomInt(min: 0, max: 1)
        if type == 0 {
            let index = randomInt(min: 0, max: tickers.count - 1)
            textLabel.text = tickers[index]
        } else {
            let index = randomInt(min: 0, max: ports.count - 1)
            textLabel.text = ports[index]
        }
        
        pause.isEnabled = true
        pause.setTitleColor(UIColor .white, for: UIControlState.normal)
    }
    
    func quit() {
        (mainControl as! mainController).slideLeft(fromView: self, toView: mainControl)
    }
}

