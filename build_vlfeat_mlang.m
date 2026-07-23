function build_vlfeat_mlang(vlroot, cc)
% BUILD_VLFEAT_MLANG  Build the ORIGINAL (unmodified) VLFeat from source for MLang.
%
%   build_vlfeat_mlang()            builds the VLFeat tree containing this file
%                                   (or the current directory if run elsewhere).
%   build_vlfeat_mlang(ROOT)        builds the VLFeat tree at ROOT.
%   build_vlfeat_mlang(ROOT, CC)    additionally forces the C compiler CC
%                                   (name on PATH or full path).
%
%   Supported platforms: Windows (-> toolbox/mex/mexdll) and Linux
%   (-> toolbox/mex/mexso), on x86-64 and ARM (32/64-bit, little-endian).
%   The compiler is auto-detected from: CC argument > $CC env var > gcc >
%   clang > cc. No MATLAB is required; the MEX files are compiled with
%   MLang's own `mex` command against MLang's mex ABI (libmlang), so the
%   binaries produced here run under MLang only (they are NOT MATLAB MEX).
%
%   Prerequisite (MLang side, one-time): MLang's <dist>/include/mex.h must
%   define MWSIZE_MAX (standard MATLAB macro; present in current TyMLangDist).
%   Without it, vlfeat's mexutils.h falls back to a 32-bit mwSize and the
%   compile fails.
%
%   Why NOT vl_compile.m: that tool targets MATLAB + Visual C++ and assumes
%   bin/win64/vl.dll was already produced by vlfeat's own Makefiles; it also
%   omits the defines below, so anything it built with gcc would crash.
%
%   Why the -D flags:
%     -DVL_DISABLE_SSE2/AVX/OPENMP
%         Portable pure-C build. These MUST be identical for the core library
%         and every MEX: vlfeat headers configure struct/inline layouts from
%         them, and a mismatch crashes at run time.
%     -DVL_COMPILER_LLP64        (Windows/MinGW only)
%         vl/host.h does not recognise MinGW-gcc-on-Win64 as an LLP64 target,
%         so vl_size/vl_uindex silently become 32-bit and pointer arithmetic
%         that relies on 64-bit unsigned wrap-around (e.g. vl_alldist2 self
%         mode) corrupts memory. MSVC is auto-detected; MinGW is not.
%     -DVL_ARCH_LITTLE_ENDIAN    (non-x86 little-endian targets, e.g. ARM)
%         vl/host.h only infers endianness for x86/ia64 and otherwise assumes
%         BIG endian, which breaks byte-swapping I/O (vl_ubcread etc.) on ARM.
%         (Do not use this script unmodified on a big-endian machine.)
%
%   Linux runtime linking: the MEX files reference the core library by the
%   ABSOLUTE path of libvl.so (passed to `mex` as a direct linker input, since
%   MLang's mex has no -Wl passthrough). This makes the freshly built tree work
%   with no LD_LIBRARY_PATH. If you MOVE the tree afterwards, either re-run
%   this script or export LD_LIBRARY_PATH=<...>/toolbox/mex/mexso.
%
%   After building, the stock vl_setup.m works unchanged:
%       run('<ROOT>/toolbox/vl_setup.m')      % bindir = mexext = mexdll/mexso

  % ------------------------------------------------------------------ setup
  if nargin < 1 || isempty(vlroot)
      vlroot = fileparts(mfilename('fullpath'));
      if isempty(vlroot), vlroot = pwd; end
  end
  cd(vlroot);

  ext = mexext;                          % mexdll (Windows) / mexso (Linux)
  iswin = strcmp(ext, 'mexdll');
  islinux = strcmp(ext, 'mexso');
  if ~iswin && ~islinux
      error('build_vlfeat_mlang: unsupported platform (mexext=%s); only Windows/Linux are supported.', ext);
  end

  outdir = fullfile(vlroot, 'toolbox', 'mex', ext);
  if ~exist(outdir, 'dir'), mkdir(outdir); end

  % ------------------------------------------------------- compiler discovery
  if nargin < 2 || isempty(cc)
      cand = {getenv('CC'), 'gcc', 'clang', 'cc'};
      cc = '';
      for k = 1:numel(cand)
          if isempty(cand{k}), continue; end
          [st, ~] = system([cand{k} ' --version']);
          if st == 0, cc = cand{k}; break; end
      end
      if isempty(cc)
          error('build_vlfeat_mlang: no C compiler found; install gcc/clang and add it to PATH, or pass the compiler as the 2nd argument.');
      end
  end
  fprintf('build_vlfeat_mlang: platform=%s  compiler=%s\n', ext, cc);

  % ------------------------------------------------------------------ defines
  defs = {'-DVL_DISABLE_SSE2', '-DVL_DISABLE_AVX', '-DVL_DISABLE_OPENMP'};
  if iswin
      % MinGW-gcc-on-Win64 is not recognised as LLP64 by vl/host.h
      defs{end+1} = '-DVL_COMPILER_LLP64';
  else
      % MATLAB's mex.h (via tmwtypes.h) defines EXTERN_C, and vlfeat's
      % mexutils.h relies on it to declare mexErrMsgIdAndTxt. On Windows the
      % MinGW system headers happen to provide "#define EXTERN_C extern", but
      % Linux glibc headers do not, so define it here for MLang's mex.h.
      % (Harmless once MLang's mex.h gains a guarded EXTERN_C block itself.)
      defs{end+1} = '-DEXTERN_C=extern';
      [st, mach] = system('uname -m');
      mach = strtrim(mach);
      if st == 0 && isempty(regexp(mach, '^(x86_64|amd64|i[3-6]86)$', 'once'))
          % ARM / RISC-V etc: vl/host.h would wrongly assume big endian
          defs{end+1} = '-DVL_ARCH_LITTLE_ENDIAN';
          fprintf('build_vlfeat_mlang: non-x86 machine (%s): adding -DVL_ARCH_LITTLE_ENDIAN\n', mach);
      end
  end
  defstr = strjoin(defs, ' ');

  % ------------------------------------------- 1) core library from vl/*.c
  % Enumerate sources explicitly (no shell globbing) and use absolute paths
  % (MLang's system() does not inherit the M working directory).
  vlsrcs = dir(fullfile(vlroot, 'vl', '*.c'));
  srclist = '';
  for k = 1:numel(vlsrcs)
      srclist = [srclist ' "' fullfile(vlroot, 'vl', vlsrcs(k).name) '"']; %#ok<AGROW>
  end

  if iswin
      corelib = fullfile(outdir, 'vl.dll');
      linkout = sprintf('-o "%s" -Wl,--out-implib,"%s"', corelib, fullfile(outdir, 'vl.lib'));
  else
      corelib = fullfile(outdir, 'libvl.so');
      linkout = sprintf('-o "%s"', corelib);   % no soname: MEX will link it by absolute path
  end

  cmd = sprintf(['"%s" -shared -std=c99 -O3 -DNDEBUG -DVL_BUILD_DLL %s ' ...
      '-Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable ' ...
      '-I"%s" -fPIC%s %s'], cc, defstr, vlroot, srclist, linkout);

  if iswin
      % cmd.exe mis-parses a directly-passed command that has a quoted exe path
      % plus many quoted args; a .bat with backslash paths is reliable.
      batfile = strrep(fullfile(outdir, '_build_vlcore.bat'), '/', '\');
      fid = fopen(batfile, 'w'); fprintf(fid, '@echo off\n%s\n', cmd); fclose(fid);
      [st, msg] = system(batfile);
      delete(batfile);
  else
      [st, msg] = system(cmd);
  end
  if st ~= 0 || ~exist(corelib, 'file')
      error('build_vlfeat_mlang: core library build failed:\n%s', msg);
  end
  fprintf('core library built: %s\n', corelib);

  % ------------------------------------------------ 2) all MEX files (MLang)
  % Config-consistent defines; on Linux link the core library by absolute path
  % (direct linker input) so the .mexso resolve it without LD_LIBRARY_PATH.
  if iswin
      linkargs = {['-L' outdir], '-lvl'};
  else
      linkargs = {corelib};
  end
  incargs = {['-I' vlroot], ['-I' fullfile(vlroot, 'toolbox')]};

  cats = dir(fullfile(vlroot, 'toolbox'));
  ok = 0; fail = 0; failnames = {};
  for ci = 1:numel(cats)
      if ~cats(ci).isdir || any(strcmp(cats(ci).name, {'.', '..'})), continue; end
      srcs = dir(fullfile(vlroot, 'toolbox', cats(ci).name, 'vl_*.c'));
      for si = 1:numel(srcs)
          src = fullfile(vlroot, 'toolbox', cats(ci).name, srcs(si).name);
          [~, name, ~] = fileparts(srcs(si).name);
          outfile = fullfile(outdir, [name '.' ext]);
          if exist(outfile, 'file'), delete(outfile); end
          try
              mex(src, incargs{:}, linkargs{:}, defs{:}, '-outdir', outdir);
          catch
          end
          if exist(outfile, 'file')
              ok = ok + 1;
          else
              fail = fail + 1; failnames{end+1} = name; %#ok<AGROW>
              fprintf('FAIL: %s\n', name);
          end
      end
  end
  fprintf('MEX build complete: %d ok, %d fail\n', ok, fail);
  if fail == 0
      fprintf('Done. Use:  run(''%s'')\n', fullfile(vlroot, 'toolbox', 'vl_setup.m'));
  else
      fprintf('Failed MEX: %s\n', strjoin(failnames, ', '));
  end
end
