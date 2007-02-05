@echo off
REM --
REM  Copyright 2004 Austin Ziegler <diff-lcs@halostatue.ca>
REM    adapted from:
REM      Algorithm::Diff (Perl) by Ned Konz <perl@bike-nomad.com>
REM      Smalltalk by Mario I. Wolczko <mario@wolczko.com>
REM    implements McIlroy-Hunt diff algorithm
REM 
REM  This program is free software. It may be redistributed and/or modified under
REM  the terms of the GPL version 2 (or later), the Perl Artistic licence, or the
REM  Ruby licence.
REM  
REM  $Id$
REM ++
if "%OS%"=="Windows_NT" goto WinNT
ruby -x "ldiff" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto done
:WinNT
ruby -x "ldiff" %*
goto done
:done
