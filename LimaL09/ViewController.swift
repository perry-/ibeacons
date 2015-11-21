//
//  ViewController.swift
//  LimaL09
//

import UIKit
import SocketIO

class ViewController: UIViewController, ProximityContentManagerDelegate {
    
    let socket = SocketIOClient(socketURL: "jeloy.azurewebsites.net:80", options: [.Log(true), .ForcePolling(true)])

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
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
            print("joined")
        }
        
        self.socket.connect()
    }

    func proximityContentManager(proximityContentManager: ProximityContentManager, didUpdateContent content: AnyObject?) {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()

        if let beaconDetails = content as? EstimoteCloudBeaconDetails {
            
            self.socket.emit("cap", beaconDetails.beaconName)
            
            self.label.text = beaconDetails.beaconName
            print(beaconDetails.beaconName)
        } else {
            self.view.backgroundColor = EstimoteCloudBeaconDetails.neutralColor
            self.label.text = "No beacons in range."
            self.image.hidden = true
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
