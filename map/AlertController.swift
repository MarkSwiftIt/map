//
//  AlertController.swift
//  map
//
//  Created by Mark Goncharov on 20.07.2022.
//

import UIKit


extension ViewController {
    
//MARK: - Alert AddAdress
    
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let acrtionSheet = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
        }
        alertController.addTextField() { (tf) in
            tf.placeholder = placeholder
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        alertController.addAction(acrtionSheet)
        alertController.addAction(alertCancel)
        present(alertController, animated: true, completion: nil)
    }
    
//MARK: - Alert Error
    
    func alertError(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let acrtionSheet = UIAlertAction(title: "Ok", style: .default)

        alertController.addAction(acrtionSheet)
        present(alertController, animated: true, completion: nil)
    }
}
