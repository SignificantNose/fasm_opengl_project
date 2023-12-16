ST_RunnerFirst.Msgs:
       UnprocessedMessage        <E3, 2.666666666, 0.0>, INSTR_BASS
       UnprocessedMessage        <E2, 2.666666666, 0.0>, INSTR_PADS
       UnprocessedMessage        <G3, 2.666666666, 2.666666666>, INSTR_BASS
       UnprocessedMessage        <G2, 2.666666666, 2.666666666>, INSTR_PADS
       UnprocessedMessage        <B3, 2.666666666, 5.33333333>, INSTR_BASS
       UnprocessedMessage        <B2, 2.666666666, 5.33333333>, INSTR_PADS
       UnprocessedMessage        <A3, 2.666666666, 8.0>, INSTR_BASS
       UnprocessedMessage        <A2, 2.666666666, 8.0>, INSTR_PADS

       UnprocessedMessage        <E3, 2.666666666, 10.666666666>, INSTR_BASS
       UnprocessedMessage        <E2, 2.666666666, 10.666666666>, INSTR_PADS 
       UnprocessedMessage        <G3, 2.666666666, 13.333333333>, INSTR_BASS
       UnprocessedMessage        <G2, 2.666666666, 13.333333333>, INSTR_PADS 
       UnprocessedMessage        <B3, 2.666666666, 16.0>, INSTR_BASS
       UnprocessedMessage        <B2, 2.666666666, 16.0>, INSTR_PADS 
       UnprocessedMessage        <A3, 2.666666666, 18.666666666>, INSTR_BASS
       UnprocessedMessage        <A2, 2.666666666, 18.666666666>, INSTR_PADS



       UnprocessedMessage        <C3, 2.666666666, 21.333333333>, INSTR_BASS
       UnprocessedMessage        <C2, 2.666666666, 21.333333333>, INSTR_PADS 
       UnprocessedMessage        <D3, 2.666666666, 24.0>, INSTR_BASS
       UnprocessedMessage        <D2, 2.666666666, 24.0>, INSTR_PADS 
       UnprocessedMessage        <E3, 4.0, 26.6666666>, INSTR_BASS
       UnprocessedMessage        <E2, 4.0, 26.6666666>, INSTR_PADS
       UnprocessedMessage        <D3, 1.333333333, 30.6666666>, INSTR_BASS
       UnprocessedMessage        <D2, 1.333333333, 30.6666666>, INSTR_PADS

       UnprocessedMessage        <C3, 2.666666666, 32.0>, INSTR_BASS
       UnprocessedMessage        <C2, 2.666666666, 32.0>, INSTR_PADS 
       UnprocessedMessage        <D3, 2.666666666, 34.6666666>, INSTR_BASS
       UnprocessedMessage        <D2, 2.666666666, 34.6666666>, INSTR_PADS 
       UnprocessedMessage        <E3, 4.666666666, 37.33333333>, INSTR_BASS
       UnprocessedMessage        <E2, 4.666666666, 37.33333333>, INSTR_PADS 
       UnprocessedMessage        <D3, 0.666666666, 42.0>, INSTR_BASS
       UnprocessedMessage        <D2, 0.666666666, 42.0>, INSTR_PADS

ST_RunnerFirst.MsgsCount = ($ - ST_RunnerFirst.Msgs)/sizeof.UnprocessedMessage


ST_RunnerFirst.Seqs:
        Sequencer                 ST_RunnerFirst.Drums, ST_RunnerFirst.DrumsCount, 90.0, 0.0, 4, 4 
ST_RunnerFirst.SeqsCount = ($ - ST_RunnerFirst.Seqs)/sizeof.Sequencer 

ST_RunnerFirst.Drums:
        SeqMessage                ST_RunnerFirst.HiHat,     1111111111111111b
        SeqMessage                ST_RunnerFirst.Kick,      0000000100000001b
        SeqMessage                ST_RunnerFirst.SnareBody, 0001000000010000b
        SeqMessage                ST_RunnerFirst.SnareTail, 0001000000010000b
ST_RunnerFirst.DrumsCount = ($ - ST_RunnerFirst.Drums)/sizeof.SeqMessage


ST_RunnerFirst.HiHat       UnprocessedMessage      <A1, 0.131614, ?>, INSTR_HIHAT
ST_RunnerFirst.Kick        UnprocessedMessage      <G1, KICK_TIME, ?>, INSTR_KICK 
ST_RunnerFirst.SnareBody   UnprocessedMessage      <FSh1, 1.0, ?>, INSTR_SNAREBODY
ST_RunnerFirst.SnareTail   UnprocessedMessage      <A4, 1.0, ?>, INSTR_SNARETAIL