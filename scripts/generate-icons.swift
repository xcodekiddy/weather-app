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
  ctx.setFillColor(color(0x2ba7f4))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: x - 14 * scale, y: y + 54 * scale, width: 15 * scale, height: 29 * scale))
  ctx.setFillColor(color(0xffffff, 0.45))
  ctx.fillPath()
}

func drawSnowflake(_ ctx: CGContext, center: CGPoint, radius: CGFloat) {
  ctx.saveGState()
  ctx.translateBy(x: center.x, y: center.y)
  ctx.setLineWidth(radius * 0.14)
  ctx.setLineCap(.round)
  ctx.setStrokeColor(color(0xffffff, 0.96))
  ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 12, color: color(0x1f2937, 0.28))

  for i in 0..<6 {
    ctx.saveGState()
    ctx.rotate(by: CGFloat(i) * .pi / 3)
    ctx.move(to: CGPoint(x: 0, y: -radius))
    ctx.addLine(to: CGPoint(x: 0, y: radius))
    ctx.strokePath()

    ctx.move(to: CGPoint(x: 0, y: -radius * 0.48))
    ctx.addLine(to: CGPoint(x: -radius * 0.24, y: -radius * 0.72))
    ctx.strokePath()

    ctx.move(to: CGPoint(x: 0, y: -radius * 0.48))
    ctx.addLine(to: CGPoint(x: radius * 0.24, y: -radius * 0.72))
    ctx.strokePath()
    ctx.restoreGState()
  }

  ctx.restoreGState()
}

func drawIcon(_ ctx: CGContext) {
  ctx.saveGState()
  ctx.translateBy(x: 0, y: 1024)
  ctx.scaleBy(x: 1, y: -1)

  drawLinearGradient(
    ctx,
    colors: [color(0x010707), color(0x162126), color(0x2d281f)],
    locations: [0, 0.48, 1],
    start: CGPoint(x: 512, y: 0),
    end: CGPoint(x: 512, y: 1024)
  )

  ctx.setBlendMode(.screen)
  ctx.addEllipse(in: CGRect(x: 178, y: 32, width: 660, height: 530))
  ctx.setFillColor(color(0x8bdcff, 0.34))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: 96, y: 252, width: 780, height: 620))
  ctx.setFillColor(color(0xffd38a, 0.26))
  ctx.fillPath()
  ctx.setBlendMode(.normal)

  ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 78, color: color(0x9ee7ff, 0.58))
  let tile = CGRect(x: 196, y: 198, width: 632, height: 608)
  let tilePath = CGPath(roundedRect: tile, cornerWidth: 132, cornerHeight: 132, transform: nil)
  ctx.addPath(tilePath)
  ctx.setFillColor(color(0xffffff, 0.28))
  ctx.fillPath()
  ctx.setShadow(offset: .zero, blur: 0, color: nil)

  ctx.saveGState()
  ctx.addPath(tilePath)
  ctx.clip()
  drawLinearGradient(
    ctx,
    colors: [color(0x85dbff), color(0xe5f4ff), color(0xffc978)],
    locations: [0, 0.57, 1],
    start: CGPoint(x: 512, y: 194),
    end: CGPoint(x: 512, y: 810)
  )

  ctx.addEllipse(in: CGRect(x: 186, y: 176, width: 648, height: 388))
  ctx.setFillColor(color(0xffffff, 0.11))
  ctx.fillPath()

  ctx.addPath(tilePath)
  ctx.setLineWidth(1.5)
  ctx.setStrokeColor(color(0xffffff, 0.35))
  ctx.strokePath()

  let sunCenter = CGPoint(x: 434, y: 462)
  ctx.setLineWidth(24)
  ctx.setLineCap(.round)
  ctx.setStrokeColor(color(0xfff63b, 0.95))
  for i in 0..<8 {
    let angle = CGFloat(i) * .pi / 4
    let inner = CGPoint(x: sunCenter.x + cos(angle) * 126, y: sunCenter.y + sin(angle) * 126)
    let outer = CGPoint(x: sunCenter.x + cos(angle) * 174, y: sunCenter.y + sin(angle) * 174)
    ctx.move(to: inner)
    ctx.addLine(to: outer)
    ctx.strokePath()
  }

  ctx.saveGState()
  ctx.addEllipse(in: CGRect(x: 316, y: 345, width: 236, height: 236))
  ctx.clip()
  drawLinearGradient(
    ctx,
    colors: [color(0xffff42), color(0xffb618)],
    locations: [0, 1],
    start: CGPoint(x: 360, y: 356),
    end: CGPoint(x: 522, y: 560)
  )
  ctx.restoreGState()

  ctx.setShadow(offset: CGSize(width: 0, height: 20), blur: 40, color: color(0x0f172a, 0.24))
  ctx.setFillColor(color(0xe8ece8, 0.78))
  ctx.addEllipse(in: CGRect(x: 252, y: 520, width: 300, height: 162))
  ctx.fillPath()
  ctx.addEllipse(in: CGRect(x: 438, y: 390, width: 268, height: 268))
  ctx.fillPath()
  ctx.addEllipse(in: CGRect(x: 632, y: 464, width: 154, height: 158))
  ctx.fillPath()
  ctx.addPath(CGPath(
    roundedRect: CGRect(x: 254, y: 518, width: 520, height: 132),
    cornerWidth: 66,
    cornerHeight: 66,
    transform: nil
  ))
  ctx.fillPath()
  ctx.setShadow(offset: .zero, blur: 0, color: nil)

  ctx.addEllipse(in: CGRect(x: 464, y: 414, width: 166, height: 80))
  ctx.setFillColor(color(0xffffff, 0.18))
  ctx.fillPath()

  drawDrop(ctx, x: 580, y: 610, scale: 0.62)
  drawSnowflake(ctx, center: CGPoint(x: 660, y: 654), radius: 38)

  ctx.restoreGState()
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
