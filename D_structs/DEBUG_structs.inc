debugOutStartStr        db       'Debug value: '
debugOutValue           db       0,0,0,0,0,0,0,0
nullPoint               db       0

debugFloatFormatString  db       '%f',0
debugFloatStartStr      db       'Float value: '
debugOutFloatValue      db       64 dup 0
nullPointFloat          db       0 

shaderCompiled          dd      ?
debugOutShaderNotComp   db      'ERROR: shader not compiled',0