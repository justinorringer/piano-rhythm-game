<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
-odac     ;;;realtime audio out
;-iadc    ;;;uncomment -iadc if real audio input is needed too
; For Non-realtime ouput leave only the line below:
; -o prepiano.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

instr piano
;;          fund NS detune stiffness decay loss (bndry) (hammer) scan prep
aa,ab prepiano 60, 3, 10, p4, 3, 0.002, 2, 2, 1, 5000, -0.01, p5, p6, 0, 0.1, 1, 2
      outs aa*.2, ab*.2
endin

	instr synth
idur	=		p3
iamp	=		p4
ipitch	=		p5
iatk	=		p6
irel	=		p7
icut1	=		p8
icut2	=		p9
kenv    linseg 0, p3*.2, 1, p3*.55, .5, p3*.25, 0
kcut	expon	icut1, idur, icut2
aosc    oscili  iamp, ipitch
afilt	tone	aosc, kcut
aout    =  	    afilt*kenv
		outs  	aout, aout
		dispfft	afilt, idur, 4096
endin

</CsInstruments>
<CsScore>
f1 0 8 2 1 0.6 10 100 0.001 ;; 1 rattle
f2 0 8 2 1 0.7 50 500 1000  ;; 1 rubber
</CsScore>
</CsoundSynthesizer>
