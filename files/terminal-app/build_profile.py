#!/usr/bin/env python3
"""
Build a Rose Pine Moon .terminal profile for macOS Terminal.app.

Terminal.app stores NSColor values as NSKeyedArchiver-encoded binary
plists in the profile. Each blob is essentially:

  {
    "$version": 100000,
    "$archiver": "NSKeyedArchiver",
    "$top": {"root": UID(1)},
    "$objects": [
      "$null",
      {
        "NSColorSpace": 2,
        "NSRGB": "0.208 0.258 0.296",   # ASCII, space-separated floats
        "$class": UID(2)
      },
      {
        "$classname": "NSColor",
        "$classes": ["NSColor", "NSObject"]
      }
    ]
  }

We build one of these per color, then wrap them in a Window Settings
profile dict, then package everything as a .terminal file.
"""
import plistlib
from plistlib import UID

# Rose Pine Moon palette (canonical values from rosepinetheme.com)
PALETTE = {
    "base":           (0x23, 0x21, 0x36),
    "overlay":        (0x39, 0x35, 0x52),
    "muted":          (0x6e, 0x6a, 0x86),
    "text":           (0xe0, 0xde, 0xf4),
    "love":           (0xeb, 0x6f, 0x92),
    "gold":           (0xf6, 0xc1, 0x77),
    "rose":           (0xea, 0x9a, 0x97),
    "pine":           (0x3e, 0x8f, 0xb0),
    "foam":           (0x9c, 0xcf, 0xd8),
    "iris":           (0xc4, 0xa7, 0xe7),
    "highlight_med":  (0x44, 0x41, 0x5a),
    "highlight_high": (0x56, 0x52, 0x6e),
}


def color_blob(r, g, b):
    """Return NSKeyedArchiver bytes for an NSColor in the sRGB space."""
    rgb_string = f"{r/255:.10f} {g/255:.10f} {b/255:.10f}"
    archive = {
        "$version": 100000,
        "$archiver": "NSKeyedArchiver",
        "$top": {"root": UID(1)},
        "$objects": [
            "$null",
            {
                "NSColorSpace": 2,
                "NSRGB": rgb_string.encode("ascii"),
                "$class": UID(2),
            },
            {
                "$classname": "NSColor",
                "$classes": ["NSColor", "NSObject"],
            },
        ],
    }
    return plistlib.dumps(archive, fmt=plistlib.FMT_BINARY)


def c(name):
    return color_blob(*PALETTE[name])


profile = {
    "name": "Rose Pine Moon",
    "type": "Window Settings",
    "ProfileCurrentVersion": 2.09,

    # ANSI 0..7 (normal)
    "ANSIBlackColor":         c("overlay"),
    "ANSIRedColor":           c("love"),
    "ANSIGreenColor":         c("pine"),
    "ANSIYellowColor":        c("gold"),
    "ANSIBlueColor":          c("foam"),
    "ANSIMagentaColor":       c("iris"),
    "ANSICyanColor":          c("rose"),
    "ANSIWhiteColor":         c("text"),

    # ANSI 8..15 (bright)
    "ANSIBrightBlackColor":   c("muted"),
    "ANSIBrightRedColor":     c("love"),
    "ANSIBrightGreenColor":   c("pine"),
    "ANSIBrightYellowColor":  c("gold"),
    "ANSIBrightBlueColor":    c("foam"),
    "ANSIBrightMagentaColor": c("iris"),
    "ANSIBrightCyanColor":    c("rose"),
    "ANSIBrightWhiteColor":   c("text"),

    # Window colors
    "BackgroundColor":        c("base"),
    "TextColor":              c("text"),
    "TextBoldColor":          c("text"),
    "CursorColor":            c("highlight_high"),
    "SelectionColor":         c("highlight_med"),

    # Sensible defaults
    "columnCount":            120,
    "rowCount":               36,
    "useOptionAsMetaKey":     True,
}

out = "/tmp/rose-pine-terminal/RosePineMoon.terminal"
with open(out, "wb") as f:
    plistlib.dump(profile, f, fmt=plistlib.FMT_XML)

print(f"wrote {out}")
