//
//  main.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
