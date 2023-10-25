struct DoublyLinkedList
       next              dd     ?
       prev              dd     ?
       data              dd     ?
ends

struct Note
       freq              dd     ?
       instrument        dw     ?       
ends

struct EnvelopeADSR
       attackTime        dd     ?
       decayTime         dd     ?
       releaseTime       dd     ?

       sustainAmpl       dd     ?
       startAmpl         dd     ?
ends

struct Instrument
       env               EnvelopeADSR
       oscType           dw     ?
ends

struct GUID
       Data1 dd ?
       Data2 dw ?
       Data3 dw ?
       Data4 db 8 dup(?)
ends       

struct DSBUFFERDESC
       dwSize dd ?
       dwFlags dd ?
       dwBufferBytes dd ?
       dwReserved dd ?
       lpwfxFormat dd ?
       guid3DAlgorithm  GUID
ends  

struct WAVEFORMATEX
       wFormatTag dw ?
       nChannels dw ?
       nSamplesPerSec dd ?
       nAvgBytesPerSec dd ?
       nBlockAlign dw ?
       wBitsPerSample dw ?
       cbSize dw ?
ends  

import dsound,\
       DirectSoundCaptureCreate,'DirectSoundCaptureCreate',\
       DirectSoundCaptureCreate8,'DirectSoundCaptureCreate8',\
       DirectSoundCaptureEnumerate ,'DirectSoundCaptureEnumerateA',\
       DirectSoundCreate,'DirectSoundCreate',\
       DirectSoundCreate8,'DirectSoundCreate8',\
       DirectSoundEnumerate ,'DirectSoundEnumerateA',\
       DirectSoundFullDuplexCreate,'DirectSoundFullDuplexCreate',\
       DllCanUnloadNow,'DllCanUnloadNow',\
       DllGetClassObject,'DllGetClassObject',\
       GetDeviceID,'GetDeviceID'       

interface IDirectSound8,\
          QueryInterface,\
          AddRef,\
          Release,\
          CreateSoundBuffer,\
          GetCaps,\
          DuplicateSoundBuffer,\
          SetCooperativeLevel,\
          Compact,\
          GetSpeakerConfig,\
          SetSpeakerConfig,\
          Initialize,\
          VerifyCertification


interface IDirectSoundBuffer,\
          QueryInterface,\
          AddRef,\
          Release,\
          GetCaps,\
          GetCurrentPosition,\
          GetFormat,\
          GetVolume,\
          GetPan,\
          GetFrequency,\
          GetStatus,\
          Initialize,\
          Lock,\
          Play,\
          SetCurrentPosition,\
          SetFormat,\
          SetVolume,\
          SetPan,\
          SetFrequency,\
          Stop,\
          Unlock,\
          Restore


interface IDirectSoundBuffer8,\
          QueryInterface,\
          AddRef,\
          Release,\
          GetCaps,\
          GetCurrentPosition,\
          GetFormat,\
          GetVolume,\
          GetPan,\
          GetFrequency,\
          GetStatus,\
          Initialize,\
          Lock,\
          Play,\
          SetCurrentPosition,\
          SetFormat,\
          SetVolume,\
          SetPan,\
          SetFrequency,\
          Stop,\
          Unlock,\
          Restore,\
          SetFX,\
          AcquireResources,\
          GetObjectInPath

