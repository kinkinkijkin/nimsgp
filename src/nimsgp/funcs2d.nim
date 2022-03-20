import glm, datatypes, pixelchoose

#pray

type
    Triangle2D* = object
        a*, b*, c*: Vec[2, float32]
    BBoxSPACE2D* = object
        pos*, siz*: Vec[2, float32]
    PShadCallback2D*[T] = proc (bpos: Vec2[uint16], here: Vec2[float32],
                            norm: Vec2[float32], vcol: Vec3[uint8]): Vec4[uint16] {.inline.}
    
proc t2d: Triangle2D {.inline.} =
    result.a = vec2(0.float32)
    result.b = vec2(0.float32)
    result.c = vec2(0.float32)
    return

const tri2Def*: Triangle2D = td()

const tri2NorDef*: array[2, Vec3[float32]] = [vec2(0.float32),
                                            vec2(0.float32),
                                            vec2(0.float32)]

proc tri2BBOXspace* (itri: Triangle2D): BBoxSPACE2D {.inline.} =
    result.pos = min(itri.a, min(itri.b, itri.c))

    var extent = max(itri.a, max(itri.b, itri.c))
    result.siz = extent - result.pos
    return result

proc tri2BBOXscreen* (itri: Triangle2D, buffersize: BufRESprefloat): BBoxSCREE =
    var minimalExtent = min(itri.a, min(itri.b, itri.c))
    var maximalExtent = max(itri.a, max(itri.b, itri.c))

    minimalExtent = minimalExtent.clamp(vec2(0'f32), buffersize)             
    maximalExtent = maximalExtent.clamp(vec2(0'f32), buffersize)

    result.pos = vec2[uint16](minimalExtent.x.uint16, minimalExtent.y.uint16)
    var boxend = vec2[uint16](maximalExtent.x.ceil().uint16, maximalExtent.y.ceil().uint16)
    result.siz = boxend - result.pos

    return result

proc collectTri2D* (element: TrianglePointer, data: V2Buffer): Triangle2D {.inline.} =
    result.a = data[element.x]
    result.b = data[element.y]
    result.c = data[element.z]

    return result

proc collectElems*[T,S] (element: TrianglePointer,
                        data: array[S, Vec2[T]]): array[3, Vec2[T]] {.inline.} =
    return [data[element.x], data[element.y], data[element.z]]

proc tri2ToScreen* (itri: Triangle2D, screenSize: BufRESprefloat): Triangle =
    var scr2 = screenSize / 2
    result.a = (itri.a + 1.0) * scr2
    result.b = (itri.b + 1.0) * scr2
    result.c = (itri.c + 1.0) * scr2

    return

#don't fucking mention that this just turns a line into a triangle
#ill replace it with a line alg later if i feel like it

proc line2D* (where, dist: Vec[2, float32]): Triangle2D {.inline.} =
    var endPoint = where + dist
    result.a = where
    result.b = endPoint
    result.c = endPoint

    return

#i feel like im going mad this is the exact same as the 3d one but
#i removed the depthtest and changed the types

proc drawReadyElements2D* (intris: MultiElementBuffer, tribuf: V2Buffer,
                dbuf: var ScalarBuffer2D, shad: PShadCallback2D,
                outbound: var ColourInnerBufferINTE, outsize: BufRESprefloat,
                normelem: MultiElementBuffer, normatt: V2Buffer,
                colelem: MultiElementBuffer, colatt: ColourBufferOBUF,
                uvelem: MultiElementBuffer, uvatt: V2Buffer) =

    for i in 0..(intris.len-1):
        var ctri = intris[i].collectTri2D(tribuf)

        #var attseq: seq[Vec3[float32]]

        var bbs = ctri.triBBOXscreen(outsize)

        block cycle1:
            if bbs.siz == vec2(0.uint16,0): break cycle1

            #block elemer:
            #    if attachments[0].fake: break elemer
            #    for att in attachments:
            #        attseq.add(att.elements[i].collectElems(att.arrptr[]))

            var nor: array[3, Vec2[float32]] = tri2NorDef

            block elemer2:
                if normelem.len < intris.len: break elemer2
                nor = normelem[i].collectElems(normatt)

            var col: array[3, ColourOBUF] = triColDef

            block elemer3:
                if colelem.len < intris.len: break elemer3
                col = colelem[i].collectElems(colatt)

            var uv: array[2, float32] = triUVDef

            block elemer4:
                if uvelem.len < intris.len: break elemer4
                uv = uvelem[i].collectElems(uvatt)

            for p in bbs:

                block cycle2:
                    var bposf: BufRESprefloat = vec2(p.x.float32, p.y.float32)
                    if not(tripleEdgeFunc(ctri, bposf)): break cycle2

                    var tripos = terp(ctri, bposf)

                    var norhere = triEstimate(nor, tripos)
                    var colhere = triEstimateCol(col, tripos)

                    #for inter in attseq:
                    #    attch.add(triEstimate(inter, tripos))

                    outbound[p.x][p.y] = shad(p, bpos, norhere, colhere, uv)