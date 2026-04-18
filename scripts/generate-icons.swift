import AppKit
import CoreGraphics
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsDir = root.appendingPathComponent("src-tauri/icons", isDirectory: true)
let tempIconset = iconsDir.appendingPathComponent("icon.iconset", isDirectory: true)

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
  let r = CGFloat((hex >> 16) & 0xff) / 255
  let g = CGFloat((hex >> 8) & 0xff) / 255
  let b = CGFloat(hex & 0xff) / 255
  return CGColor(red: r, green: g, blue: b, alpha: alpha)
}

func drawLinearGradient(
  _ ctx: CGContext,
  colors: [CGColor],
  locations: [CGFloat],
  start: CGPoint,
  end: CGPoint
) {
  let gradient = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: colors as CFArray,
    locations: locations
  )!
  ctx.drawLinearGradient(gradient, start: start, end: end, options: [])
}

func drawDrop(_ ctx: CGContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
  let path = CGMutablePath()
  path.move(to: CGPoint(x: x, y: y))
  path.addCurve(
    to: CGPoint(x: x - 44 * scale, y: y + 84 * scale),
    control1: CGPoint(x: x - 31 * scale, y: y + 33 * scale),
    control2: CGPoint(x: x - 44 * scale, y: y + 57 * scale)
  )
  path.addCurve(
    to: CGPoint(x: x, y: y + 128 * scale),
    control1: CGPoint(x: x - 44 * scale, y: y + 110 * scale),
    control2: CGPoint(x: x - 25 * scale, y: y + 128 * scale)
  )
  path.addCurve(
    to: CGPoint(x: x + 44 * scale, y: y + 84 * scale),
    control1: CGPoint(x: x + 25 * scale, y: y + 128 * scale),
    control2: CGPoint(x: x + 44 * scale, y: y + 110 * scale)
  )
  path.addCurve(
    to: CGPoint(x: x, y: y),
    control1: CGPoint(x: x + 44 * scale, y: y + 57 * scale),
    control2: CGPoint(x: x + 31 * scale, y: y + 33 * scale)
  )
  path.closeSubpath()

  ctx.addPath(path)
  ctx.setFillColor(color(0x29b6f6))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: x - 14 * scale, y: y + 54 * scale, width: 15 * scale, height: 29 * scale))
  ctx.setFillColor(color(0xffffff, 0.45))
  ctx.fillPath()
}

func drawIcon(_ ctx: CGContext) {
  ctx.saveGState()
  ctx.translateBy(x: 0, y: 1024)
  ctx.scaleBy(x: 1, y: -1)

  let bounds = CGRect(x: 48, y: 48, width: 928, height: 928)
  let rounded = CGPath(roundedRect: bounds, cornerWidth: 220, cornerHeight: 220, transform: nil)
  ctx.addPath(rounded)
  ctx.clip()

  drawLinearGradient(
    ctx,
    colors: [color(0x57d7ff), color(0x1b85e5), color(0x1553b6)],
    locations: [0, 0.56, 1],
    start: CGPoint(x: 140, y: 80),
    end: CGPoint(x: 880, y: 970)
  )

  ctx.addEllipse(in: CGRect(x: 118, y: 85, width: 880, height: 700))
  ctx.setFillColor(color(0xffffff, 0.10))
  ctx.fillPath()

  let sunCenter = CGPoint(x: 330, y: 315)
  ctx.setLineWidth(42)
  ctx.setLineCap(.round)
  ctx.setStrokeColor(color(0xfff3a3, 0.85))
  for i in 0..<8 {
    let angle = CGFloat(i) * .pi / 4
    let inner = CGPoint(x: sunCenter.x + cos(angle) * 132, y: sunCenter.y + sin(angle) * 132)
    let outer = CGPoint(x: sunCenter.x + cos(angle) * 205, y: sunCenter.y + sin(angle) * 205)
    ctx.move(to: inner)
    ctx.addLine(to: outer)
    ctx.strokePath()
  }

  ctx.saveGState()
  ctx.addEllipse(in: CGRect(x: 205, y: 190, width: 250, height: 250))
  ctx.clip()
  drawLinearGradient(
    ctx,
    colors: [color(0xfff6a5), color(0xffb347)],
    locations: [0, 1],
    start: CGPoint(x: 245, y: 205),
    end: CGPoint(x: 430, y: 430)
  )
  ctx.restoreGState()

  ctx.setShadow(offset: CGSize(width: 0, height: 36), blur: 44, color: color(0x062a67, 0.33))
  let cloud = CGMutablePath()
  cloud.addEllipse(in: CGRect(x: 226, y: 430, width: 280, height: 265))
  cloud.addEllipse(in: CGRect(x: 390, y: 345, width: 330, height: 330))
  cloud.addEllipse(in: CGRect(x: 610, y: 455, width: 215, height: 220))
  cloud.addRoundedRect(in: CGRect(x: 205, y: 545, width: 650, height: 215), cornerWidth: 100, cornerHeight: 100)
  ctx.addPath(cloud)
  ctx.setFillColor(color(0xf6fbff))
  ctx.fillPath()
  ctx.setShadow(offset: .zero, blur: 0, color: nil)

  let cloudTint = CGMutablePath()
  cloudTint.addRoundedRect(in: CGRect(x: 260, y: 648, width: 520, height: 78), cornerWidth: 36, cornerHeight: 36)
  ctx.addPath(cloudTint)
  ctx.setFillColor(color(0xd5eefc, 0.92))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: 422, y: 386, width: 220, height: 118))
  ctx.setFillColor(color(0xffffff, 0.38))
  ctx.fillPath()

  drawDrop(ctx, x: 334, y: 745, scale: 0.78)
  drawDrop(ctx, x: 512, y: 780, scale: 0.92)
  drawDrop(ctx, x: 692, y: 745, scale: 0.78)

  ctx.restoreGState()
}

func pngData(size: Int) -> Data {
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )!
  rep.size = NSSize(width: size, height: size)

  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  let ctx = NSGraphicsContext.current!.cgContext
  ctx.interpolationQuality = .high
  ctx.setShouldAntialias(true)
  ctx.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)
  drawIcon(ctx)
  NSGraphicsContext.restoreGraphicsState()

  return rep.representation(using: .png, properties: [:])!
}

func writePNG(_ name: String, size: Int) throws {
  try pngData(size: size).write(to: iconsDir.appendingPathComponent(name))
}

func appendLE16(_ value: UInt16, to data: inout Data) {
  var v = value.littleEndian
  withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func appendLE32(_ value: UInt32, to data: inout Data) {
  var v = value.littleEndian
  withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
}

func writeICO() throws {
  let sizes = [16, 32, 48, 64, 128, 256]
  let images = sizes.map { pngData(size: $0) }
  var offset = UInt32(6 + sizes.count * 16)
  var ico = Data()

  appendLE16(0, to: &ico)
  appendLE16(1, to: &ico)
  appendLE16(UInt16(sizes.count), to: &ico)

  for (size, image) in zip(sizes, images) {
    ico.append(UInt8(size == 256 ? 0 : size))
    ico.append(UInt8(size == 256 ? 0 : size))
    ico.append(0)
    ico.append(0)
    appendLE16(1, to: &ico)
    appendLE16(32, to: &ico)
    appendLE32(UInt32(image.count), to: &ico)
    appendLE32(offset, to: &ico)
    offset += UInt32(image.count)
  }

  for image in images {
    ico.append(image)
  }

  try ico.write(to: iconsDir.appendingPathComponent("icon.ico"))
}

try FileManager.default.createDirectory(at: iconsDir, withIntermediateDirectories: true)

let pngTargets: [(String, Int)] = [
  ("icon.png", 512),
  ("32x32.png", 32),
  ("128x128.png", 128),
  ("128x128@2x.png", 256),
  ("StoreLogo.png", 50),
  ("Square30x30Logo.png", 30),
  ("Square44x44Logo.png", 44),
  ("Square71x71Logo.png", 71),
  ("Square89x89Logo.png", 89),
  ("Square107x107Logo.png", 107),
  ("Square142x142Logo.png", 142),
  ("Square150x150Logo.png", 150),
  ("Square284x284Logo.png", 284),
  ("Square310x310Logo.png", 310)
]

for (name, size) in pngTargets {
  try writePNG(name, size: size)
}

try? FileManager.default.removeItem(at: tempIconset)
try FileManager.default.createDirectory(at: tempIconset, withIntermediateDirectories: true)

let iconsetTargets: [(String, Int)] = [
  ("icon_16x16.png", 16),
  ("icon_16x16@2x.png", 32),
  ("icon_32x32.png", 32),
  ("icon_32x32@2x.png", 64),
  ("icon_128x128.png", 128),
  ("icon_128x128@2x.png", 256),
  ("icon_256x256.png", 256),
  ("icon_256x256@2x.png", 512),
  ("icon_512x512.png", 512),
  ("icon_512x512@2x.png", 1024)
]

for (name, size) in iconsetTargets {
  try pngData(size: size).write(to: tempIconset.appendingPathComponent(name))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = [
  "-c", "icns",
  "-o", iconsDir.appendingPathComponent("icon.icns").path,
  tempIconset.path
]
try iconutil.run()
iconutil.waitUntilExit()
guard iconutil.terminationStatus == 0 else {
  throw NSError(domain: "IconGeneration", code: Int(iconutil.terminationStatus))
}
try? FileManager.default.removeItem(at: tempIconset)

try writeICO()

print("Generated weather app icons in \(iconsDir.path)")
