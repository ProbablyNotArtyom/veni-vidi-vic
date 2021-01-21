#Makefile for GNU Make by Marko M�kel�
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

C1541 = c1541
DASM = dasm
DASMFLAGS = -R -E2 -v2 -f1

MODULES = basic.i timings.i global.i

TARGETS1 = 1-intro 3-copper 5-plasma
TARGETS2 = init 2-scroll 4-vector 6-rotator 7-end

DIRS = pal ntsc pal.u ntsc.u
DISKS = $(DIRS:%=%.d64)

ALLTARGETS = $(TARGETS1:%=pal.u/%) $(TARGETS1:%=ntsc.u/%) \
             $(TARGETS1:%=pal/%) $(TARGETS1:%=ntsc/%) \
             $(TARGETS2:%=pal/%) $(TARGETS2:%=ntsc/%)

all: $(DIRS) $(ALLTARGETS) $(DISKS)

$(DIRS):
	mkdir $@

pal.u/% : %.s $(MODULES)
	$(DASM) $< -o$@ -DSTANDALONE=1 -MSYSTEM=PAL $(DASMFLAGS)
ntsc.u/% : %.s $(MODULES)
	$(DASM) $< -o$@ -DSTANDALONE=1 -MSYSTEM=NTSC $(DASMFLAGS)

pal/%: %.s $(MODULES)
	$(DASM) $< -o$@ -DSTANDALONE=0 -MSYSTEM=PAL $(DASMFLAGS)
ntsc/%: %.s $(MODULES)
	$(DASM) $< -o$@ -DSTANDALONE=0 -MSYSTEM=NTSC $(DASMFLAGS)

pal/2-scroll: 2-scroll.bin

ntsc/2-scroll: 2-scroll.bin

pal/7-end: font.big

ntsc/7-end: font.big

2-scroll.bin: 2-scroll.ppm ppm2bin
	./ppm2bin $< $@

font.big: font.multi convfont
	./convfont $< $@

ppm2bin: ppm2bin.c

convfont: convfont.c

clean:
	rm -f ppm2bin convfont listmultifont 2-scroll.bin font.big
	rm -f *.lst *.prg a.out
	rm -f *.d64

reallyclean: clean
	rm -fr $(DIRS)


$(DISKS): %.d64 : %
	$(C1541) -format '$(notdir $(@:%.d64=%)),20' d64 $@ 8 $(foreach tmp, $(shell find $^ -name 'init') $(sort $(shell find $^ -iname '*-*')), -write $(tmp))
