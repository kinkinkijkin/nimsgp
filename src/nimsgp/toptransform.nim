import datatypes, glm

#transforms to screenspace, assuming perspective projection

proc defaultTransformerPersp* (inbuff: V3Buffer, outsizeHALVED: BufRESprefloat,
                                modelMat, viewMat, projMat: Mat4x4,
                                obuff: var V3Buffer) =
    obuff = @[]
    var mvp = projMat * viewMat * modelMat
    for i in 0..inbuff.len-1:
        var f = inbuff[i]
        obuff.add((mvp * vec4(f.x, f.y, f.z, 1) + vec4(1.float32,1,0,0)).xyz)
        obuff[i].xy *= outsizeHALVED
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
    for i in 0..inbuff.len-1:
        obuff.add(rot * inbuff[i])
    return

