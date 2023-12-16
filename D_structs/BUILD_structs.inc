
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