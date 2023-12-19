VKCH_OPTION1            equ     'Q'
VKCH_OPTION2            equ     'E'


struct ChoiceData
    choiceHasBeenMade   db      ?       ;  00000xx1 if it has been made by a player, 
                                        ;  00000xx0 if the player didn't choose 
    choiceIndex         db      ?
    pFirstDestPoint     dd      ?       ; or not pointers? their values?
    pSecondDestPoint    dd      ?       ; think...
ends

Choice.Value            db      0           ; it must be formed as a mask