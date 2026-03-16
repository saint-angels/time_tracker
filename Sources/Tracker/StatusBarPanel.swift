import AppKit
import SwiftUI

final class StatusBarPanel: NSPanel {
    override var canBecomeKey: Bool { true }

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        isMovable = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        level = .statusBar
        isOpaque = false
        backgroundColor = .windowBackgroundColor
        hasShadow = true
        animationBehavior = .utilityWindow
        collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]
    }
}

final class StatusBarPanelController {
    private let panel: StatusBarPanel
    private let statusItem: NSStatusItem
    private var eventMonitor: Any?
    private let margin: CGFloat = 2
    var pinned = false

    init(statusItem: NSStatusItem, content: some View, size: NSSize) {
        self.statusItem = statusItem
        let rect = NSRect(origin: .zero, size: size)
        panel = StatusBarPanel(contentRect: rect)
        panel.contentView = NSHostingView(rootView: content)
    }

    var isVisible: Bool { panel.isVisible }

    func toggle() {
        if panel.isVisible {
            dismiss()
        } else {
            show()
        }
    }

    func show() {
        reposition()
        panel.alphaValue = 1
        panel.makeKeyAndOrderFront(nil)
        setButtonHighlight(true)
        startMonitoringClicks()
    }

    func dismiss() {
        if pinned { return }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.panel.orderOut(nil)
            self?.setButtonHighlight(false)
            self?.stopMonitoringClicks()
        }
    }

    private func reposition() {
        guard let buttonWindow = statusItem.button?.window else {
            panel.center()
            return
        }
        let panelSize = panel.frame.size
        let buttonFrame = buttonWindow.frame
        var x = buttonFrame.midX - panelSize.width / 2
        let y = buttonFrame.origin.y - panelSize.height - margin

        if let screen = buttonWindow.screen {
            let screenRight = screen.visibleFrame.maxX
            let screenLeft = screen.visibleFrame.origin.x
            if x + panelSize.width > screenRight {
                x = screenRight - panelSize.width - 4
            }
            if x < screenLeft {
                x = screenLeft + 4
            }
        }

        panel.setFrame(
            NSRect(x: x, y: y, width: panelSize.width, height: panelSize.height),
            display: true, animate: false
        )
    }

    private func startMonitoringClicks() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.dismiss()
        }
    }

    private func setButtonHighlight(_ highlight: Bool) {
        guard let button = statusItem.button else { return }
        button.highlight(highlight)
        // Re-assert after runloop to override system reset
        if highlight {
            DispatchQueue.main.async { [weak button] in
                button?.highlight(true)
            }
        }
    }

    private func stopMonitoringClicks() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
