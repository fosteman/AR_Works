//
//  Functions.swift
//  ImageDetection
//
//  Created by Tim Fosteman on 2020-02-11.
//  Copyright © 2020 Fosteman's Software Solutions LLC. All rights reserved.
//

import Foundation
import AVFoundation

func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video)
    else {return}

    if device.hasTorch {
        do {
            try device.lockForConfiguration()

            if on == true {
                device.torchMode = .on // set on
            } else {
                device.torchMode = .off // set off
            }

            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}
