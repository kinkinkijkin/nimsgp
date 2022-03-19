import glm

export glm

proc defaultPSveccol* (bpos: Vec2[uint16], here: Vec3[float32],
                        norm: Vec3[float32], vcol: Vec3[uint8],): Vec4[uint16] {.inline.} =
    var vc1: Vec3[uint8] = vec3(vcol[0], vcol[1], vcol[2])
    var vcc = vec3(vc1.x.uint16.shl(8),
                vc1.y.uint16.shl(8),
                vc1.z.uint16.shl(8))

    return vec4(vcc.x, vcc.y, vcc.z, uint16.high())
