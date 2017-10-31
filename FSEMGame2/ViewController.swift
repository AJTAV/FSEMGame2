//
//  ViewController.swift
//  FSEMGame
//
//  Created by Addison Thomas on 10/12/17.
//  Copyright © 2017 Addison Thomas. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    // Member variables for the multipeer conformance
    var mctype: String = "FSEMGame";
    var peerid: MCPeerID
    var advertizer: MCAdvertiserAssistant
    var mcsession: MCSession
    var joinedplayers: [Int] = []
    
   
    @IBOutlet weak var JoinButtonOutlet: UIButton!
    @IBOutlet weak var DisconnectButtonOutlet: UIButton!
    
    
    //initialize the variables and call super
    required init?(coder aDecoder: NSCoder) {
        
        peerid = MCPeerID(displayName: UIDevice.current.name)
        mcsession = MCSession(peer: peerid, securityIdentity: nil, encryptionPreference: .optional)
        advertizer = MCAdvertiserAssistant(serviceType: mctype, discoveryInfo: nil, session: mcsession)
        super.init(coder: aDecoder)
        mcsession.delegate = self
        
    }
    //start the advertizer after the initial view loads
    override func viewDidLoad(){
        super.viewDidLoad()
        peerid = SettingMCpeerID()
        advertizer.start()
    }
    //IBactions for the buttons that are in the view
    @IBAction func Disconnect(_ sender: Any) {
        mcsession.disconnect();
    }
    
    @IBAction func test(_ sender: Any) {
        var browser = MCBrowserViewController(serviceType: mctype, session: mcsession)
        browser.delegate = self
        present(browser, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Browser related events
    //-------------------------
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    //----------------------------------------------
    //End of Browser related evevents
    //Session related events. data, changed state, resources, etc.
    //----------------------------------------------
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Did change state");
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print(peerID.displayName);
                self.JoinButtonOutlet.isHidden = true;
               self.DisconnectButtonOutlet.isHidden = false;
                break;
            case .connecting:
                self.JoinButtonOutlet.isHidden = true
                self.DisconnectButtonOutlet.isHidden = false;
                break;
                
            case .notConnected:
                self.JoinButtonOutlet.isHidden = false;
                self.DisconnectButtonOutlet.isHidden = true;
                break;
            }
        }
    }
    
    
    
    enum cmd: String {
        case A = "A"
        case B = "B"
        case C = "C"
        
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
           
        let recieveddata = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let parcedstring = recieveddata.components(separatedBy: ":")
        let command: cmd = cmd(rawValue: parcedstring[0])!
            
        switch command {
        case .A:
            break;
        default:
            print("Command Does Not Exist in the Switch")
        
        }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
    //----------------------------------------------
    // End of Session related Events
    
    func SettingMCpeerID() -> MCPeerID {
        let displayname = UIDevice.current.name
        let kdisplaynamekey: String = "kdisplaynamekey"
        let defaults = UserDefaults.standard
        let olddisplayname = defaults.string(forKey: kdisplaynamekey)
        let kpeerIDkey: String = "kpeerIDkey"
        var peerID: MCPeerID? = nil
        if olddisplayname == displayname {
            let peeriddata = defaults.data(forKey: kpeerIDkey)
            peerID = (NSKeyedUnarchiver.unarchiveObject(with: peeriddata!) as! MCPeerID)
        } else {
            peerID = MCPeerID(displayName: UIDevice.current.name)
            let peeriddata = NSKeyedArchiver.archivedData(withRootObject: peerID as Any)
            defaults.set(peeriddata, forKey: kpeerIDkey)
            defaults.set(displayname, forKey: kdisplaynamekey)
            defaults.synchronize()
        }
        return peerID!
    }
    
    func SendData(value: String) {
        do {
            try mcsession.send(value.data(using: String.Encoding.utf8)!, toPeers: mcsession.connectedPeers, with: .reliable)
        } catch {
            print("Attempt to send data failed")
        }
    }
    
    
    
    
}

