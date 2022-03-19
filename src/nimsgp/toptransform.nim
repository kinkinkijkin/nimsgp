import datatypes, glm

#transforms to screenspace, assuming perspective projection

proc defaultTransformerPersp* (inbuff: V3Buffer, outsizeHALVED: BufRESprefloat,
                                modelMat, viewMat, projMat: Mat4x4,
                                obuff: var V3Buffer) =
    var mvp = projMat * viewMat * modelMat
    for i in 0..inbuff.len-1:
        obuff[i] = ((mvp * inbuff[i]) + vec3(1,1,0)) * outsizeHALVED
    return

#transforms to screenspace, assuming flat projection

proc defaultTransformerFlat* (inbuff: V3Buffer, outsizeHALVED: BufRESprefloat,
                                modelMat, viewMat: Mat4x4,
                                obuff: var V3Buffer) =
    var mv = viewMat * modelMat
    for i in 0..inbuff.len-1:
        obuff[i] = ((mv * inbuff[i]) + vec3(1,1,0)) * outsizeHALVED
    return

#transforms normal attachments to worldspace, assuming flat projection

proc defTransNormal* (inbuff: V3Buffer, modelMat:Mat4x4, obuff: var V3Buffer) =
    var rot = modelMat.translate(vec3f(0))
    for i in 0..inbuff.len-1:
        obuff[i] = -rot * inbuff[i]
    return

