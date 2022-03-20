import sdl2, glm, os

import src/nimsgp/[datatypes,topdraw,toptransform,sdl2_b,shaderimp/core]

const screen_w = 1920
const screen_h = 1080
const screen_bpp = 24

var scree: SurfacePtr
var screePRT: SurfacePtr
var wind: WindowPtr

var rekt: Rect

rekt.x = 0
rekt.y = 0
rekt.w = screen_w
rekt.h = screen_h

if init(INIT_EVERYTHING).cint == -1:
    quit(5)

wind = createWindow("hamtest-nim",
                    SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                    screen_w, screen_h, 0)
screePRT = createRGBSurface(0, screen_w, screen_h, screen_bpp, 0, 0, 0, 0)
scree = getSurface(wind)

var depthbuf: ScalarBuffer2D[256,144]
var colbuf: ColourOutBufferOBUF[256,144]
var interiorcolbuf: ColourInnerBufferINTE[256,144]

clearDepthbuff(depthbuf)

var bgcol4 = vec4(3.shl(8).uint16,3.shl(8),55.shl(8),uint16.high)

defaultBackgroundO(colbuf, vec3(3.uint8,3,3))
defaultBackgroundI(interiorcolbuf, bgcol4)

var testTriBuf: V3Buffer[3] = [vec3(-0.9.float32,-0.9,1),
                            vec3(0.9.float32,0.9,1),
                            vec3(0.9.float32,-0.2,1)]
var testTriCol: ColourBufferOBUF[3] = [vec3(128.uint8, 137, 189),
                                        vec3(100.uint8, 200, 150),
                                        vec3(190.uint8, 100, 100)]
var testTriElem: MultiElementBuffer[1] = [vec3(0.uint32, 1, 2)]

var tn: V3Buffer[3] = [vec3(0.float32), vec3(0.float32), vec3(0.float32)]

var osh: BufRESprefloat = vec2(128.float32, 72)
var oh = osh * 2

proc testproject (inbuff: V3Buffer, obuff: var V3Buffer, a: BufRESprefloat) = 
    for i in 0..inbuff.len-1:
        obuff[i] = vec3((inbuff[i].x + 1) * a.x,
                        (inbuff[i].y + 1) * a.y,
                        inbuff[i].z)
    return

var testTriTrans: V3Buffer[3]


testproject(testTriBuf, testTriTrans, osh)

var shouldNotQuit = true

while shouldNotQuit:
    drawReadyElements(testTriElem, testTriTrans, depthbuf, defaultPSveccol,
                        interiorcolbuf, oh, testTriElem, tn,
                        testTriElem, testTriCol)

    interiorToOuterBufferNT(interiorcolbuf, colbuf)

    fill_surface(screePRT[], colbuf)

    blitSurface(screePRT, addr rekt, scree, addr rekt)

    #sleep(20)
    if updateSurface(wind).int < 0: echo(getError())

    defaultBackgroundO(colbuf, vec3(3.uint8,3,3))
    defaultBackgroundI(interiorcolbuf, bgcol4)
    clearDepthbuff(depthbuf)
