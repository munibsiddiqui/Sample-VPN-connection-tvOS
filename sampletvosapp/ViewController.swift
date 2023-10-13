//
//  ViewController.swift
//  sampletvosapp
//
//  Created by Munib Siddiqui  on 13/10/2023.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    var providerManager: NETunnelProviderManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.loadProviderManager {
            
        }
    }

    @IBAction func connectionBtnAction(_ sender: Any) {
        self.configureVPN(serverAddress: "127.0.0.1", username: "uid", password: "pw123")

    }
    
    func loadProviderManager(completion:@escaping () -> Void) {
       NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
           if error == nil {
               self.providerManager = managers?.first ?? NETunnelProviderManager()
               completion()
           }
       }
    }
    
    func configureVPN(serverAddress: String, username: String, password: String) {
        let configData = "your_openvpn_configuration"
      self.providerManager?.loadFromPreferences { error in
         if error == nil {
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.username = username
            tunnelProtocol.serverAddress = serverAddress
             
             /*
              com.atom.sampletvosapp.tvospackettunnel -> will work perfectly fine with patch
              com.atom.sampletvosapp.tvospackettunnelfaulty -> will not work since we haven't applied the patch yet.
              */
             
            tunnelProtocol.providerBundleIdentifier = "com.atom.sampletvosapp.tvospackettunnelfaulty" // bundle id of the network extension target
            tunnelProtocol.providerConfiguration = ["ovpn": configData, "username": username, "password": password]
            tunnelProtocol.disconnectOnSleep = false
            self.providerManager.protocolConfiguration = tunnelProtocol
            self.providerManager.localizedDescription = "MyVPN" // the title of the VPN profile which will appear on Settings
            self.providerManager.isEnabled = true
            self.providerManager.saveToPreferences(completionHandler: { (error) in
                  if error == nil  {
                     self.providerManager.loadFromPreferences(completionHandler: { (error) in
                         do {
                           try self.providerManager.connection.startVPNTunnel() // starts the VPN tunnel.
                         } catch let error {
                             print(error.localizedDescription)
                         }
                     })
                  }
            })
          }
       }
    }

}

