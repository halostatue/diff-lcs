@echo off
REM Ruwiki 0.7.0
REM   Copyright © 2002 - 2004, Digikata and HaloStatue
REM   Alan Chen (alan@digikata.com)
REM   Austin Ziegler (ruwiki@halostatue.ca)
REM
REM Licensed under the same terms as Ruby.
REM $Id$
REM
if "%OS%"=="Windows_NT" goto WinNT
ruby -x "ruwiki_servlet" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto done
:WinNT
title Ruwiki
ruby -x "ruwiki_servlet" %*
goto done
:done
