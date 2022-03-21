import datatypes, glm

#lerp funtion, found on google but credit unforunately not provided w/ code?
proc lerp*(a: float32, b: float32, c: float32): float32 {.inline.} =
    return (a * (1.0 - c)) + (b * c)

proc lerp*[T](a: Vec2[T], b: Vec2[T], c: float32): Vec2[T] {.inline.} =
    return (a * (1.0 - c)) + (b * c)

proc lerp*[T](a: Vec3[T], b: Vec3[T], c: float32): Vec3[T] {.inline.} =
    return (a * (1.0 - c)) + (b * c)

proc lerpCol*(a, b: Vec3[uint8], c: float32): Vec3[uint8] =
    var af = vec3(a.x.float32, a.y.float32, a.z.float32)
    var bf = vec3(b.x.float32, b.y.float32, b.z.float32)

    var step1 = lerp(af, bf, c)

    return vec3(step1.x.uint8, step1.y.uint8, step1.z.uint8)

#calculates a point's a-b and b-c distances on a tri.
proc terp* (itri: Triangle, pos: BufRESprefloat): Vec2[float32] {.inline.} =
    result.x = abs(length(pos - itri.a.xy) - length(pos - itri.b.xy)) /
                max(abs(length(itri.a.xy - itri.b.xy)), 0.000001)
    result.y = abs(length(pos - itri.b.xy) - length(pos - itri.c.xy)) /
                max(abs(length(itri.b.xy - itri.c.xy)), 0.000001)
    return

#simple edge function.

proc tripleEdgeFunc* (itri: Triangle, pos: BufRESprefloat): bool =
    proc ef (a,b,c: Vec2f):float32 {.inline.} =
        return (c.x-a.x)*(b.y-a.y)-(c.y-a.y)*(b.x-a.x)

    return not ((ef(itri.a.xy, itri.b.xy, pos) >= 0) and
            (ef(itri.b.xy, itri.c.xy, pos) >= 0) and
            (ef(itri.a.xy, itri.c.xy, pos) >= 0))

#makes depth at pixel from a triangle

proc depthEstimate* (itri: Triangle, trep: Vec2[float32]): float32 {.inline.} =
    return lerp(lerp(itri.a.z, itri.b.z, trep.x), itri.c.z, trep.y)

proc triEstimate*[T] (invec: seq[T], trep: Vec2[float32]): T {.inline.} =
    return lerp(lerp(invec[0], invec[1], trep.x), invec[2], trep.y)

proc triEstimateCol*[T] (invec: seq[T], trep: Vec2[float32]): T {.inline.} =
    return lerpCol(lerpCol(invec[0], invec[1], trep.x), invec[2], trep.y)

#depth test function.

proc depthTest* (depthHere: float32, pos: BufRES,
                dbuffer: ScalarBuffer2D): bool {.inline.} =
    return (depthHere <= dbuffer[pos.x][pos.y])

#transparency-aware visibility test.

proc visTestTRANSP* (pos: BufRES, pos2: Vec2[float32], itri: Triangle,
                    odepth: var float32, dbuffer: ScalarBuffer2D,
                    alpha, vislevel: uint16): bool =
    if alpha >= vislevel:
        odepth = depthEstimate(itri, pos2)
        return depthTest(odepth, pos, dbuffer)
    return false

#transparency-unaware visibility test.

proc visTestOPAQ* (pos: BufRES, pos2: Vec2[float32], itri: Triangle,
                    odepth: var float32, dbuffer: ScalarBuffer2D): bool =
    odepth = depthEstimate(itri, pos2)
    return depthTest(odepth, pos, dbuffer)

