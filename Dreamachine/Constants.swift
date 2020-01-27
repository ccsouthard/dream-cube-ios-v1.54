//
//  Constants.swift
//  Dreamachine
//
//  Created by Ken on 5/3/17.
//  Copyright © 2017 charles. All rights reserved.
//

import Foundation
import UIKit

let CHANNEL_COUNTS: UInt32 = 5
let SCREEN_WIDTH: UInt32 = UInt32(UIScreen.main.bounds.width)
let SCREEN_HEIGHT: UInt32 = UInt32(UIScreen.main.bounds.height)
let FREQUENCY_MAX: Float = 46.0
let FREQUENCY_MIN: Float = 1.0

let THRESHOLD_DELTA_THETA: Float = 4.0
let THRESHOLD_THETA_ALPHA: Float = 8.0
let THRESHOLD_ALPHA_BETA: Float = 12.0
let THRESHOLD_BETA_GAMMA: Float = 40.0

let FREQUENCY_DESCRIPTION: [String: String] = [
    "delta": "Delta: Deep Sleep",
    "theta": "Theta: Hypnagogic Imagery/Meditation",
    "alpha": "Alpha: Creativity/Meditation",
    "beta" : "Beta: Concentration",
    "gamma": "Gamma: Problem Solving"
]

let COLORS: [String] = [
    "00A7F7",
    "3E4EB8",
    "6734BA",
    "00BCD6",
    "47B04B",
    "FFED18",
    "FEC100",
    "FE9800",
    "EC1561",
    "9D1BB2",
    "212121",
    "9E9E9E"
]

let URL_OF_HOW_IT_WORKS = "http://dreamachine.co/"
let URL_OF_ABOUT = "http://dreamachine.co/"
let URL_OF_FAQ = "http://dreamachine.co/"



