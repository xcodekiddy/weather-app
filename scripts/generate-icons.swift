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

func drawSparkle(_ ctx: CGContext, center: CGPoint, radius: CGFloat, alpha: CGFloat = 1) {
  ctx.saveGState()
  ctx.translateBy(x: center.x, y: center.y)
  ctx.setFillColor(color(0xffffff, alpha))

  let path = CGMutablePath()
  path.move(to: CGPoint(x: 0, y: -radius))
  path.addCurve(
    to: CGPoint(x: radius, y: 0),
    control1: CGPoint(x: radius * 0.16, y: -radius * 0.34),
    control2: CGPoint(x: radius * 0.34, y: -radius * 0.16)
  )
  path.addCurve(
    to: CGPoint(x: 0, y: radius),
    control1: CGPoint(x: radius * 0.34, y: radius * 0.16),
    control2: CGPoint(x: radius * 0.16, y: radius * 0.34)
  )
  path.addCurve(
    to: CGPoint(x: -radius, y: 0),
    control1: CGPoint(x: -radius * 0.16, y: radius * 0.34),
    control2: CGPoint(x: -radius * 0.34, y: radius * 0.16)
  )
  path.addCurve(
    to: CGPoint(x: 0, y: -radius),
    control1: CGPoint(x: -radius * 0.34, y: -radius * 0.16),
    control2: CGPoint(x: -radius * 0.16, y: -radius * 0.34)
  )
  path.closeSubpath()

  ctx.addPath(path)
  ctx.fillPath()
  ctx.restoreGState()
}

func drawIcon(_ ctx: CGContext) {
  ctx.saveGState()
  ctx.translateBy(x: 0, y: 1024)
  ctx.scaleBy(x: 1, y: -1)

  let bounds = CGRect(x: 48, y: 48, width: 928, height: 928)
  let rounded = CGPath(roundedRect: bounds, cornerWidth: 218, cornerHeight: 218, transform: nil)
  ctx.addPath(rounded)
  ctx.clip()

  drawLinearGradient(
    ctx,
    colors: [color(0x071024), color(0x172554), color(0x0284c7)],
    locations: [0, 0.62, 1],
    start: CGPoint(x: 140, y: 100),
    end: CGPoint(x: 890, y: 920)
  )

  ctx.setBlendMode(.screen)
  ctx.addEllipse(in: CGRect(x: -145, y: -110, width: 570, height: 570))
  ctx.setFillColor(color(0x60a5fa, 0.30))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: 555, y: 510, width: 530, height: 500))
  ctx.setFillColor(color(0x22d3ee, 0.33))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: 150, y: 610, width: 560, height: 480))
  ctx.setFillColor(color(0xf472b6, 0.16))
  ctx.fillPath()
  ctx.setBlendMode(.normal)

  ctx.addEllipse(in: CGRect(x: 126, y: 120, width: 820, height: 520))
  ctx.setFillColor(color(0xffffff, 0.07))
  ctx.fillPath()

  drawSparkle(ctx, center: CGPoint(x: 266, y: 284), radius: 32, alpha: 0.72)
  drawSparkle(ctx, center: CGPoint(x: 734, y: 232), radius: 22, alpha: 0.68)
  drawSparkle(ctx, center: CGPoint(x: 814, y: 398), radius: 18, alpha: 0.56)
  drawSparkle(ctx, center: CGPoint(x: 208, y: 482), radius: 14, alpha: 0.48)

  let moonRect = CGRect(x: 556, y: 220, width: 260, height: 260)
  ctx.setShadow(offset: CGSize(width: 0, height: 16), blur: 34, color: color(0x020617, 0.32))
  ctx.saveGState()
  ctx.addEllipse(in: moonRect)
  ctx.clip()
  drawLinearGradient(
    ctx,
    colors: [color(0xfff7ad), color(0xfde68a)],
    locations: [0, 1],
    start: CGPoint(x: 590, y: 238),
    end: CGPoint(x: 770, y: 466)
  )
  ctx.restoreGState()
  ctx.addEllipse(in: CGRect(x: 628, y: 178, width: 244, height: 244))
  ctx.setFillColor(color(0x172554))
  ctx.fillPath()
  ctx.setShadow(offset: .zero, blur: 0, color: nil)

  let cloud = CGMutablePath()
  cloud.addEllipse(in: CGRect(x: 200, y: 504, width: 318, height: 256))
  cloud.addEllipse(in: CGRect(x: 390, y: 382, width: 360, height: 360))
  cloud.addEllipse(in: CGRect(x: 642, y: 508, width: 206, height: 210))
  cloud.addRoundedRect(in: CGRect(x: 182, y: 624, width: 690, height: 204), cornerWidth: 102, cornerHeight: 102)

  ctx.setShadow(offset: CGSize(width: 0, height: 38), blur: 52, color: color(0x020617, 0.38))
  ctx.addPath(cloud)
  ctx.setFillColor(color(0xf8fafc, 0.96))
  ctx.fillPath()
  ctx.setShadow(offset: .zero, blur: 0, color: nil)

  ctx.addPath(CGPath(
    roundedRect: CGRect(x: 246, y: 700, width: 560, height: 70),
    cornerWidth: 35,
    cornerHeight: 35,
    transform: nil
  ))
  ctx.setFillColor(color(0xdbeafe, 0.64))
  ctx.fillPath()

  ctx.addEllipse(in: CGRect(x: 424, y: 424, width: 250, height: 112))
  ctx.setFillColor(color(0xffffff, 0.30))
  ctx.fillPath()

  ctx.addPath(rounded)
  ctx.setLineWidth(3)
  ctx.setStrokeColor(color(0xffffff, 0.15))
  ctx.strokePath()
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
  ("64x64.png", 64),
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
