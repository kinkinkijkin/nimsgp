# nimsgp (Nim Software Graphics Programming Library)

nimsgp / libnimsgp is a software-based 3D rendering library,
focussed primarily on providing usage paradigms similar to
GPU-accelerated APIs

The purpose of this library is for usage on operating systems
and computers without access 3D acceleration, such as(respectively)
Haiku and most riscv computers.

## confirmed working on:
 - Debian 10 x86_64 (nim 1.4.2)

## implementation plans (so far)
shading sublanguage:
 - Position/Transform programs
 - Make 3D Pixel programs better (how?)
 - Implement arbitrary attachments
 - 2D Pixel programs (for backgrounds)
 - Alpha-check programs (for binary alpha/pixel culling)
 - Texture attachment system

main render api:
 - Partial transparency recognition
 - Different optimized draw procs
 - Make more culling subalgorithms (`pixelchoose.nim`) available
 - Optimize included (experimental) interpolation system
 - Faster everything
 - Optimized data structures
 - Faster, naturally-vectorizable, traversal algs
 - Binary alpha-based culling (see shading list)
 - "Easy API" convenience procs

externals:
 - SDL2 integrations (working but slow and not yet released)
 - GLFW integrations (no work done)
 - Reference renderer (current skeleton included, otherwise no work)

# API

Follows is a bit of usage instruction. The code has explanatory
comments in places in case anything needs clarification.

## datatypes.nim

This file contains every type used by the defined parts of the
render functionality. If you're connecting into the render
functions in a piece of code you want to import this file and
understand the things it does:

`triBBOXspace` creates a 3-dimensional floating point bounding box
of the triangle entered into it, with no "outer bounds", in whatever
coordinate space the triangle is passed to it in.

`triBBOXscreen` on the other hand, creates a 2-dimensional uint16
bounding box of the triangle entered into it, in final screen space,
assuming the triangle has already been transformed into such.
this is effectively only here for use in draw functions, but go mad.

`collectTri` reads a container holding array-relative positions of
three points on a triangle, often called an "element collection".
All of the other procs beginning with `collect` do the same thing,
but for different final data structures, meant for use in different
parts of the implemented renderer.

`clearDepthBuff` clears a depth buffer by replacing every position
contained within it with positive infinity.

`clearScalarBuff` more general version of `clearDepthBuff` which
instead replaces the positions with a predefined value. Useful
in replacement of the other one to implement natural clipping distance.

`triToScreen` I literally forgot I implemented this until just now,
writing this document. Huh. Coulda used that in a few spots. Turns
a triangle in normalized device coordinates into a triangle in screen
coordinates. Thinking about it, not terribly useful as models are
meant to be transformed all-at-once before draw instead of one at
a time in the draw loop. Consider it deprecated unless someone finds
a use for it I guess.

## pixelchoose.nim

`lerp` two (overloaded) procs that perform linear interpolation.

`lerpCol` lerp but for 24bpp colour types. might make an overload
for the 64bpp colour type as well. Kind of ridiculously slow, though.

`terp` couldn't think of a name, estimates a 2d point's position
on a triangle in normalized triangular coordinates, for use in
interpolation. Likely can be done faster. Keystone function of
the experimental interpolation alg in this library, theoretically
can be used to increase speed of extremely large amounts of
triangular interpolations, given proper usage of the coordinates
and proper implementation of the "terp" function (to come)

`tripleEdgeFunc` for testing if a point falls inside of a triangle.

`depthEstimate` uses "terp" values to estimate the depth at a pixel.
seems to be accurate as far as I've tested to now.

`triEstimate` and `triEstimateCol` are depthEstimate but for
interpolating attachments.

`depthTest` is a generic inlineable for testing if the current pixel
is in front of the pixel in the image.

`visTestTRANSP` scratch pre-implementation of a needed proc for 
binary alpha. currently not used.

`visTestOPAQ` actually used visibility test, note this also runs the
depth estimator and sets your depth value. Reimpliment if you need
it not to.

## topdraw.nim

this file is a mess

`items` iterator. an iterator for screenspace bounding box's
contained pixels.

`defaultBackgroundO` included method of writing a render background.
yes this is equiv to glClear(GL_COLOR_BIT) technically. shup

`defaultBackgroundI` same thing but for the 64bpp internal buffer
type.

`interiorToOuterBufferNT` horrible implementation of a cross-precision
copy from the interior buffer type to the one meant to write to screen.
please only run this once per frame I beg of you, it's so slow.

`drawReadyElements` draws a model as provided by an element buffer.
probably really terrible, I've been awake for 14 hours and have
put too much work into that proc tonight so I'll figure it out later.
call structure is likely nightmarish.

## toptransform.nim

`defaultTransformerPersp` transforms a model's entire point buffer
into perspective space. requires usage and understanding of GLM.

`defaultTransformerFlat` above proc but into orthoganal space.

`defTransNormal` humorous disobedience of naming conventions,
transforms a model's normal buffer into its corect world position.

## shaderimp/

safer to just ignore this folder has anything in it until the shading
sublanguage is properly described.

# Contact

do not attempt to contact me. put things in the issue tracker.
I (current lead developer Averey Vermette) am in a bad spot and
don't want to waste my little socialization time I have available
providing help for unfinished software.