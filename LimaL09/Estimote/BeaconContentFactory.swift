//
//  BeaconContentFactory.swift
//  LimaL09
//

protocol BeaconContentFactory {

    func contentForBeaconID(beaconID: BeaconID, completion: (content: AnyObject) -> ())

}
