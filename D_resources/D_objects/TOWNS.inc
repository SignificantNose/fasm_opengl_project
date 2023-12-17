TOWN_LCOUNT = 1
TOWN_MCOUNT = 4
TOWN_SCOUNT = 4

townSectionTemplate:    
; center
    TownSectionElement      6, 6,\              ; coordX, coordZ
                            3, 3,\              ; unitWidth, unitHeight 
                            12, 19,\            ; rangeFloorsMin, rangeFloorsMax
                            0.0,\               ; rotation 
                            textureNeonBlueID   ; pTextureID

; medium
    TownSectionElement      9, 9,\
                            5, 5,\
                            6, 11,\
                            0.0,\
                            textureNeonBlueID

    TownSectionElement      1, 9,\
                            5, 5,\
                            6, 11,\
                            0.0,\
                            textureNeonBlueID

    TownSectionElement      9, 1,\
                            5, 5,\
                            6, 11,\
                            0.0,\
                            textureNeonBlueID

    TownSectionElement      1, 1,\
                            5, 5,\
                            6, 11,\
                            0.0,\
                            textureNeonBlueID 

; small 
    TownSectionElement      9, 9,\
                            3, 4,\
                            2, 6,\
                            90.0,\
                            textureNeonWhiteID

    TownSectionElement      6, 9,\
                            3, 4,\
                            2, 6,\
                            0.0,\
                            textureNeonWhiteID

    TownSectionElement      9, 6,\
                            3, 4,\
                            2, 6,\
                            180.0,\
                            textureNeonWhiteID

    TownSectionElement      6, 6,\
                            3, 4,\
                            2, 6,\
                            -90.0,\
                            textureNeonWhiteID

    
townArray   dd      ?