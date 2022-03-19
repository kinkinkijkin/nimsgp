import glm

#no god may assist you within this file
#may the fallen ones have mercy on you
type
    Triangle* = object
        a*, b*, c*: Vec[3,float32]
    ScrenTri* = object
        a*, b*, c*: Vec[2,uint16]
    TrianglePointer* = Vec[3,uint32]
    BBoxSPACE* = object
        pos*, siz*: Vec[3,float32]
    BBoxSCREE* = object
        pos*, siz*: Vec[2,uint16]
    ColourOBUF* = Vec[3,uint8]
    ColourINTE* = Vec[4,uint16]
    BufRES* = Vec[2, uint16]
    BufRESprefloat* = Vec[2, float32]
    V3Buffer*[size: static int] = array[size, Vec[3,float32]]
    Attribute2Buffer*[size: static int, T] = array[size, Vec[2, T]]
    ColourBufferINTE*[size: static int] = array[size, ColourINTE]
    ColourInnerBufferINTE*[sizex, sizey: static int] = array[sizex, array[sizey, ColourINTE]]
    ColourBufferOBUF*[size: static int] = array[size, ColourOBUF]
    ColourOutBufferOBUF*[sizex, sizey: static int] = array[sizex, array[sizey, ColourOBUF]]
    ScalarBuffer1D*[size: static int] = array[size, float32]
    MultiElementBuffer*[size: static int] = array[size, TrianglePointer]
    ScalarBuffer2D*[sizex, sizey: static int] = array[sizex, array[sizey, float32]]
    PShadingCallback*[T] = proc (bpos: Vec2[uint16], here: Vec3[float32],
                            norm: Vec3[float32], vcol: Vec3[uint8]): Vec4[uint16] {.inline.}

proc td: Triangle {.inline.} =
    result.a = vec3(0.float32)
    result.b = vec3(0.float32)
    result.c = vec3(0.float32)
    return

const triDef*: Triangle = td()

const triColDef*: array[3, ColourOBUF] = [vec3(0.uint8),
                                        vec3(0.uint8),
                                        vec3(0.uint8)]

const triNorDef*: array[3, Vec3[float32]] = [vec3(0.float32),
                                            vec3(0.float32),
                                            vec3(0.float32)]

#works on a single triangle to create a spatial bounding box. no assumptions.

proc triBBOXspace* (itri: Triangle): BBoxSPACE {.inline.} =
    result.pos = min(itri.a, min(itri.b, itri.c))

    var extent = max(itri.a, max(itri.b, itri.c))
    result.siz = extent - result.pos
    return result

#works on a single triangle assumed to be already transformed to NDC
#to make a pixel coordinates bounding box.

proc triBBOXscreen* (itri: Triangle, buffersize: BufRESprefloat): BBoxSCREE =
    var minimalExtent = min(itri.a.xy, min(itri.b.xy, itri.c.xy))
    var maximalExtent = max(itri.a.xy, max(itri.b.xy, itri.c.xy))

    minimalExtent = minimalExtent.clamp(vec2(0'f32), buffersize)             
    maximalExtent = maximalExtent.clamp(vec2(0'f32), buffersize)

    result.pos = vec2[uint16](minimalExtent.x.uint16, minimalExtent.y.uint16)
    var boxend = vec2[uint16](maximalExtent.x.ceil().uint16, maximalExtent.y.ceil().uint16)
    result.siz = boxend - result.pos

    return result

#collects a triangle from elements. Included as an example.

proc collectTri* (element: TrianglePointer, data: V3Buffer): Triangle {.inline.} =
    result.a = data[element.x]
    result.b = data[element.y]
    result.c = data[element.z]

    return result

#collects attachments for a triangle from elements.

proc collectElems*[T,S] (element: TrianglePointer, data: array[S, T]): array[3, T] {.inline.} =
    return vec3(data[element.x], data[element.y], data[element.z])

proc collectElems*[T,S] (element: TrianglePointer,
                        data: array[S, Vec3[T]]): array[3, Vec3[T]] {.inline.} =
    return [data[element.x], data[element.y], data[element.z]]

#clears a depth buffer in a "standard" way. sometimes not desirable,
#even for a depth buffer.

proc clearDepthbuff* (d: var ScalarBuffer2D) {.inline.} =
    for coln in 0..d.len-1:
        for pointn in 0..d[coln].len-1: d[coln][pointn] = Inf.float32

#clears any scalar float buffer with a given value. can be used to clear
#a depth buffer with a "max viewdistance" as a neat little hack

proc clearScalarBuff* (b: var ScalarBuffer2D, val: float32) {.inline.} =
    for coln in 0..b.len-1:
        for pointn in 0..b[coln].len-1: b[coln][pointn] = val

proc triToScreen* (itri: Triangle, screenSize: BufRESprefloat): Triangle =
    var scr2 = screenSize / 2
    result.a.xy = (itri.a.xy + 1.0) * scr2
    result.b.xy = (itri.b.xy + 1.0) * scr2
    result.c.xy = (itri.c.xy + 1.0) * scr2

    result.a.z = itri.a.z
    result.b.z = itri.b.z
    result.c.z = itri.c.z

    return