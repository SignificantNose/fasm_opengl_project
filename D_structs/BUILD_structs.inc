
; the struct doesn't have a scale component
; for transformation matrix, as the towers 
; themselves already have scale applied to them
struct Town
       width            dd      ?
       height           dd      ?
       total            dd      ?
       scale            dd      ?
       pTowerModels     dd      ?
       townPos          Vector3 
       townRot          Vector3 
ends

; struct for generating a separate town 
; secion in the whole city 
struct TownSectionElement 
       coordX               db     ?
       coordZ               db     ?
       unitWidth            db     ?
       unitHeight           db     ?
       rangeFloorsMin       db     ?
       rangeFloorsMax       db     ?
       rotation             dd     ?
       pTextureID           dd     ?
ends 

LAYOUT_CROSSROADSWIDTH      =      5
LAYOUT_CROSSROADSHEIGHT     =      3