import datatypes, glm

#transforms to screenspace, assuming perspective projection

proc defaultTransformerPersp* (inbuff: V3Buffer, outsizeHALVED: BufRESprefloat,
                                modelMat, viewMat, projMat: Mat4x4,
                                obuff: var V3Buffer) =
    obuff = @[]
    var mvp = viewMat * projMat * modelMat
    for i in 0..inbuff.len-1:
        var f = inbuff[i]
        var t = ((mvp * vec4(f.x, f.y, f.z, 3)))
        obuff.add(t.xyz)
        obuff[i].xy = (obuff[i].xy + vec2(1.0.float32, 1.0)) * outsizeHALVED
    return

#transforms to screenspace, assuming flat projection

proc defaultTransformerFlat* (inbuff: V3Buffer, outsizeHALVED: BufRESprefloat,
                                modelMat, viewMat: Mat4x4,
                                obuff: var V3Buffer) =
    obuff = @[]
    var mv = viewMat * modelMat
    for i in 0..inbuff.len-1:
        var f = inbuff[i]
        obuff.add((mv * vec4(f.x, f.y, f.z, 1) + vec4(1.float32,1,0,0)).xyz)
        obuff[i].xy *= outsizeHALVED
    return

#transforms normal attachments to worldspace, assuming flat projection

proc defTransNormal* (inbuff: V3Buffer, modelMat:Mat4x4, obuff: var V3Buffer) =
    var rot = inverse(mat3(modelMat[0].xyz,
                            modelMat[1].xyz,
                            modelMat[2].xyz))
    obuff = @[]
    for i in 0..inbuff.len-1:
        obuff.add(rot * inbuff[i])
        obuff[i].z = obuff[i].z
    return

proc uvGLtoSGP* (inbuff: V2Buffer, obuff: var V2Buffer) =
    obuff = @[]
    for i in 0..inbuff.len-1:
        obuff.add(vec2(inbuff[i].x, inbuff[i].y))
    return