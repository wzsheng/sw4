#-----------------------------------------------------------------------
# Usage:
# make sw4 [debug=yes/no]
#
# This Makefile asumes that the following environmental variables have been assigned:
# etree = [yes/no]
# CXX = C++ compiler
# FC  = Fortran-77 compiler
# SW4ROOT = path to third party libraries (used when etree=yes). 
#
# Note: third party libraries should have include files in $(SW4ROOT)/include, libraries in $(SW4ROOT)/lib
#
# The following environmental variables are optional:
# EXTRA_CXX_FLAGS  = additional c++ compiler flags
# EXTRA_FORT_FLAGS = additional fortran compiler flags
# EXTRA_LINK_FLAGS = additional arguments to the linker
#
# There a three ways of assigning the environmental variables:
# 1) Set them in your .cshrc (or similar) file
# 2) Set them in the configs/make.inc file
# 3) Set them on the command line before running make
#
#-----------------------------------------------------------------------
# Do not make changes below this line (don't blame us if you do!)
#-----------------------------------------------------------------------

ifeq ($(debug),yes)
   optlevel = DEBUG
else
   debug := "no"
   optlevel = OPTIMIZE
endif

ifeq ($(optlevel),DEBUG)
   FFLAGS    = -g
   CXXFLAGS  = -g -I../src
   CFLAGS    = -g
else
   FFLAGS   = -O3 
   CXXFLAGS = -O -I../src
   CFLAGS   = -O 
endif

debugdir := debug_v1.0
optdir := optimize_v1.0

fullpath := $(shell pwd)

HOSTNAME := $(shell hostname)
UNAME := $(shell uname)

SW4INC    = $(SW4ROOT)/include
SW4LIB    = $(SW4ROOT)/lib

emptystring := ""
foundincfile := $(emptystring)

# check if the file configs/make.inc exists?
USERMAKE := $(shell if test -r configs/make.inc; then echo "configs/make.inc"; fi)

ifeq ($(USERMAKE),configs/make.inc)
  include configs/make.inc
  foundincfile := "configs/make.inc"
else

# if configs/make.inc does not exist
  ifeq ($(UNAME),Darwin)
  # for Anders' laptop
    ifeq ($(findstring yorkville,$(HOSTNAME)),yorkville)
      include configs/make.yorkville
      foundincfile := "configs/make.yorkville"
    endif
  endif
  
  # put the variables in the configs/make.xyz file
  ifeq ($(UNAME),Linux)
  # For Cab at LC
    ifeq ($(findstring cab,$(HOSTNAME)),cab)
      include configs/make.cab
      foundincfile := "configs/make.cab"
  # for Bjorn's tux box
    else ifeq ($(findstring tux337,$(HOSTNAME)),tux337)
      include configs/make.tux337
      foundincfile := "configs/make.tux337"
  # for Anders' tux box
    else ifeq ($(findstring tux355,$(HOSTNAME)),tux355)
      include configs/make.tux355
      foundincfile := "configs/make.tux355"
  # For Edison at NERSC
    else ifeq ($(findstring edison,$(HOSTNAME)),edison)
      include configs/make.edison
      foundincfile := "configs/make.edison"
  # For Vulcan at LC
    else ifeq ($(findstring vulcan,$(HOSTNAME)),vulcan)
      include configs/make.bgq
      foundincfile := "configs/make.bgq"
    endif
  endif

endif

ifdef EXTRA_CXX_FLAGS
   CXXFLAGS += $(EXTRA_CXX_FLAGS)
endif

ifdef EXTRA_FORT_FLAGS
   FFLAGS += $(EXTRA_FORT_FLAGS)
endif

ifeq ($(etree),yes)
   CXXFLAGS += -DENABLE_ETREE -I$(SW4INC)
   linklibs += -L$(SW4LIB) -lcencalvm -lproj
else
  etree := "no"
endif

ifdef EXTRA_LINK_FLAGS
   linklibs += $(EXTRA_LINK_FLAGS)
endif

ifeq ($(optlevel),DEBUG)
   builddir = $(debugdir)
else
   builddir = $(optdir)
endif

QUADPACK = dqags.o dqagse.o  dqaws.o  dqawse.o  dqc25s.o \
           dqcheb.o  dqelg.o  dqk15w.o  dqk21.o  dqmomo.o \
           dqpsrt.o  dqwgts.o  qaws.o  qawse.o  qc25s.o \
           qcheb.o  qk15w.o  qmomo.o  qpsrt.o  qwgts.o xerror.o d1mach.o r1mach.o

OBJ  = main.o EW.o Sarray.o version.o parseInputFile.o ForcingTwilight.o \
       curvilinearGrid.o boundaryOp.o bcfort.o twilightfort.o rhs4th3fort.o \
       parallelStuff.o Source.o MaterialProperty.o MaterialData.o material.o setupRun.o \
       solve.o solerr3.o Parallel_IO.o Image.o GridPointSource.o MaterialBlock.o testsrc.o \
       TimeSeries.o sacsubc.o SuperGrid.o addsgd.o velsum.o rayleighfort.o energy4.o TestRayleighWave.o \
       MaterialPfile.o Filter.o Polynomial.o SecondOrderSection.o time_functions.o Qspline.o \
       lamb_exact_numquad.o twilightsgfort.o EtreeFile.o MaterialIfile.o GeographicProjection.o \
       rhs4curvilinear.o curvilinear4.o rhs4curvilinearsg.o curvilinear4sg.o gradients.o Image3D.o \
       MaterialVolimagefile.o MaterialInvtest.o \
       invtestmtrl.o projectmtrl.o randomfield3d.o

OBJOPT  = optmain.o EW.o Sarray.o version.o parseInputFile.o ForcingTwilight.o \
       curvilinearGrid.o boundaryOp.o bcfort.o twilightfort.o rhs4th3fort.o \
       parallelStuff.o Source.o MaterialProperty.o MaterialData.o material.o setupRun.o \
       solve.o solerr3.o Parallel_IO.o Image.o GridPointSource.o MaterialBlock.o testsrc.o \
       TimeSeries.o sacsubc.o SuperGrid.o addsgd.o linsolvelu.o velsum.o solve-backward.o \
       rayleighfort.o energy4.o TestRayleighWave.o MaterialPfile.o \
       Filter.o Polynomial.o SecondOrderSection.o time_functions.o Qspline.o \
       lamb_exact_numquad.o twilightsgfort.o EtreeFile.o MaterialIfile.o GeographicProjection.o \
       rhs4curvilinear.o curvilinear4.o rhs4curvilinearsg.o curvilinear4sg.o gradients.o Image3D.o \
       MaterialVolimagefile.o ConvParOutput.o MaterialInvtest.o invtestmtrl.o projectmtrl.o randomfield3d.o

MOBJOPT  = moptmain.o EW.o Sarray.o version.o parseInputFile.o ForcingTwilight.o \
       curvilinearGrid.o boundaryOp.o bcfort.o twilightfort.o rhs4th3fort.o \
       parallelStuff.o Source.o MaterialProperty.o MaterialData.o material.o setupRun.o \
       solve.o solerr3.o Parallel_IO.o Image.o GridPointSource.o MaterialBlock.o testsrc.o \
       TimeSeries.o sacsubc.o SuperGrid.o addsgd.o linsolvelu.o velsum.o solve-backward.o \
       rayleighfort.o energy4.o TestRayleighWave.o MaterialPfile.o \
       Filter.o Polynomial.o SecondOrderSection.o time_functions.o Qspline.o \
       lamb_exact_numquad.o twilightsgfort.o EtreeFile.o MaterialIfile.o GeographicProjection.o \
       rhs4curvilinear.o curvilinear4.o rhs4curvilinearsg.o curvilinear4sg.o solve-allpars.o \
       solve-backward-allpars.o DataPatches.o \
       gradients.o  Image3D.o MaterialVolimagefile.o  MaterialInvtest.o invtestmtrl.o lbfgs.o \
       projectmtrl.o randomfield3d.o nlcg.o MaterialParameterization.o Mopt.o MaterialParCartesian.o \
       InterpolateMaterial.o interpolatemtrl.o

OBJL  = lamb_one_point.o

# prefix object files with build directory
FOBJ = $(addprefix $(builddir)/,$(OBJ)) $(addprefix $(builddir)/,$(QUADPACK))

FOBJOPT = $(addprefix $(builddir)/,$(OBJOPT)) $(addprefix $(builddir)/,$(QUADPACK))

FMOBJOPT = $(addprefix $(builddir)/,$(MOBJOPT)) $(addprefix $(builddir)/,$(QUADPACK))

FOBJL = $(addprefix $(builddir)/,$(OBJL)) $(addprefix $(builddir)/,$(QUADPACK))

sw4: $(FOBJ)
	@echo "*** Configuration file: '" $(foundincfile) "' ***"
	@echo "********* User configuration variables **************"
	@echo "debug=" $(debug) " etree=" $(etree) " SW4ROOT"= $(SW4ROOT) 
	@echo "CXX=" $(CXX) "EXTRA_CXX_FLAGS"= $(EXTRA_CXX_FLAGS)
	@echo "FC=" $(FC) " EXTRA_FORT_FLAGS=" $(EXTRA_FORT_FLAGS)
	@echo "EXTRA_LINK_FLAGS"= $(EXTRA_LINK_FLAGS)
	@echo "******************************************************"
	cd $(builddir); $(CXX) $(CXXFLAGS) -o $@ $(OBJ) $(QUADPACK) $(linklibs)
	@cat wave.txt
	@echo "*** Build directory: " $(builddir) " ***"

sw4opt: $(FOBJOPT)
	@echo "*** Configuration file: '" $(foundincfile) "' ***"
	@echo "********* User configuration variables **************"
	@echo "debug=" $(debug) " etree=" $(etree) " SW4ROOT"= $(SW4ROOT) 
	@echo "CXX=" $(CXX) "EXTRA_CXX_FLAGS"= $(EXTRA_CXX_FLAGS)
	@echo "FC=" $(FC) " EXTRA_FORT_FLAGS=" $(EXTRA_FORT_FLAGS)
	@echo "EXTRA_LINK_FLAGS"= $(EXTRA_LINK_FLAGS)
	@echo "******************************************************"
	cd $(builddir); $(CXX) $(CXXFLAGS) -o $@ $(OBJOPT) $(QUADPACK) $(linklibs)
	@echo " "
	@echo "******* sw4opt was built successfully *******" 
	@echo " "
	@echo "*** Build directory: " $(builddir) " ***"

sw4mopt: $(FMOBJOPT)
	@echo "*** Configuration file: '" $(foundincfile) "' ***"
	@echo "********* User configuration variables **************"
	@echo "debug=" $(debug) " etree=" $(etree) " SW4ROOT"= $(SW4ROOT) 
	@echo "CXX=" $(CXX) "EXTRA_CXX_FLAGS"= $(EXTRA_CXX_FLAGS)
	@echo "FC=" $(FC) " EXTRA_FORT_FLAGS=" $(EXTRA_FORT_FLAGS)
	@echo "EXTRA_LINK_FLAGS"= $(EXTRA_LINK_FLAGS)
	@echo "******************************************************"
	cd $(builddir); $(CXX) $(CXXFLAGS) -o $@ $(MOBJOPT) $(QUADPACK) $(linklibs)
	@echo " "
	@echo "******* sw4mopt was built successfully *******" 
	@echo " "
	@echo "*** Build directory: " $(builddir) " ***"

lamb1: $(FOBJL)
	@echo "*** Configuration file: '" $(foundincfile) "' ***"
	@echo "********* User configuration variables **************"
	@echo "debug=" $(debug) " etree=" $(etree) " SW4ROOT"= $(SW4ROOT) 
	@echo "FC=" $(FC) " EXTRA_FORT_FLAGS=" $(EXTRA_FORT_FLAGS)
	@echo "EXTRA_LINK_FLAGS"= $(EXTRA_LINK_FLAGS)
	@echo "******************************************************"
	cd $(builddir); $(FC) $(FFLAGS) -o $@ $(OBJL) $(QUADPACK) $(linklibs)
#	@cat "Done building lamb1 executable"
#	@echo "*** Build directory: " $(builddir) " ***"

# distribution
tardir := sw4-v1.01
sw4-v1.01.tgz:
	/bin/mkdir -p $(tardir)
	cd $(tardir); cvs -d:ext:petersson1@sourceforge.llnl.gov:/cvsroot/sbp4w checkout .
	cd $(tardir); /bin/rm -rf tests docs opt-src CVSROOT
# remove an empty cvs dir
	cd $(tardir); /bin/rm -rf examples/scec/loh3
# command for sticking in the license blurb in all source code files
	cd $(tardir); python enforceLicense.py Blurb.txt $(fullpath)/$(tardir)
	cd $(tardir); /bin/rm -f enforceLicense.py
	cd $(tardir); /bin/rm -f Blurb.txt
	cd $(tardir); /bin/rm -f Makefile
	cd $(tardir); /bin/mv distMakefile Makefile
	@echo "building tar ball..."
	tar -c --exclude "CVS" -z -f $@ $(tardir)
	rm -rf $(tardir)

$(builddir)/version.o:src/version.C .FORCE
	cd $(builddir); $(CXX) $(CXXFLAGS) -DEW_MADEBY=\"$(USER)\"  -DEW_OPT_LEVEL=\"$(optlevel)\" -DEW_COMPILER=\""$(shell which $(CXX))"\" -DEW_LIBDIR=\"${SW4LIB}\" -DEW_INCDIR=\"${SW4INC}\" -DEW_HOSTNAME=\""$(shell hostname)"\" -DEW_WHEN=\""$(shell date)"\" -c ../$<

# having version.o depend on .FORCE has the effect of always building version.o
.FORCE:

$(builddir)/%.o:src/%.f
	/bin/mkdir -p $(builddir)
	cd $(builddir); $(FC) $(FFLAGS) -c ../$<

$(builddir)/%.o:src/quadpack/%.f
	/bin/mkdir -p $(builddir)
	cd $(builddir); $(FC) $(FFLAGS) -c ../$<

$(builddir)/%.o:src/%.C
	/bin/mkdir -p $(builddir)
	 cd $(builddir); $(CXX) $(CXXFLAGS) -c ../$< 

$(builddir)/%.o:opt-src/%.f
	/bin/mkdir -p $(builddir)
	cd $(builddir); $(FC) $(FFLAGS) -c ../$<

$(builddir)/%.o:opt-src/%.C
	/bin/mkdir -p $(builddir)
	 cd $(builddir); $(CXX) $(CXXFLAGS) -c ../$< 

clean:
	/bin/mkdir -p $(optdir)
	/bin/mkdir -p $(debugdir)
	cd $(optdir); /bin/rm -f sw4 sw4opt sw4mopt $(OBJ) $(OBJOPT) $(MOBJOPT) $(QUADPACK); cd ../$(debugdir); /bin/rm -f sw4 sw4opt $(OBJ) $(OBJOPT) $(MOBJOPT) $(QUADPACK)