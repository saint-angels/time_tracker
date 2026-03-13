import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panelController: StatusBarPanelController!
    private let timer = TrackerTimer()
    private var cancellables = Set<AnyCancellable>()
    private var pulseTimer: Timer?
    private let spotifyGreen = NSColor(red: 0.114, green: 0.725, blue: 0.329, alpha: 1.0)

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
                if self.timer.mode != .break {
                    self.statusItem.button?.title = text
                }
            }
            .store(in: &cancellables)

        timer.$mode
            .receive(on: RunLoop.main)
            .sink { [weak self] mode in
                if mode == .break {
                    self?.startPulse()
                } else {
                    self?.stopPulse()
                }
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

    private func startPulse() {
        pulseTimer?.invalidate()
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.updatePulseColor()
        }
    }

    private func stopPulse() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        if let button = statusItem.button {
            button.title = timer.displayMinutes
        }
    }

    private func updatePulseColor() {
        guard let button = statusItem.button else { return }
        let t = Date().timeIntervalSinceReferenceDate
        let phase = CGFloat((sin(t * 1.5) + 1) / 2) // 0..1, ~4s full cycle
        let r = 1.0 + (spotifyGreen.redComponent - 1.0) * phase
        let g = 1.0 + (spotifyGreen.greenComponent - 1.0) * phase
        let b = 1.0 + (spotifyGreen.blueComponent - 1.0) * phase
        let color = NSColor(red: r, green: g, blue: b, alpha: 1.0)
        button.attributedTitle = NSAttributedString(
            string: timer.displayMinutes,
            attributes: [.foregroundColor: color]
        )
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
