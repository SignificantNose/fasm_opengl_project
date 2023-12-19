VKCH_OPTION1            equ     'Q'
VKCH_OPTION2            equ     'E'


struct ChoiceData
    choiceHasBeenMade       db      ?       ;  00000xx1 if it has been made by a player, 
                                            ;  00000xx0 if the player didn't choose 
    choiceIndex             db      ?
    standingPoint           Vector3         ; so that I don't have to look at the previous scene
    standingDirection       Vector3         ; and potentially somewhere in the future move the camera while the choice is happening?
    choiceDirectionIndex    db      ?
    ; pFirstDestPoint     dd      ?       ; or not pointers? their values?
    ; pSecondDestPoint    dd      ?       ; think...
ends

Choice.Value            db      0           ; it must be formed as a mask

firstChoiceEndPoint      Vector3     0.0, 10.0, 188.0