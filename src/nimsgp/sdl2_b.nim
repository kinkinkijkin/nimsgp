import sdl2, datatypes, glm

const opt_BPP* = 24

proc fill_surface* (surf: var Surface, buf: ColourOutBufferOBUF) =
    var nearest = vec2(buf.len / surf.w, buf[0].len / surf.h)
    var death = cast[ptr UncheckedArray[byte]](surf.pixels)
    for x in 0..surf.w-1:
        for y in 0..surf.h-1:
            var posit = (((y * surf.w) + x) * 3)
            var curcol = buf[(x.float * nearest.x).int][(y.float * nearest.y).int]
            for i in 0..2:
                death[posit + i] = curcol[2 - i]

proc fill_surface_samesize* (surf: var Surface, buf: ColourOutBufferOBUF) =
    var death = cast[ptr UncheckedArray[byte]](surf.pixels)
    for x in 0..buf.len-1:
        for y in 0..buf[0].len-1:
            var posit = (((x * buf[0].len) + y) * 3)
            var curcol = buf[x][y]
            for i in 0..2:
                death[posit + i] = curcol[2 - i]