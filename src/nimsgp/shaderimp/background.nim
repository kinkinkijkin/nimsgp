import glm

export glm

proc coloredBG* (bpos: Vec2[uint16], here: Vec2[float32], norm: Vec2[float32],
                vcol: Vec3[uint8], uv: Vec2[float32]): Vec4[uint16] {.inline.} =
    return vec4(vcol.x.shl(8).uint16, vcol.y.shl(8).uint16,
                vcol.y.shl(8).uint16, uint16.high)