//
//  ViewController.swift
//  LimaL09
//

import UIKit
import SocketIO
import SwiftyJSON

class ViewController: UIViewController, ProximityContentManagerDelegate {
    
    let socket = SocketIOClient(socketURL: "jeloy.azurewebsites.net:80", options: [.Log(true), .ForcePolling(true)])
    var currentbeacon = ""

    @IBOutlet weak var current_percent: UILabel!
    @IBOutlet weak var beacon4: UITextView!
    @IBOutlet weak var beacon3: UITextView!
    @IBOutlet weak var beacon2: UITextView!
    @IBOutlet weak var beacon1: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var team: UITextView!
    @IBOutlet weak var points_red: UILabel!
    @IBOutlet weak var points_blue: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var proximityContentManager: ProximityContentManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.startAnimating()

        self.proximityContentManager = ProximityContentManager(
            beaconIDs: [
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 20479, minor: 18538), //Lima
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 43101, minor: 17907), //Santiago
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 32718, minor: 63524),  //Gang
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 34726, minor: 4762),  //Shanghai
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 5909, minor: 28213)  //Blomster
            ],
            beaconContentFactory: EstimoteCloudBeaconDetailsFactory())
        self.proximityContentManager.delegate = self
        self.proximityContentManager.startContentUpdates()
        
        self.socket.on("connect") {data, ack in
            print("socket connected")
            self.socket.emit("join")
        }
        
        self.socket.on("joined") {data, ack in
            let json = JSON(data)
            if let team = json[0]["team"].string {
                if(team == "red"){
                    self.team.backgroundColor = UIColor.redColor()
                } else if (team == "blue"){
                    self.team.backgroundColor = UIColor.blueColor()
                }
            }
        }
        
        self.socket.on("teams") {data, ack in
            let json = JSON(data)
            
            if let points_blue = json[0]["blue"]["score"].int {
                self.points_blue.text = String(points_blue)
            }
            if let points_red = json[0]["red"]["score"].int {
                self.points_red.text = String(points_red)
            }
        }
        
        self.socket.on("beacons") {data, ack in
            let json = JSON(data)
            
            if(self.currentbeacon != ""){
                let currentbeacon_score = json[0][self.currentbeacon]["score"]
                self.current_percent.text = String(currentbeacon_score) + "%"
                print(currentbeacon_score)
            }
            
            if let beacon1_cappedby = json[0]["Lima"]["cappedby"].int {
                self.beacon1.text = "Lima"
                
                if(beacon1_cappedby == 1){
                    self.beacon1.backgroundColor = UIColor.redColor()
                } else if (beacon1_cappedby == 0){
                    self.beacon1.backgroundColor = UIColor.grayColor()
                } else if (beacon1_cappedby == -1){
                    self.beacon1.backgroundColor = UIColor.blueColor()
                }
            }
            
            if let beacon2_cappedby = json[0]["Santiago"]["cappedby"].int {
                self.beacon2.text = "Santiago"
                
                if(beacon2_cappedby == 1){
                    self.beacon2.backgroundColor = UIColor.redColor()
                } else if (beacon2_cappedby == 0){
                    self.beacon2.backgroundColor = UIColor.grayColor()
                } else if (beacon2_cappedby == -1){
                    self.beacon2.backgroundColor = UIColor.blueColor()
                }
            }
        
            if let beacon3_cappedby = json[0]["Shanghai"]["cappedby"].int {
                self.beacon3.text = "Shanghai"
                
                if(beacon3_cappedby == 1){
                    self.beacon3.backgroundColor = UIColor.redColor()
                } else if (beacon3_cappedby == 0){
                    self.beacon3.backgroundColor = UIColor.grayColor()
                } else if (beacon3_cappedby == -1){
                    self.beacon3.backgroundColor = UIColor.blueColor()
                }
            }
            
            if let beacon4_cappedby = json[0]["Buenos Aires"]["cappedby"].int {
                self.beacon4.text = "Buenos Aires"
                
                if(beacon4_cappedby == 1){
                    self.beacon4.backgroundColor = UIColor.redColor()
                } else if (beacon4_cappedby == 0){
                    self.beacon4.backgroundColor = UIColor.grayColor()
                } else if (beacon4_cappedby == -1){
                    self.beacon4.backgroundColor = UIColor.blueColor()
                }
            }
            
        }
        
        self.socket.connect()
    }

    func proximityContentManager(proximityContentManager: ProximityContentManager, didUpdateContent content: AnyObject?) {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()

        if let beaconDetails = content as? EstimoteCloudBeaconDetails {
            
            self.socket.emit("cap", beaconDetails.beaconName)
            
            self.label.text = beaconDetails.beaconName
            self.currentbeacon = beaconDetails.beaconName
            
        } else {
            self.view.backgroundColor = EstimoteCloudBeaconDetails.neutralColor
            self.label.text = "No beacons in range."
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
