import SwiftUI
import AppKit

private class TooltipPanel {
    static let shared = TooltipPanel()
    private var panel: NSPanel?

    func show(text: String, scheme: ModeScheme, near: NSPoint) {
        dismiss()
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.monospacedSystemFont(ofSize: 8, weight: .bold)
        label.textColor = NSColor(scheme.foreground).withAlphaComponent(0.8)
        label.sizeToFit()

        let padding: CGFloat = 6
        let size = NSSize(width: label.frame.width + padding * 2, height: label.frame.height + padding * 2)
        label.frame.origin = NSPoint(x: padding, y: padding)

        let p = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        p.isOpaque = false
        p.backgroundColor = NSColor(scheme.background)
        p.hasShadow = true
        p.level = .statusBar + 1
        p.contentView?.addSubview(label)

        let origin = NSPoint(x: near.x, y: near.y + 8)
        p.setFrameOrigin(origin)
        p.orderFront(nil)
        panel = p
    }

    func dismiss() {
        panel?.orderOut(nil)
        panel = nil
    }
}

struct SettingsView: View {
    @ObservedObject var settings = Settings.shared
    let scheme: ModeScheme
    var onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SETTINGS")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .tracking(4)
                .foregroundColor(scheme.accent)
                .padding(.bottom, 2)

            Rectangle()
                .fill(scheme.foreground.opacity(0.2))
                .frame(height: 0.5)

            Spacer().frame(height: 8)
            settingRow("AFK", value: $settings.afkTimeoutMinutes, unit: "MIN", range: 1...15, tip: "SWITCH TO REST AFTER NO INPUT FOR")
            Spacer().frame(height: 6)
            settingRow("REST REMINDER", value: $settings.breakReminderMinutes, unit: "MIN", range: 5...60, tip: "WORK TIME BEFORE BREAK NUDGES START")
            Spacer().frame(height: 6)
            settingRow("REST MIN", value: $settings.restDurationMinutes, unit: "MIN", range: 1...30, tip: "SWITCH TO WORK ON ANY INPUT AFTER")

            Spacer()

            HStack {
                Spacer()
                PressableButton(action: onDone) { isPressed, isHovered in
                let fg = isHovered ? scheme.hover : scheme.foreground.opacity(0.5)
                Text("DONE")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(isPressed ? scheme.background : fg)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isPressed ? fg : .clear)
                    .overlay(Rectangle().stroke(fg, lineWidth: 1))
            }
            }
        }
        .padding(12)
        .frame(width: 240, height: 160)
        .background(scheme.background)
    }

    private func settingRow(_ label: String, value: Binding<Int>, unit: String, range: ClosedRange<Int>, tip: String = "") -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(scheme.foreground.opacity(0.6))
                .onHover { hovering in
                    if hovering, !tip.isEmpty {
                        let mouse = NSEvent.mouseLocation
                        TooltipPanel.shared.show(text: tip, scheme: scheme, near: mouse)
                    } else {
                        TooltipPanel.shared.dismiss()
                    }
                }
            Spacer()
            PressableButton(action: { if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 } }) { isPressed, isHovered in
                Text("-")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(isHovered ? scheme.hover : scheme.foreground.opacity(0.5))
            }
            Text("\(value.wrappedValue) \(unit)")
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .foregroundColor(scheme.foreground)
                .frame(width: 50)
            PressableButton(action: { if value.wrappedValue < range.upperBound { value.wrappedValue += 1 } }) { isPressed, isHovered in
                Text("+")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(isHovered ? scheme.hover : scheme.foreground.opacity(0.5))
            }
        }
    }
}
