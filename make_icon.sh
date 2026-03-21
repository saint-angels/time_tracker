#!/bin/bash
set -e

cat > /tmp/make_icon.swift << 'EOF'
import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

NSColor(red: 1.0, green: 0.95, blue: 0.0, alpha: 1.0).setFill()
NSRect(origin: .zero, size: size).fill()

let ctx = NSGraphicsContext.current!.cgContext

ctx.saveGState()
ctx.translateBy(x: 512, y: 512)
ctx.rotate(by: -.pi / 4)

let pillWidth: CGFloat = 300
let pillHeight: CGFloat = 700
let pillRect = CGRect(x: -pillWidth / 2, y: -pillHeight / 2, width: pillWidth, height: pillHeight)

// Fill top half black
ctx.saveGState()
let topHalf = CGRect(x: -pillWidth / 2, y: 0, width: pillWidth, height: pillHeight / 2)
let clipPath = NSBezierPath(roundedRect: pillRect, xRadius: pillWidth / 2, yRadius: pillWidth / 2)
clipPath.addClip()
NSColor.black.withAlphaComponent(0.9).setFill()
topHalf.fill(using: .sourceOver)
ctx.restoreGState()

NSColor.black.withAlphaComponent(0.9).setStroke()

// Pill outline
let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: pillWidth / 2, yRadius: pillWidth / 2)
pillPath.lineWidth = 3
pillPath.stroke()

// Divider line
let line = NSBezierPath()
line.lineWidth = 3
line.move(to: NSPoint(x: -pillWidth / 2, y: 0))
line.line(to: NSPoint(x: pillWidth / 2, y: 0))
line.stroke()

ctx.restoreGState()

image.unlockFocus()

let tiff = image.tiffRepresentation!
let bitmap = NSBitmapImageRep(data: tiff)!
let png = bitmap.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "/tmp/cycle_icon.png"))
EOF

swift /tmp/make_icon.swift

rm -rf /tmp/Cycle.iconset
mkdir -p /tmp/Cycle.iconset
for size in 16 32 128 256 512; do
    sips -z $size $size /tmp/cycle_icon.png --out /tmp/Cycle.iconset/icon_${size}x${size}.png > /dev/null 2>&1
    double=$((size * 2))
    sips -z $double $double /tmp/cycle_icon.png --out /tmp/Cycle.iconset/icon_${size}x${size}@2x.png > /dev/null 2>&1
done
iconutil -c icns /tmp/Cycle.iconset -o Sources/Tracker/Resources/AppIcon.icns

echo "Built AppIcon.icns"
