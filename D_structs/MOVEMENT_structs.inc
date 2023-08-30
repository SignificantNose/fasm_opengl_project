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

struct  Transform
        position        Vector3
        rotation        Vector3
        scale           Vector3
ends