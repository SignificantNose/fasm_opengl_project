struct  Spline.Point
        pMainVertex     dd      ?
        pDirectionPrev  dd      ?
        pDirectionNext  dd      ?
        time            dd      ?
ends

struct  Spline
        pointsCount     dd      ?
        points          dd      ?
        cycle           dd      ?
        time            dd      ?
ends

SPLINE_NOT_LOOPED       = 0
SPLINE_LOOPED           = 1