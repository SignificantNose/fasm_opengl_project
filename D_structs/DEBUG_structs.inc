dbgStartDefault         db       'Debug value: '
debugOutValue           db       0,0,0,0,0,0,0,0
nullPointDec            db       0

dbgStartFloat           db       'Float value: '
debugOutFloatValue      db       64 dup 0
nullPointFloat          db       0 

dbgStartCountTicks      db      'Tick count: '
dbgOutValueCount        db      0,0,0,0,0,0,0,0
nullPointCount          db      0

shaderCompiled          dd      ?
debugOutShaderNotComp   db      'ERROR: shader not compiled',0

debugOutThreadPing      db      'Thread signal set!!',0
debugOutFrontDir        db      'Front vector coordinates:',0
debugOutCameraPos       db      'Camera position:',0