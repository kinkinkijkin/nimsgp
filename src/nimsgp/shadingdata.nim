import glm, datatypes

proc nearestTexture24* (uvpos: Vec2[float32],
                        texture: ColourOutBufferOBUF): ColourOBUF {.inline.} =
    var near = vec2(uvpos.x * texture.len.float32,
                    uvpos.y * texture[0].len.float32)
    return texture[near.x.floor().int][near.y.floor().int]

proc nearestTexture24_slow* (uvpos: Vec2[float32],
                        texture: ColourInnerBufferINTE): ColourOBUF {.inline.} =
    var near = vec2(uvpos.x * texture.len.float32,
                    uvpos.y * texture[0].len.float32)
    var f = texture[near.x.floor().int][near.y.floor().int]

    return vec3(f.x.shr(8).uint8, f.y.shr(8).uint8, f.z.shr(8).uint8)

proc nearestTexture64* (uvpos: Vec2[float32],
                        texture: ColourInnerBufferINTE): ColourINTE {.inline.} =
    var near = vec2(uvpos.x * texture.len.float32,
                    uvpos.y * texture[0].len.float32)
    return texture[near.x.floor().int][near.y.floor().int]

proc nearestTexture64_slow* (uvpos: Vec2[float32],
                        texture: ColourOutBufferOBUF): ColourINTE {.inline.} =
    var near = vec2(uvpos.x * texture.len.float32,
                    uvpos.y * texture[0].len.float32)
    var f = texture[near.x.floor().int][near.y.floor().int]

    return vec4(f.x.shl(8).uint16, f.y.shl(8).uint16, f.z.shl(8).uint16, uint16.high)