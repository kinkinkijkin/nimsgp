#[ Package ]#

version     = "0.1.0"
author      = "Averey Vermette"
description = "compiler-reliant software 3d rendering API written in Nim"
license     = "MIT"

skipFiles   = @["test.nim"]

requires "glm >= 1.1.1"
requires "sdl2"
