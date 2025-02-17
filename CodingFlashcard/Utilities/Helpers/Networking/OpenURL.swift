//
//  OpenURL.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

func openURL(_ urlString: String, completion: @escaping (_ success: Bool) -> Void)  {
    if let url = URL(string: urlString) {
        UIApplication.shared.open(url, completionHandler: completion)
    }
}
