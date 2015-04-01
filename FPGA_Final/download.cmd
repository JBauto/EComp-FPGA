setMode -bs
setCable -port auto
Identify
identifyMPM 
assignFile -p 1 -file implementation/download.bit
Program -p 1
quit

#impact -batch
#cleancablelock
#exit