import datatypes, pixelchoose, glm

iterator items*(box: BBoxSCREE): BufRES =
    var d: Vec2[uint16] = vec2(0.uint16)
    while d.y < box.siz.y:
        while d.x < box.siz.x:
            yield box.pos + d
            d.x.inc()
        d.y.inc()
        d.x = 0.uint8
    
proc defaultBackgroundO* (outbound: var ColourOutBufferOBUF,
                        colour: ColourOBUF) {.inline.} =
    for coln in 0..outbound.len-1:
        for pointn in 0..outbound[coln].len-1: outbound[coln][pointn] = colour

proc defaultBackgroundI* (outbound: var ColourInnerBufferINTE,
                        colour: ColourINTE) {.inline.} =
    for coln in 0..outbound.len-1:
        for pointn in 0..outbound[coln].len-1: outbound[coln][pointn] = colour

proc interiorToOuterBufferNT* (inbound: ColourInnerBufferINTE,
                                outbound: var ColourOutBufferOBUF) {.inline.} =
    for coln in 0..outbound.len-1:
        for pointn in 0..outbound[coln].len-1:
            var f = vec3(inbound[coln][pointn].x.shr(8).uint8,
                        inbound[coln][pointn].y.shr(8).uint8,
                        inbound[coln][pointn].z.shr(8).uint8)
            outbound[coln][pointn] = f
    

#I wanted to do type magic to make sure I could do things generically,
#compiler did not like it and I lack the will right now to introduce a
#shitload of slow-ass code turning type magic into type beaurocracy
#so instead you get the default element draw alg forcing all arbitrary
#attachments to be scalars of some description.

#fuck type magic

#will reimplement with normals and their interpolation later
#since they have to be vectors

proc drawReadyElements* (intris: MultiElementBuffer, tribuf: V3Buffer,
                dbuf: var ScalarBuffer2D, shad: PShadingCallback,
                outbound: var ColourInnerBufferINTE, outsize: BufRESprefloat,
                normelem: MultiElementBuffer, normatt: V3Buffer,
                colelem: MultiElementBuffer, colatt: ColourBufferOBUF) =

    for i in 0..(intris.len-1):
        var ctri = intris[i].collectTri(tribuf)

        #var attseq: seq[Vec3[float32]]

        var bbs = ctri.triBBOXscreen(outsize)

        block cycle1:
            if bbs.siz == vec2(0.uint16,0): break cycle1

            #block elemer:
            #    if attachments[0].fake: break elemer
            #    for att in attachments:
            #        attseq.add(att.elements[i].collectElems(att.arrptr[]))

            var nor: array[3, Vec3[float32]] = triNorDef

            block elemer2:
                if normelem.len < intris.len: break elemer2
                nor = normelem[i].collectElems(normatt)

            var col: array[3, ColourOBUF] = triColDef

            block elemer3:
                if colelem.len < intris.len: break elemer3
                col = colelem[i].collectElems(colatt)

            for p in bbs:

                block cycle2:
                    var bposf: BufRESprefloat = vec2(p.x.float32, p.y.float32)
                    if not(tripleEdgeFunc(ctri, bposf)): break cycle2

                    var tripos = terp(ctri, bposf)

                    var dpth: float32 = 0.0
                    if not visTestOPAQ(p, tripos, ctri, dpth, dbuf): break cycle2

                    var norhere = triEstimate(nor, tripos)
                    var colhere = triEstimateCol(col, tripos)

                    #for inter in attseq:
                    #    attch.add(triEstimate(inter, tripos))

                    dbuf[p.x][p.y] = dpth

                    outbound[p.x][p.y] = shad(p, vec3(bposf.x, bposf.y, dpth),
                                            norhere, colhere)