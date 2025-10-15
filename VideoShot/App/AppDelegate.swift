//
//  AppDelegate.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import Cocoa
import RevenueCat

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var window: NSWindow?
    private var mainVC: MainViewController?
    private var dragDropVC: DragDropViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        _ = PurchaseManager.shared
        _ = AnalyticsManager.shared
        _ = ReachabilityManager.shared
        NSApp.appearance = NSAppearance(named: .darkAqua)
        window = NSWindow(
            contentRect: .init(origin: .zero, size: Constants.appSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        guard let window else { return }
        window.center()
        window.minSize = Constants.appSize
        window.maxSize = Constants.appSize

        window.title = ""
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.isReleasedWhenClosed = false
        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = true

        showDragDropScreen()
        setupMenuBar()
    }

    func showDragDropScreen() {
        guard let window else { return }
        
        dragDropVC = DragDropViewController()
        dragDropVC?.onFilesDropped = { [weak self] urls in
            guard let self else { return }
            self.showMainViewController(with: urls)
        }
        
        window.contentViewController = dragDropVC
        window.makeKeyAndOrderFront(nil)
    }
    
    private func showMainViewController(with urls: [URL] = []) {
        mainVC = MainViewController()
    
        window?.contentViewController = mainVC
        mainVC?.loadMedia(from: urls)
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(withTitle: "Show Window", action: #selector(showWindow), keyEquivalent: "")
        return menu
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            window?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        return true
    }
    
    private func setupMenuBar() {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenuItem = NSMenuItem()
        appMenuItem.title = Constants.appName
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(NSMenuItem(title: "About \(Constants.appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "Quit \(Constants.appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        mainMenu.addItem(appMenuItem)
        
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu()
        windowMenuItem.submenu = windowMenu
        windowMenuItem.title = "Window"
        
        windowMenu.addItem(NSMenuItem(title: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"))
        windowMenu.addItem(NSMenuItem(title: "Zoom", action: #selector(NSWindow.zoom(_:)), keyEquivalent: "z"))
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(NSMenuItem(title: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: ""))
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(NSMenuItem(title: "Show Window", action: #selector(showWindow), keyEquivalent: "w"))
        windowMenu.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.close), keyEquivalent: "c"))
        
        mainMenu.addItem(windowMenuItem)
        NSApplication.shared.mainMenu = mainMenu
    }
}

private extension AppDelegate {
    @objc func showWindow(_ sender: Any? = nil) {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }}
