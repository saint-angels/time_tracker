import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panelController: StatusBarPanelController!
    private let timer = TrackerTimer()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: 56)
        if let button = statusItem.button {
            button.title = timer.displayMinutes
            button.action = #selector(togglePanel)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let contentView = PopoverContentView(timer: timer)
        panelController = StatusBarPanelController(
            statusItem: statusItem,
            content: contentView,
            size: NSSize(width: 220, height: 220)
        )

        timer.$displayMinutes
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.statusItem.button?.title = text
            }
            .store(in: &cancellables)

        timer.$flashBreakReminder
            .receive(on: RunLoop.main)
            .filter { $0 }
            .sink { [weak self] _ in
                self?.flashMenuBar()
                self?.timer.flashBreakReminder = false
            }
            .store(in: &cancellables)
    }

    private func flashMenuBar() {
        guard let button = statusItem.button, let layer = button.layer else { return }
        button.wantsLayer = true
        let flash = CAKeyframeAnimation(keyPath: "backgroundColor")
        let green = NSColor.systemGreen.withAlphaComponent(0.6).cgColor
        let clear = CGColor.clear
        flash.values = [clear, green, clear]
        flash.keyTimes = [0, 0.3, 1.0]
        flash.duration = 0.8
        flash.isRemovedOnCompletion = true
        layer.add(flash, forKey: "flash")
    }

    @objc private func togglePanel(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showContextMenu(sender)
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        panelController.toggle()
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
}
