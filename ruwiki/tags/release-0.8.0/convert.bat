@echo off
REM Ruwiki 0.8.0
REM   Copyright © 2002 - 2004, Digikata and HaloStatue
REM   Alan Chen (alan@digikata.com)
REM   Austin Ziegler (ruwiki@halostatue.ca)
REM
REM Licensed under the same terms as Ruby.
REM $Id$
REM
if "%OS%"=="Windows_NT" goto WinNT
ruby -x "convert" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto done
:WinNT
ruby -x "convert" %*
goto done
:done
