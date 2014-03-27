UNAME = $(shell uname)
SOLIB_PREFIX = lib

ifeq ($(UNAME), Darwin)  # Mac
  SOLIB_EXT = dylib
  PDNATIVE_SOLIB_EXT = jnilib
  PDNATIVE_PLATFORM = mac
  PDNATIVE_ARCH = 
  PLATFORM_CFLAGS = -DHAVE_LIBDL -DMACOSX -O3 -arch x86_64 -arch i386 -g \
    -I/System/Library/Frameworks/JavaVM.framework/Headers
  LDFLAGS = -arch x86_64 -arch i386 -dynamiclib -ldl
  CSHARP_LDFLAGS = $(LDFLAGS)
  JAVA_LDFLAGS = -framework JavaVM $(LDFLAGS)
else
  ifeq ($(OS), Windows_NT)  # Windows, use Mingw
    CC = gcc
    SOLIB_EXT = dll
    SOLIB_PREFIX = 
    PDNATIVE_PLATFORM = windows
    PDNATIVE_ARCH = $(shell $(CC) -dumpmachine | sed -e 's,-.*,,' -e 's,i[3456]86,x86,' -e 's,amd64,x86_64,')
    PLATFORM_CFLAGS = -DWINVER=0x502 -DWIN32 -D_WIN32 -DPD_INTERNAL -DMSW -O3 \
      -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/win32"
    MINGW_LDFLAGS = -shared -lws2_32 -lkernel32
    LDFLAGS = $(MINGW_LDFLAGS) -Wl,--output-def=libs/libpd.def \
      -Wl,--out-implib=libs/libpd.lib
    CSHARP_LDFLAGS = $(MINGW_LDFLAGS) -Wl,--output-def=libs/libpdcsharp.def \
      -Wl,--out-implib=libs/libpdcsharp.lib
    JAVA_LDFLAGS = $(MINGW_LDFLAGS) -Wl,--kill-at
  else  # Assume Linux
    SOLIB_EXT = so
    PDNATIVE_PLATFORM = linux
    PDNATIVE_ARCH = $(shell $(CC) -dumpmachine | sed -e 's,-.*,,' -e 's,i[3456]86,x86,' -e 's,amd64,x86_64,')
    JAVA_HOME ?= /usr/lib/jvm/default-java
    PLATFORM_CFLAGS = -DHAVE_LIBDL -Wno-int-to-pointer-cast \
      -Wno-pointer-to-int-cast -fPIC -I"$(JAVA_HOME)/include" \
      -I"$(JAVA_HOME)/include/linux" -O3
    LDFLAGS = -shared -ldl -Wl,-Bsymbolic
    CSHARP_LDFLAGS = $(LDFLAGS)
    JAVA_LDFLAGS = $(LDFLAGS)
  endif
endif

PDNATIVE_SOLIB_EXT ?= $(SOLIB_EXT)

PD_FILES = \
	pure-data/src/d_arithmetic.c pure-data/src/d_array.c pure-data/src/d_ctl.c \
	pure-data/src/d_dac.c pure-data/src/d_delay.c pure-data/src/d_fft.c \
	pure-data/src/d_fft_mayer.c pure-data/src/d_fftroutine.c \
	pure-data/src/d_filter.c pure-data/src/d_global.c pure-data/src/d_math.c \
	pure-data/src/d_misc.c pure-data/src/d_osc.c pure-data/src/d_resample.c \
	pure-data/src/d_soundfile.c pure-data/src/d_ugen.c \
	pure-data/src/g_all_guis.c pure-data/src/g_array.c pure-data/src/g_bang.c \
	pure-data/src/g_canvas.c pure-data/src/g_editor.c pure-data/src/g_graph.c \
	pure-data/src/g_guiconnect.c pure-data/src/g_hdial.c \
	pure-data/src/g_hslider.c pure-data/src/g_io.c pure-data/src/g_mycanvas.c \
	pure-data/src/g_numbox.c pure-data/src/g_readwrite.c \
	pure-data/src/g_rtext.c pure-data/src/g_scalar.c pure-data/src/g_template.c \
	pure-data/src/g_text.c pure-data/src/g_toggle.c pure-data/src/g_traversal.c \
	pure-data/src/g_vdial.c pure-data/src/g_vslider.c pure-data/src/g_vumeter.c \
	pure-data/src/m_atom.c pure-data/src/m_binbuf.c pure-data/src/m_class.c \
	pure-data/src/m_conf.c pure-data/src/m_glob.c pure-data/src/m_memory.c \
	pure-data/src/m_obj.c pure-data/src/m_pd.c pure-data/src/m_sched.c \
	pure-data/src/s_audio.c pure-data/src/s_audio_dummy.c \
	pure-data/src/s_file.c pure-data/src/s_inter.c \
	pure-data/src/s_loader.c pure-data/src/s_main.c pure-data/src/s_path.c \
	pure-data/src/s_print.c pure-data/src/s_utf8.c pure-data/src/x_acoustics.c \
	pure-data/src/x_arithmetic.c pure-data/src/x_connective.c \
	pure-data/src/x_gui.c pure-data/src/x_interface.c pure-data/src/x_list.c \
	pure-data/src/x_midi.c pure-data/src/x_misc.c pure-data/src/x_net.c \
	pure-data/src/x_qlist.c pure-data/src/x_time.c \
	libpd_wrapper/s_libpdmidi.c libpd_wrapper/x_libpdreceive.c \
	libpd_wrapper/z_libpd.c \
	pure-data/extra/bonk~/bonk~.c \
	pure-data/extra/choice/choice.c \
	pure-data/extra/fiddle~/fiddle~.c \
	pure-data/extra/loop~/loop~.c \
	pure-data/extra/lrshift~/lrshift~.c \
	pure-data/extra/pd~/pdsched.c \
	pure-data/extra/pique/pique.c \
	pure-data/extra/sigmund~/sigmund~.c \
	pure-data/extra/cyclone/hammer/accum.c \
	pure-data/extra/cyclone/hammer/acos.c \
	pure-data/extra/cyclone/hammer/active.c \
	pure-data/extra/cyclone/hammer/allhammers.c \
	pure-data/extra/cyclone/hammer/anal.c \
	pure-data/extra/cyclone/hammer/Append.c \
	pure-data/extra/cyclone/hammer/asin.c \
	pure-data/extra/cyclone/hammer/bangbang.c \
	pure-data/extra/cyclone/hammer/bondo.c \
	pure-data/extra/cyclone/hammer/Borax.c \
	pure-data/extra/cyclone/hammer/Bucket.c \
	pure-data/extra/cyclone/hammer/buddy.c \
	pure-data/extra/cyclone/hammer/capture.c \
	pure-data/extra/cyclone/hammer/cartopol.c \
	pure-data/extra/cyclone/hammer/Clip.c \
	pure-data/extra/cyclone/hammer/coll.c \
	pure-data/extra/cyclone/hammer/comment.c \
	pure-data/extra/cyclone/hammer/cosh.c \
	pure-data/extra/cyclone/hammer/counter.c \
	pure-data/extra/cyclone/hammer/cycle.c \
	pure-data/extra/cyclone/hammer/decide.c \
	pure-data/extra/cyclone/hammer/Decode.c \
	pure-data/extra/cyclone/hammer/drunk.c \
	pure-data/extra/cyclone/hammer/flush.c \
	pure-data/extra/cyclone/hammer/forward.c \
	pure-data/extra/cyclone/hammer/fromsymbol.c \
	pure-data/extra/cyclone/hammer/funbuff.c \
	pure-data/extra/cyclone/hammer/funnel.c \
	pure-data/extra/cyclone/hammer/gate.c \
	pure-data/extra/cyclone/hammer/grab.c \
	pure-data/extra/cyclone/hammer/hammer.c \
	pure-data/extra/cyclone/hammer/Histo.c \
	pure-data/extra/cyclone/hammer/iter.c \
	pure-data/extra/cyclone/hammer/match.c \
	pure-data/extra/cyclone/hammer/maximum.c \
	pure-data/extra/cyclone/hammer/mean.c \
	pure-data/extra/cyclone/hammer/midiflush.c \
	pure-data/extra/cyclone/hammer/midiformat.c \
	pure-data/extra/cyclone/hammer/midiparse.c \
	pure-data/extra/cyclone/hammer/minimum.c \
	pure-data/extra/cyclone/hammer/mousefilter.c \
	pure-data/extra/cyclone/hammer/MouseState.c \
	pure-data/extra/cyclone/hammer/mtr.c \
	pure-data/extra/cyclone/hammer/next.c \
	pure-data/extra/cyclone/hammer/offer.c \
	pure-data/extra/cyclone/hammer/onebang.c \
	pure-data/extra/cyclone/hammer/past.c \
	pure-data/extra/cyclone/hammer/Peak.c \
	pure-data/extra/cyclone/hammer/poltocar.c \
	pure-data/extra/cyclone/hammer/prepend.c \
	pure-data/extra/cyclone/hammer/prob.c \
	pure-data/extra/cyclone/hammer/pv.c \
	pure-data/extra/cyclone/hammer/seq.c \
	pure-data/extra/cyclone/hammer/sinh.c \
	pure-data/extra/cyclone/hammer/speedlim.c \
	pure-data/extra/cyclone/hammer/spell.c \
	pure-data/extra/cyclone/hammer/split.c \
	pure-data/extra/cyclone/hammer/spray.c \
	pure-data/extra/cyclone/hammer/sprintf.c \
	pure-data/extra/cyclone/hammer/substitute.c \
	pure-data/extra/cyclone/hammer/sustain.c \
	pure-data/extra/cyclone/hammer/switch.c \
	pure-data/extra/cyclone/hammer/Table.c \
	pure-data/extra/cyclone/hammer/tanh.c \
	pure-data/extra/cyclone/hammer/testmess.c \
	pure-data/extra/cyclone/hammer/thresh.c \
	pure-data/extra/cyclone/hammer/TogEdge.c \
	pure-data/extra/cyclone/hammer/tosymbol.c \
	pure-data/extra/cyclone/hammer/Trough.c \
	pure-data/extra/cyclone/hammer/universal.c \
	pure-data/extra/cyclone/hammer/urn.c \
	pure-data/extra/cyclone/hammer/Uzi.c \
	pure-data/extra/cyclone/hammer/xbendin.c \
	pure-data/extra/cyclone/hammer/xbendin2.c \
	pure-data/extra/cyclone/hammer/xbendout.c \
	pure-data/extra/cyclone/hammer/xbendout2.c \
	pure-data/extra/cyclone/hammer/xnotein.c \
	pure-data/extra/cyclone/hammer/xnoteout.c \
	pure-data/extra/cyclone/hammer/zl.c \
	pure-data/extra/cyclone/shadow/cyclone.c \
	pure-data/extra/cyclone/shadow/dummies.c \
	pure-data/extra/cyclone/shadow/maxmode.c \
	pure-data/extra/cyclone/shadow/nettles.c \
	pure-data/extra/cyclone/shared/common/binport.c \
	pure-data/extra/cyclone/shared/common/clc.c \
	pure-data/extra/cyclone/shared/common/dict.c \
	pure-data/extra/cyclone/shared/common/fitter.c \
	pure-data/extra/cyclone/shared/common/grow.c \
	pure-data/extra/cyclone/shared/common/lex.c \
	pure-data/extra/cyclone/shared/common/loud.c \
	pure-data/extra/cyclone/shared/common/messtree.c \
	pure-data/extra/cyclone/shared/common/mifi.c \
	pure-data/extra/cyclone/shared/common/os.c \
	pure-data/extra/cyclone/shared/common/patchvalue.c \
	pure-data/extra/cyclone/shared/common/port.c \
	pure-data/extra/cyclone/shared/common/props.c \
	pure-data/extra/cyclone/shared/common/qtree.c \
	pure-data/extra/cyclone/shared/common/rand.c \
	pure-data/extra/cyclone/shared/common/vefl.c \
	pure-data/extra/cyclone/shared/hammer/file.c \
	pure-data/extra/cyclone/shared/hammer/gui.c \
	pure-data/extra/cyclone/shared/hammer/tree.c \
	pure-data/extra/cyclone/shared/shared.c \
	pure-data/extra/cyclone/shared/sickle/arsic.c \
	pure-data/extra/cyclone/shared/sickle/sic.c \
	pure-data/extra/cyclone/shared/toxy/plusbob.c \
	pure-data/extra/cyclone/shared/toxy/scriptlet.c \
	pure-data/extra/cyclone/sickle/abs.c \
	pure-data/extra/cyclone/sickle/acos.c \
	pure-data/extra/cyclone/sickle/acosh.c \
	pure-data/extra/cyclone/sickle/allpass.c \
	pure-data/extra/cyclone/sickle/allsickles.c \
	pure-data/extra/cyclone/sickle/asin.c \
	pure-data/extra/cyclone/sickle/asinh.c \
	pure-data/extra/cyclone/sickle/atan.c \
	pure-data/extra/cyclone/sickle/atan2.c \
	pure-data/extra/cyclone/sickle/atanh.c \
	pure-data/extra/cyclone/sickle/average.c \
	pure-data/extra/cyclone/sickle/avg.c \
	pure-data/extra/cyclone/sickle/bitand.c \
	pure-data/extra/cyclone/sickle/bitnot.c \
	pure-data/extra/cyclone/sickle/bitor.c \
	pure-data/extra/cyclone/sickle/bitshift.c \
	pure-data/extra/cyclone/sickle/bitxor.c \
	pure-data/extra/cyclone/sickle/buffir.c \
	pure-data/extra/cyclone/sickle/capture.c \
	pure-data/extra/cyclone/sickle/cartopol.c \
	pure-data/extra/cyclone/sickle/change.c \
	pure-data/extra/cyclone/sickle/click.c \
	pure-data/extra/cyclone/sickle/Clip.c \
	pure-data/extra/cyclone/sickle/comb.c \
	pure-data/extra/cyclone/sickle/cosh.c \
	pure-data/extra/cyclone/sickle/cosx.c \
	pure-data/extra/cyclone/sickle/count.c \
	pure-data/extra/cyclone/sickle/curve.c \
	pure-data/extra/cyclone/sickle/cycle.c \
	pure-data/extra/cyclone/sickle/delay.c \
	pure-data/extra/cyclone/sickle/delta.c \
	pure-data/extra/cyclone/sickle/deltaclip.c \
	pure-data/extra/cyclone/sickle/edge.c \
	pure-data/extra/cyclone/sickle/frameaccum.c \
	pure-data/extra/cyclone/sickle/framedelta.c \
	pure-data/extra/cyclone/sickle/index.c \
	pure-data/extra/cyclone/sickle/kink.c \
	pure-data/extra/cyclone/sickle/Line.c \
	pure-data/extra/cyclone/sickle/linedrive.c \
	pure-data/extra/cyclone/sickle/log.c \
	pure-data/extra/cyclone/sickle/lookup.c \
	pure-data/extra/cyclone/sickle/lores.c \
	pure-data/extra/cyclone/sickle/matrix.c \
	pure-data/extra/cyclone/sickle/maximum.c \
	pure-data/extra/cyclone/sickle/minimum.c \
	pure-data/extra/cyclone/sickle/minmax.c \
	pure-data/extra/cyclone/sickle/mstosamps.c \
	pure-data/extra/cyclone/sickle/onepole.c \
	pure-data/extra/cyclone/sickle/overdrive.c \
	pure-data/extra/cyclone/sickle/peakamp.c \
	pure-data/extra/cyclone/sickle/peek.c \
	pure-data/extra/cyclone/sickle/phasewrap.c \
	pure-data/extra/cyclone/sickle/pink.c \
	pure-data/extra/cyclone/sickle/play.c \
	pure-data/extra/cyclone/sickle/poke.c \
	pure-data/extra/cyclone/sickle/poltocar.c \
	pure-data/extra/cyclone/sickle/pong.c \
	pure-data/extra/cyclone/sickle/pow.c \
	pure-data/extra/cyclone/sickle/rampsmooth.c \
	pure-data/extra/cyclone/sickle/rand.c \
	pure-data/extra/cyclone/sickle/record.c \
	pure-data/extra/cyclone/sickle/reson.c \
	pure-data/extra/cyclone/sickle/sah.c \
	pure-data/extra/cyclone/sickle/sampstoms.c \
	pure-data/extra/cyclone/sickle/Scope.c \
	pure-data/extra/cyclone/sickle/sickle.c \
	pure-data/extra/cyclone/sickle/sinh.c \
	pure-data/extra/cyclone/sickle/sinx.c \
	pure-data/extra/cyclone/sickle/slide.c \
	pure-data/extra/cyclone/sickle/Snapshot.c \
	pure-data/extra/cyclone/sickle/spike.c \
	pure-data/extra/cyclone/sickle/svf.c \
	pure-data/extra/cyclone/sickle/tanh.c \
	pure-data/extra/cyclone/sickle/tanx.c \
	pure-data/extra/cyclone/sickle/train.c \
	pure-data/extra/cyclone/sickle/trapezoid.c \
	pure-data/extra/cyclone/sickle/triangle.c \
	pure-data/extra/cyclone/sickle/vectral.c \
	pure-data/extra/cyclone/sickle/wave.c \
	pure-data/extra/cyclone/sickle/zerox.c \
	pure-data/extra/cyclone/shared/unstable/forky.c \
	pure-data/extra/cyclone/shared/unstable/fragile.c \
	pure-data/extra/cyclone/shared/unstable/fringe.c \
	pure-data/extra/cyclone/shared/unstable/loader.c \
	pure-data/extra/oggread~/oggread~.c \
	pure-data/extra/oggread~/libogg-1.3.1/src/bitwise.c \
	pure-data/extra/oggread~/libogg-1.3.1/src/framing.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/analysis.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/bitrate.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/block.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/codebook.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/envelope.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/floor0.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/floor1.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/info.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/lookup.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/lpc.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/lsp.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/mapping0.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/mdct.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/psy.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/registry.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/res0.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/sharedbook.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/smallft.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/synthesis.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/vorbisenc.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/vorbisfile.c \
	pure-data/extra/oggread~/libvorbis-1.3.4/lib/window.c


PDJAVA_JAR_CLASSES = \
	java/org/puredata/core/PdBase.java \
	java/org/puredata/core/NativeLoader.java \
	java/org/puredata/core/PdListener.java \
	java/org/puredata/core/PdMidiListener.java \
	java/org/puredata/core/PdMidiReceiver.java \
	java/org/puredata/core/PdReceiver.java \
	java/org/puredata/core/utils/IoUtils.java \
	java/org/puredata/core/utils/PdDispatcher.java

	
JNI_FILE = libpd_wrapper/util/ringbuffer.c libpd_wrapper/util/z_queued.c \
	jni/z_jni_plain.c
JNIH_FILE = jni/z_jni.h
JAVA_BASE = java/org/puredata/core/PdBase.java
HOOK_SET = libpd_wrapper/util/z_hook_util.c
LIBPD = libs/libpd.$(SOLIB_EXT)
PDCSHARP = libs/libpdcsharp.$(SOLIB_EXT)

PDJAVA_BUILD = java-build
PDJAVA_DIR = $(PDJAVA_BUILD)/org/puredata/core/natives/$(PDNATIVE_PLATFORM)/$(PDNATIVE_ARCH)/
PDJAVA_NATIVE = $(PDJAVA_DIR)/$(SOLIB_PREFIX)pdnative.$(PDNATIVE_SOLIB_EXT)
PDJAVA_JAR = libs/libpd.jar

CFLAGS = -DPD -DHAVE_UNISTD_H -DUSEAPI_DUMMY -I./pure-data/src \
         -I./libpd_wrapper -I./libpd_wrapper/util $(PLATFORM_CFLAGS) \
	 -I./pure-data/extra/cyclone/shared -I./pure-data/extra/cyclone/common \
	 -I./pure-data/extra/oggread~/libogg-1.3.1/include \
	 -I./pure-data/extra/oggread~/libvorbis-1.3.4/include \
	 -I./pure-data/extra/oggread~/libvorbis-1.3.4/lib

.PHONY: libpd csharplib javalib clean clobber

libpd: $(LIBPD)

$(LIBPD): ${PD_FILES:.c=.o}
	$(CC) -o $(LIBPD) $^ $(LDFLAGS) -lm -lpthread 

javalib: $(JNIH_FILE) $(PDJAVA_JAR)

$(JNIH_FILE): $(JAVA_BASE)
	javac -classpath java $^
	javah -o $@ -classpath java org.puredata.core.PdBase

$(PDJAVA_NATIVE): ${PD_FILES:.c=.o} ${JNI_FILE:.c=.o}
	mkdir -p $(PDJAVA_DIR)
	$(CC) -o $(PDJAVA_NATIVE) $^ -lm -lpthread $(JAVA_LDFLAGS) 
	cp $(PDJAVA_NATIVE) libs/

$(PDJAVA_JAR): $(PDJAVA_NATIVE) $(PDJAVA_JAR_CLASSES)
	javac -d $(PDJAVA_BUILD) $(PDJAVA_JAR_CLASSES)
	jar -cvf $(PDJAVA_JAR) -C $(PDJAVA_BUILD) org/puredata/

csharplib: $(PDCSHARP)

$(PDCSHARP): ${PD_FILES:.c=.o} ${HOOK_SET:.c=.o}
	gcc -o $(PDCSHARP) $^ $(CSHARP_LDFLAGS) -lm -lpthread

clean:
	rm -f ${PD_FILES:.c=.o} ${JNI_FILE:.c=.o} ${HOOK_SET:.c=.o}

clobber: clean
	rm -f $(LIBPD) $(PDCSHARP) $(PDJAVA_NATIVE) $(PDJAVA_JAR)
	rm -f libs/`basename $(PDJAVA_NATIVE)`
	rm -rf $(PDJAVA_BUILD)
