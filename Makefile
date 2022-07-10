# @file Makefile
#
# Makefile for typesetting LaTeX documents. Requires GNU Make 3.81 on Linux.
#
# Usage:
#   make              #   *.tex --(pdflatex)-->   *.pdf (by default)
#   make foo.dvi      # foo.tex --(latex)-----> foo.dvi
#   make foo.pdf      # foo.tex --(pdflatex)--> foo.pdf
#   make foo.ps       # foo.tex --(latex)-----> foo.dvi
#                               --(dvips)-----> foo.ps
#   make foo.eps      # foo.tex --(latex)-----> foo.dvi
#                               --(dvips,gs)--> foo.eps
#   make foo.tar.gz   # foo.tex --(pdflatex)--> foo.fls
#                               --(tar)-------> foo.tar.gz (for arXiv)
#   make foo.fmt      # foo.tex --(pdflatex)--> foo.fmt (pdfLaTeX, TeXLive only)
#   make dvi          # Create .dvi files.
#   make ps           # Create .ps files.
#   make eps          # Create .eps files.
#   make pdf          # Create .pdf files.
#   make dist         # Create .tar.gz files.
#   make fmt          # Create .fmt files (pdfLaTeX, TeXLive only)
#   make clean        # Remove all generated files.
#   make mostlyclean  # Remove all intermediate files.
#   make watch        # Continuously update .pdf (by default) files.
#   make upgrade      # Upgrade the setup.
#
# The following programs are called when needed in LaTeX typesetting:
#   bibtex, sortref, makeindex, makeglossaries and axohelp
#

# The default typeset type: dvi (latex) or pdf (pdflatex).
default_typeset = pdf

# The default target is making this type of files from all *.tex.
default_target = $(default_typeset)

# Specify if use colors for the output: always, none or auto (default).
make_colors = $(MAKE_COLORS)

# Files not to be included in a distribution.
NODISTFILES =

# Extra files to be included in a distribution.
EXTRADISTFILES =

# Files to be copied in "anc" directory in a distribution.
ANCILLARYFILES =

# Additional files to mostly-clean.
MOSTLYCLEANFILES =

# Additional files to clean.
CLEANFILES =

# Prerequisite make targets in subdirectories.
PREREQUISITE_SUBDIRS =

# Test scripts.
TESTS =

# The following variables will be guessed if empty.
TARGET = presentation.tex
SUBDIRS =
LATEX = xelatex
PDFLATEX = xelatex
DVIPS =
DVIPDF =
GS =
BIBTEX = bibtex
SORTREF =
MAKEINDEX =
MAKEGLOSSARIES =
KPSEWHICH =
AXOHELP =
PDFCROP =
EBB =
EXTRACTBB =
SOFFICE =

# Command options.
LATEX_OPT = -interaction=nonstopmode -halt-on-error
PDFLATEX_OPT = -interaction=nonstopmode -halt-on-error
DVIPS_OPT = -Ppdf -z
DVIPDF_OPT =
GS_OPT =
BIBTEX_OPT =
SORTREF_OPT =
MAKEINDEX_OPT =
MAKEGLOSSARIES_OPT =
KPSEWHICH_OPT =
AXOHELP_OPT =
PDFCROP_OPT =
EBB_OPT =
EXTRACTBB_OPT =
SOFFICE_OPT =

# The following lines enable use of platex+dvipdfmx to create pdf files.
#LATEX = platex
#PDFLATEX = ptex2pdf
#BIBTEX = pbibtex
#MAKEINDEX = mendex
#PDFLATEX_OPT = -l -ot '-interaction=nonstopmode -halt-on-error -recorder'

use_platex_dvipdfmx = \
	$(eval LATEX = platex) \
	$(eval PDFLATEX = ptex2pdf) \
	$(eval BIBTEX = pbibtex) \
	$(eval MAKEINDEX = mendex) \
	$(eval PDFLATEX_OPT = -l -ot '-interaction=nonstopmode -halt-on-error -recorder')

# The following lines enable use of uplatex+dvipdfmx to create pdf files.
#LATEX = uplatex
#PDFLATEX = ptex2pdf
#BIBTEX = upbibtex
#MAKEINDEX = upmendex
#PDFLATEX_OPT = -u -l -ot '-interaction=nonstopmode -halt-on-error -recorder'

use_uplatex_dvipdfmx = \
	$(eval LATEX = uplatex) \
	$(eval PDFLATEX = ptex2pdf) \
	$(eval BIBTEX = upbibtex) \
	$(eval MAKEINDEX = upmendex) \
	$(eval PDFLATEX_OPT = -u -l -ot '-interaction=nonstopmode -halt-on-error -recorder')

# The following lines enable use of lualatex to create pdf files.
#LATEX = lualatex
#PDFLATEX = lualatex
#BIBTEX = upbibtex
#MAKEINDEX = upmendex

use_lualatex = \
	$(eval LATEX = lualatex) \
	$(eval PDFLATEX = lualatex) \
	$(eval BIBTEX = upbibtex) \
	$(eval MAKEINDEX = upmendex)

# ANSI escape code for colorization.
CL_NORMAL = [0m
CL_NOTICE = [32m
CL_WARN   = [35m
CL_ERROR  = [31m

.SUFFIXES:
.SUFFIXES: .log .pdf .odt .eps .ps .jpg .dvi .fmt .tex .cls .sty .ltx .dtx

DEPDIR = .dep

# $(call cache,VARIABLE) expands $(VARIABLE) with caching.
# See https://www.cmcrossroads.com/article/makefile-optimization-eval-and-macro-caching
cache = $(if $(is_cached-$1),,$(eval is_cached-$1 := 1)$(eval cached_val-$1 := $($1)))$(cached_val-$1)

# $(call type,EXEC-FILE) gives the path to the executable if found,
# otherwise empty.
type = $(if $(strip $1),$(strip \
	$(eval type_retval := $(shell which '$(strip $1)' 2>/dev/null)) \
	$(if $(filter-out $(firstword $(type_retval)),$(type_retval)), \
		$(eval type_retval := '$(type_retval)') \
	) \
	$(type_retval) \
))

# $(call pathsearch,PROG-NAME,NOERROR-IF-NOT-FOUND,NAME1,...) tries to find
# the given executable.
pathsearch = $(strip \
	$(eval retval := ) \
	$(call pathsearch_impl,$3,$4,$5,$6,$7,$8,$9) \
	$(if $2$(retval),,$(eval retval := \
		$(call error_message,$1 not found); \
		exit 1; :)) \
	$(retval) \
)

pathsearch_impl = \
	$(if $(retval),,$(eval retval := $(call type,$1))) \
	$(if $(retval),,$(if $(strip $2 $3 $4 $5 $6 $7 $8 $9),$(call pathsearch_impl,$2,$3,$4,$5,$6,$7,$8,$9)))

# $(target)
target = $(call cache,target_impl)

target_impl = $(strip \
	$(target_impl_from_ltx) \
	$(target_impl_from_tex) \
)

target_impl_from_ltx = $(srcltxfiles:.ltx=.fmt)

target_impl_from_tex = $(strip \
	$(eval retval := ) \
	$(if $(retval),,$(eval retval := $(TARGET))) \
	$(if $(retval),,$(eval retval := $(srctexfiles:.tex=.$(default_target)))) \
	$(retval) \
)

# $(target_basename)
target_basename = $(call cache,target_basename_impl)

target_basename_impl = $(basename $(target))

# $(srctexfiles)
srctexfiles = $(call cache,srctexfiles_impl)

srctexfiles_impl = $(strip $(sort \
	$(shell grep documentclass -l *.tex 2>/dev/null) \
	$(shell awk 'FNR==1{if ($$0~"%&") print FILENAME;}' *.tex 2>/dev/null) \
))

# $(srcltxfiles)
srcltxfiles = $(call cache,srcltxfiles_impl)

srcltxfiles_impl = $(wildcard *.ltx)

# $(srcdtxfiles)
srcdtxfiles = $(call cache,srcdtxfiles_impl)

srcdtxfiles_impl = $(wildcard *.dtx)

# $(subdirs)
subdirs = $(call cache,subdirs_impl)

subdirs_impl = $(strip \
	$(eval retval := ) \
	$(if $(retval),,$(eval retval := $(SUBDIRS))) \
	$(if $(retval),,$(eval retval := $(dir $(wildcard */Makefile)))) \
	$(retval) \
)

# $(latex)
latex = $(call cache,latex_impl)

latex_impl = $(strip \
	$(latex_noopt) $(LATEX_OPT) \
	$(if $(findstring -recorder,$(LATEX_OPT)),,-recorder) \
)

latex_noopt = $(call cache,latex_noopt_impl)

latex_noopt_impl = $(call pathsearch,latex,,$(LATEX),latex)

# $(pdflatex)

pdflatex = $(call cache,pdflatex_impl)

pdflatex_impl = $(strip \
	$(pdflatex_noopt) $(PDFLATEX_OPT) \
	$(if $(findstring -recorder,$(PDFLATEX_OPT)),,-recorder) \
)

pdflatex_noopt = $(call cache,pdflatex_noopt_impl)

pdflatex_noopt_impl = $(call pathsearch,pdflatex,,$(PDFLATEX),pdflatex)

# $(dvips)
dvips = $(call cache,dvips_impl) $(DVIPS_OPT)

dvips_impl = $(call pathsearch,dvips,,$(DVIPS),dvips,dvipsk)

# $(dvipdf)
dvipdf = $(call cache,dvipdf_impl) $(DVIPDF_OPT)

dvipdf_impl = $(call pathsearch,dvipdf,,$(DVIPDF),dvipdfm,dvipdfmx,dvipdf)

# $(gs)
gs = $(call cache,gs_impl) $(GS_OPT)

gs_impl = $(call pathsearch,gs,,$(GS),gs,gswin32,gswin64,gsos2)

# $(bibtex)
bibtex = $(call cache,bibtex_impl) $(BIBTEX_OPT)

bibtex_impl = $(call pathsearch,bibtex,,$(BIBTEX),bibtex)

# $(sortref)
sortref = $(call cache,sortref_impl) $(SORTREF_OPT)

sortref_impl = $(call pathsearch,sortref,,$(SORTREF),sortref)

# $(makeindex)
makeindex = $(call cache,makeindex_impl) $(MAKEINDEX_OPT)

makeindex_impl = $(call pathsearch,makeindex,,$(MAKEINDEX),makeindex)

# $(makeglossaries)
makeglossaries = $(call cache,makeglossaries_impl) $(MAKEGLOSSARIES_OPT)

makeglossaries_impl = $(call pathsearch,makeglossaries,,$(MAKEGLOSSARIES),makeglossaries)

# $(kpsewhich)
kpsewhich = $(call cache,kpsewhich_impl) $(KPSEWHICH_OPT)

kpsewhich_impl = $(call pathsearch,kpsewhich,,$(KPSEWHICH),kpsewhich)

# $(axohelp)
axohelp = $(call cache,axohelp_impl) $(AXOHELP_OPT)

axohelp_impl = $(call pathsearch,axohelp,,$(AXOHELP),axohelp)

# $(pdfcrop)
pdfcrop = $(call cache,pdfcrop_impl) $(PDFCROP_OPT)

pdfcrop_impl = $(call pathsearch,pdfcrop,,$(PDFCROP),pdfcrop)

# $(ebb)
ebb = $(call cache,ebb_impl) $(EBB_OPT)

ebb_impl = $(call pathsearch,ebb,,$(EBB),ebb)

# $(extractbb)
extractbb = $(call cache,extractbb_impl) $(EXTRACTBB_OPT)

extractbb_impl = $(call pathsearch,extractbb,,$(EXTRACTBB),extractbb)

# $(soffice)
soffice = $(call cache,soffice_impl) $(SOFFICE_OPT)

soffice_impl = $(call pathsearch,soffice,, \
	$(SOFFICE), \
	soffice, \
	/cygdrive/c/Program Files/LibreOffice 6/program/soffice, \
	/cygdrive/c/Program Files (x86)/LibreOffice 6/program/soffice, \
	/cygdrive/c/Program Files/LibreOffice 5/program/soffice, \
	/cygdrive/c/Program Files (x86)/LibreOffice 5/program/soffice, \
	/cygdrive/c/Program Files/LibreOffice 4/program/soffice, \
	/cygdrive/c/Program Files (x86)/LibreOffice 4/program/soffice \
)

# $(mostlycleanfiles)
mostlycleanfiles = $(call cache,mostlycleanfiles_impl)

mostlycleanfiles_impl = $(wildcard $(strip \
	$(srctexfiles:.tex=.aux) \
	$(srctexfiles:.tex=.ax1) \
	$(srctexfiles:.tex=.ax2) \
	$(srctexfiles:.tex=.bbl) \
	$(srctexfiles:.tex=.blg) \
	$(srctexfiles:.tex=.end) \
	$(srctexfiles:.tex=.fls) \
	$(srctexfiles:.tex=.fmt) \
	$(srctexfiles:.tex=.glg) \
	$(srctexfiles:.tex=.glo) \
	$(srctexfiles:.tex=.gls) \
	$(srctexfiles:.tex=.idx) \
	$(srctexfiles:.tex=.ilg) \
	$(srctexfiles:.tex=.ind) \
	$(srctexfiles:.tex=.ist) \
	$(srctexfiles:.tex=.lof) \
	$(srctexfiles:.tex=.log) \
	$(srctexfiles:.tex=.lot) \
	$(srctexfiles:.tex=.nav) \
	$(srctexfiles:.tex=.out) \
	$(srctexfiles:.tex=.snm) \
	$(srctexfiles:.tex=.spl) \
	$(srctexfiles:.tex=.toc) \
	$(srctexfiles:.tex=.*.vrb) \
	$(srctexfiles:.tex=.xdy) \
	$(srctexfiles:.tex=Notes.bib) \
	$(srctexfiles:.tex=_ref.tex) \
	$(srcltxfiles:.ltx=.log) \
	*.bmc \
	*.pbm \
	*-eps-converted-to.pdf \
	*/*-eps-converted-to.pdf \
	$(MOSTLYCLEANFILES) \
))

# $(cleanfiles)
cleanfiles = $(call cache,cleanfiles_impl)

cleanfiles_impl = $(wildcard $(strip \
	$(srctexfiles:.tex=.tar.gz) \
	$(srctexfiles:.tex=.pdf) \
	$(srctexfiles:.tex=.ps) \
	$(srctexfiles:.tex=.eps) \
	$(srctexfiles:.tex=.dvi) \
	$(srcltxfiles:.ltx=.fmt) \
	$(srcdtxfiles:.dtx=.cls) \
	$(srcdtxfiles:.dtx=.sty) \
	$(CLEANFILES) \
	$(mostlycleanfiles) \
))

# $(call colorize,COMMAND-WITH-COLOR,COMMAND-WITHOUT-COLOR)
colorize = \
	if [ "$(make_colors)" = "always" ]; then \
		$1; \
	elif [ "$(make_colors)" = "none" ]; then \
		$2; \
	else \
		if [ -t 1 ]; then \
			$1; \
		else \
			$2; \
		fi; \
	fi

# $(call error_message,MESSAGE)
error_message = \
	$(call colorize, \
		printf "\033$(CL_ERROR)Error: $1\033$(CL_NORMAL)\n" >&2 \
	, \
		echo "Error: $1" >&2 \
	)

# $(call exec,COMMAND)
# $(call exec,COMMAND,false)
exec = \
	$(if $(and $(findstring not found,$1),$(findstring exit 1,$1)), \
		$1 \
	, \
		failed=false; \
		$(call colorize, \
			printf "\033$(CL_NOTICE)$1\033$(CL_NORMAL)\n"; \
			exec 3>&1; \
			pipe_status=`{ { $1 3>&- 4>&-; echo $$? 1>&4; } | \
					 $(colorize_output) >&3; } 4>&1`; \
			exec 3>&-; \
			[ "$$pipe_status" = 0 ] || failed=: \
		, \
			echo "$1"; \
			$1 || failed=: \
		) \
		$(if $2,,; $(check_failed)) \
	)

# $(check_failed)
check_failed = $$failed && { [ -n "$dont_delete_on_failure" ] || rm -f $@; exit 1; }; :

# $(colorize_output)
colorize_output = \
	sed 's/^\(!.*\)/\$\$\x1b$(CL_ERROR)\1\$\$\x1b$(CL_NORMAL)/; \
	     s/^\(LaTeX[^W]*Warning.*\|Package[^W]*Warning.*\|Class[^W]*Warning.*\|No pages of output.*\|Underfull.*\|Overfull.*\|Warning--.*\)/\$\$\x1b$(CL_WARN)\1\$\$\x1b$(CL_NORMAL)/'

# $(call cmpver,VER1,OP,VER2)
cmpver = { \
	cmpver_ver1_="$1"; \
	cmpver_ver2_="$3"; \
	$(call cmpver_fmt_,cmpver_ver1_); \
	$(call cmpver_fmt_,cmpver_ver2_); \
	$(if $(filter -eq,$2), \
		[ $$cmpver_ver1_ = $$cmpver_ver2_ ]; \
	, \
		$(if $(filter -ne,$2), \
			[ $$cmpver_ver1_ != $$cmpver_ver2_ ]; \
		, \
			cmpver_small_=`{ echo $$cmpver_ver1_; echo $$cmpver_ver2_; } | sort | head -1`; \
			$(if $(filter -le,$2),[ $$cmpver_small_ = $$cmpver_ver1_ ];) \
			$(if $(filter -lt,$2),[ $$cmpver_small_ = $$cmpver_ver1_ ] && [ $$cmpver_ver1_ != $$cmpver_ver2_ ];) \
			$(if $(filter -ge,$2),[ $$cmpver_small_ = $$cmpver_ver2_ ];) \
			$(if $(filter -gt,$2),[ $$cmpver_small_ = $$cmpver_ver2_ ] && [ $$cmpver_ver1_ != $$cmpver_ver2_ ];) \
		) \
	) \
	}

# $(call cmpver_fmt_,VAR)
cmpver_fmt_ = \
	$1=`expr "$$$1" : '[^0-9]*\([0-9][0-9]*\(\.[0-9][0-9]*\)*\)' | sed 's/\./ /g'`; \
	$1=`printf '%05d' $$$1`

##

all: $(target)

dvi: $(target_basename:=.dvi)

ps: $(target_basename:=.ps)

eps: $(target_basename:=.eps)

pdf: $(target_basename:=.pdf)

dist: $(target_basename:=.tar.gz)

fmt: $(target_basename:=.fmt)

ifneq ($(subdirs),)

$(target_basename:=.dvi) \
$(target_basename:=.ps) \
$(target_basename:=.eps) \
$(target_basename:=.pdf): | prerequisite

prerequisite:
	@for dir in $(subdirs); do \
		$(MAKE) -C $$dir $(PREREQUISITE_SUBDIRS); \
	done; :

endif

mostlyclean:
	@for dir in $(subdirs); do \
		$(MAKE) -C $$dir mostlyclean; \
	done; :
	@$(if $(mostlycleanfiles),$(call exec,rm -f $(mostlycleanfiles)))
	@$(if $(wildcard $(DEPDIR)),$(call exec,rm -rf $(DEPDIR)))

clean:
	@for dir in $(subdirs); do \
		$(MAKE) -C $$dir clean; \
	done; :
	@$(if $(cleanfiles),$(call exec,rm -f $(cleanfiles)))
	@$(if $(wildcard $(DEPDIR)),$(call exec,rm -rf $(DEPDIR)))

check:
	@for dir in $(subdirs); do \
		$(MAKE) -C $$dir check; \
	done
	@for test in $(TESTS); do \
		if [ -f "$$test" ]; then \
			$(call exec,./$$test); \
		else \
			$(call exec,$$test); \
		fi; \
	done

# The "watch" mode. Try .log instead of .pdf/.dvi files, otherwise make would
# continuously try to typeset for sources previously failed.
watch:
	@echo "Watching for $(srctexfiles:.tex=.$(default_target)). Press Ctrl+C to quit"
	@while :; do \
		$(MAKE) --silent $(srctexfiles:.tex=.log); \
		sleep 1; \
	done

# Upgrade files in the setup. (Be careful!)
upgrade:
	@$(call exec,wget -q https://gist.githubusercontent.com/tueda/11294821/raw/Makefile -O Makefile)
	@$(call exec,wget -q https://gist.githubusercontent.com/tueda/da7a3d0bb83b7d0cbed998b4a231afb8/raw/.gitignore -O .gitignore)

.PHONY : all dvi ps eps pdf dist fmt prerequisite mostlyclean clean check watch upgrade

# $(call typeset,LATEX-COMMAND)
# $(call typeset,LATEX-COMMAND,false)
typeset = \
	rmfile=$@; \
	$(if $2,rmfile=;dont_delete_on_failure=1;) \
	oldfile=$*.tmp$$$$.$$RANDOM$$RANDOM; \
	trap 'rm -f $$rmfile $$oldfile*' 0 1 2 3 15; \
	failed=false; \
	if [ -f '$@' ]; then \
		need_latex=$(if $(filter-out %.ref %.bib %.bst %.idx %.glo,$?),:,false); \
		need_bibtex=$(if $(filter %.bib %.bst,$?),:,false); \
		need_sortref=$(if $(filter %.ref,$?),:,false); \
		need_makeindex=$(if $(filter %.idx,$?),:,false); \
		need_makeglossaries=$(if $(filter %.glo,$?),:,false); \
		need_axohelp=$(if $(filter %.ax2,$?),:,false); \
		if $$need_sortref || $$need_bibtex; then \
			[ ! -f '$*.aux' ] && need_latex=:; \
		fi; \
	else \
		need_latex=:; \
		need_bibtex=false; \
		need_sortref=false; \
		need_makeindex=false; \
		need_makeglossaries=false; \
		need_axohelp=false; \
	fi; \
	$(call do_latex,$1,false); \
	if $$failed && $(check_noreffile); then \
		need_sortref=:; \
		failed=false; \
	else \
		$(check_failed); \
	fi; \
	for i in 1 2 3 4 5; do \
		$(do_bibtex); \
		$(do_sortref); \
		$(do_makeindex); \
		$(do_makeglossaries); \
		$(do_axohelp); \
		$(call do_latex,$1); \
	done; \
	touch $@; \
	rmfile=; \
	$(call flsdep,$@,$*.fls); \
	$(call blgdep,$@,$*.blg); \
	$(check_reffile) && $(call refdep,$@,$(<:.tex=.ref)); \
	:

# $(call do-backup,FILE,INDEX)
do_backup = \
	if [ -f '$1' ]; then \
		cp '$1' "$$oldfile"$2; \
	else \
		rm -f "$$oldfile"$2; \
		touch "$$oldfile"$2; \
	fi

# $(call check_modified,FILE,INDEX)
check_modified = \
	if diff -q "$$oldfile"$2 '$1' >/dev/null 2>&1; then false; else :; fi

# $(call do-latex,LATEX-COMMAND)
# $(call do-latex,LATEX-COMMAND,false)
do_latex = \
	if $$need_latex; then \
		need_latex=false; \
		$(call do_backup,$*.aux); \
		$(call do_backup,$*.idx,2); \
		$(call do_backup,$*.glo,3); \
		$(call do_backup,$*.ax1,4); \
		$(call exec,$1 $<,$2); \
		if $(call check_modified,$*.aux); then \
			$(check_bblfile) && need_bibtex=:; \
			$(check_reffile) && need_sortref=:; \
			$(check_glsfile) && need_makeglossaries=:; \
		fi; \
		if $(call check_modified,$*.idx,2); then \
			$(check_indfile) && need_makeindex=:; \
		fi; \
		if $(call check_modified,$*.glo,3); then \
			$(check_glsfile) && need_makeglossaries=:; \
		fi; \
		if $(call check_modified,$*.ax1,4); then \
			$(check_ax2file) && need_axohelp=:; \
		fi; \
		$(check_rerun) && need_latex=:; \
	fi

# $(do_bibtex)
do_bibtex = \
	if $$need_bibtex; then \
		need_bibtex=false; \
		$(call do_backup,$*.bbl); \
		$(call exec,$(bibtex) $(<:.tex=)); \
		$(call check_modified,$*.bbl) && need_latex=:; \
	fi

# $(do_sortref)
do_sortref = \
	if $$need_sortref; then \
		need_sortref=false; \
		$(call do_backup,$*_ref.tex); \
		$(call exec,$(sortref) $< $(<:.tex=.ref)); \
		$(call check_modified,$*_ref.tex) && need_latex=:; \
	fi

# $(do_makeindex)
do_makeindex = \
	if $$need_makeindex; then \
		need_makeindex=false; \
		$(call do_backup,$*.ind); \
		$(call exec,$(makeindex) $(<:.tex=)); \
		$(call check_modified,$*.ind) && need_latex=:; \
	fi

# $(do_makeglossaries)
do_makeglossaries = \
	if $$need_makeglossaries; then \
		need_makeglossaries=false; \
		$(call do_backup,$*.gls); \
		$(call exec,$(makeglossaries) $(<:.tex=)); \
		$(call check_modified,$*.gls) && need_latex=:; \
	fi

# $(do_axohelp)
do_axohelp = \
	if $$need_axohelp; then \
		need_axohelp=false; \
		$(call do_backup,$*.ax2); \
		$(call exec,$(axohelp) $(<:.tex=)); \
		$(call check_modified,$*.ax2) && need_latex=:; \
	fi

# $(call do_kpsewhich,FULLPATH-DEST-VAR,FILE)
do_kpsewhich = \
	fullpath_kpsewhich_impl=`$(kpsewhich) "$2"`; \
	if [ -z "$$fullpath_kpsewhich_impl" ]; then \
		$(call error_message,$2 not found); \
		exit 1; \
	fi; \
	$1=$$fullpath_kpsewhich_impl

# $(call flsdep,TARGET,FLS-FILE)
flsdep = \
	if [ -f '$2' ]; then \
		mkdir -p $(DEPDIR); \
		{ \
			for f in `grep INPUT '$2' | sed 's/INPUT *\(\.\/\)\?//' | sort | uniq`; do \
				case $$f in \
					*:*|/*) ;; \
					*.fmt) ;; \
					*) [ -f "$$f" ] && echo "$1 : \$$(wildcard $$f)";; \
				esac; \
			done; \
		} >$(DEPDIR)/$1.fls.d; \
	fi

# $(call blgdep,TARGET,BLG-FILE)
blgdep = \
	if [ -f '$2' ]; then \
		mkdir -p $(DEPDIR); \
		{ \
			for f in `{ grep 'Database file [^:]*:' '$2'; grep 'The style file:' '$2'; } | sed 's/[^:]*://'`; do \
				[ -f "$$f" ] && echo "$1 : \$$(wildcard $$f)"; \
			done; \
		} >$(DEPDIR)/$1.blg.d; \
	fi

# $(call refdep,TARGET,REF-FILE)
refdep = \
	if [ -f '$2' ]; then \
		mkdir -p $(DEPDIR); \
		echo '$1: $2' >$(DEPDIR)/$1.ref.d; \
	fi

check_noreffile = grep "File \`$*_ref.tex' not found" $*.log >/dev/null 2>&1

check_bblfile = grep '$*.bbl' $*.log >/dev/null 2>&1

check_reffile = grep '$*_ref.tex' $*.log >/dev/null 2>&1

check_indfile = grep '$*.ind' $*.log >/dev/null 2>&1

check_glsfile = grep '$*.gls' $*.log >/dev/null 2>&1

# axodraw2.sty uses primitive control sequences for reading .ax2 file, instead
# of \input, without writing any jobname.ax2 in the log file. So we look for
# jobname.ax1; if it is found in the log file, it means axodraw2.sty tries to
# read jobname.ax2.
check_ax2file = grep '$*.ax1' $*.log >/dev/null 2>&1

check_rerun = grep 'Rerun' $*.log | grep -v 'Package: rerunfilecheck\|rerunfilecheck.sty' >/dev/null 2>&1

.tex.dvi:
	@$(call typeset,$(latex))

.tex.pdf:
	@$(call typeset,$(pdflatex))

.tex.log:
	@$(call typeset,$(if $(filter $(default_target),dvi),$(latex),$(pdflatex)),false)

.dvi.ps:
	@$(call exec,$(dvips) $<)

#.dvi.pdf:
#	@$(call exec,$(dvipdf) $<)

.dvi.eps:
	@trap 'rm -f $*.tmp.ps $*.tmp.pdf' 0 1 2 3 15; \
	$(call exec,$(dvips) -o $*.tmp.ps $<); \
	$(call exec,$(gs) -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dEPSCrop -o $*.tmp.pdf $*.tmp.ps); \
	if $(call cmpver,`$(gs) --version`,-lt,9.15); then \
		$(call exec,$(gs) -sDEVICE=epswrite -o $@ $*.tmp.pdf); \
	else \
		$(call exec,$(gs) -sDEVICE=eps2write -o $@ $*.tmp.pdf); \
	fi

# Experimental: only for pdflatex (TeXLive)
.ltx.fmt:
	@$(call exec,$(pdflatex_noopt) -ini -jobname='$*' '&$(notdir $(basename $(pdflatex_noopt))) $<\dump')
	@$(call exec,rm -f $*.pdf)

# Experimental: only for pdflatex (TeXLive)
#
# Example:
#   $ cat foo.tex
#   %&foo
#   \documentclass{beamer}
#   \begin{document}
#   \begin{frame}
#   Your presentation here.
#   \end{frame}
#   \end{document}
#   $ make clean
#   $ time make foo.pdf
#   $ make clean
#   $ time { make foo.fmt && make foo.pdf; }
#
# Note: axodraw2 checks if .ax2 file exists when loaded, which becomes a problem
#   if one includes it in a format file: whether or not .ax2 file exists is
#   stores in a format file.
#
.tex.fmt:
	@$(call exec,$(pdflatex_noopt) -ini -jobname='$*' '&pdflatex' mylatexformat.ltx '$<')
	@$(call exec,rm -f $*.pdf)

.dtx.cls:
	@$(call exec,$(latex_noopt) $(basename $<).ins)

.dtx.sty:
	@$(call exec,$(latex_noopt) $(basename $<).ins)

.odt.pdf:
	@$(call exec,$(soffice) --headless --nologo --nofirststartwizard --convert-to pdf $<)

# A distribution (for arXiv) needs to include
# 1. The main tex file.
# 2. Files that the main tex file depends on, except
#    - files with absolute paths, which are considered as system files,
#    - files created by LaTeX during typesetting, e.g., *.aux files,
#    - *.ax2 file unless "\pdfoutput=1" is explicitly used.
#    This default behaviour may be overwritten by EXTRADISTFILES and
#    NODISTFILES.
# 3. 00README.XXX file if exists, and
#    - Files listed in 00README.XXX with "ignore".
#    See https://arxiv.org/help/00README
# 4. Files listed in ANCILLARYFILES are included under a subdirectory "anc".
#    See https://arxiv.org/help/ancillary_files
%.tar.gz: %.$(default_target)
	@tmpdir=tmp$$$$_$$RANDOM$$RANDOM; \
	mkdir $$tmpdir || exit 1; \
	trap 'rm -rf $$tmpdir' 0 1 2 3 15; \
	pdfoutput=false; \
	if head -5 "$*.tex" | sed 's/%.*//' | grep -q '\pdfoutput=1'; then \
		pdfoutput=:; \
	fi; \
	if [ ! -f '$*.fls' ]; then \
		$(call error_message,$*.fls not found. Delete $*.$(default_target) and then retry); \
		exit 1; \
	fi; \
	dep_files=; \
	for f in `grep INPUT '$*.fls' | sed 's/INPUT *\(\.\/\)\?//' | sed '/^kpsewhich/d' | sort | uniq`; do \
		case $$f in \
			*:*|/*|*.aux|*.lof|*.lot|*.nav|*.out|*.spl|*.toc|*.vrb|*-eps-converted-to.pdf) ;; \
			*) \
				case $$f in \
					*.ax2) \
						$$pdfoutput || continue; \
						;; \
				esac; \
				ok=:; \
				for ff in $(NODISTFILES); do \
					if [ "x$$f" = "x$$ff" ]; then \
						ok=false; \
						break; \
					fi; \
				done; \
				if $$ok; then \
					d=`dirname "$$f"`; \
					mkdir -p "$$tmpdir/$$d"; \
					cp "$$f" "$$tmpdir/$$d" || exit 1; \
					dep_files="$$dep_files $$f"; \
				fi;; \
		esac; \
	done; \
	for ff in $(EXTRADISTFILES); do \
		$(call do_kpsewhich,f,$$ff); \
		cp "$$f" "$$tmpdir/" || exit 1; \
		dep_files="$$dep_files $$f"; \
	done; \
	if [ -f 00README.XXX ]; then \
		cp "00README.XXX" "$$tmpdir/" || exit 1; \
		dep_files="$$dep_files 00README.XXX"; \
		for f in `grep ignore 00README.XXX | sed 's/ *ignore *$$//'`; do \
			cp --parents "$$f" "$$tmpdir/" || rsync -R "$$f" "$$tmpdir" || exit 1; \
			dep_files="$$dep_files $$f"; \
		done; \
	fi; \
	for f in $(ANCILLARYFILES); do \
		[ -d "$$tmpdir/anc" ] || mkdir "$$tmpdir/anc"; \
		cp "$$f" "$$tmpdir/anc/" || exit 1; \
		dep_files="$$dep_files $$f"; \
	done; \
	mkdir -p $(DEPDIR); \
	{ \
		for f in $$dep_files; do \
			echo "$@ : \$$(wildcard $$f)"; \
		done; \
	} >$(DEPDIR)/$@.d; \
	cd $$tmpdir || exit 1; \
	$(call exec,tar cfv - * | gzip -9 -n >$@,false); \
	cd .. || exit 1; \
	$(check_failed); \
	mv $$tmpdir/$@ $@

-include $(DEPDIR)/*.d
-include .rc.mk  # runtime configuration for make
