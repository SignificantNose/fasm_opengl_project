struct Sequencer
       msgListHead       DoublyLinkedList
       patternListHead   DoublyLinkedList
       tempo             dd     ?
       timeElapsed       dd     ?
       timeOneBeat       dd     ?

       totalBeats        dw     ?
       beats             db     ?
       subBeats          db     ?
       currentBeat       dw     ?
ends

seqMain         Sequencer       <LIST_NONE,LIST_NONE,0>, <LIST_NONE,LIST_NONE,0>, 60.0, 0.0, 0.0, 16, 4, 4, 0
