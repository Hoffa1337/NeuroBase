@ECHO OFF
title L4D2 VTX Constructor

echo Initiating VTX re-construction...

set /a count=0

for /r %%F in (.) do (
	Pushd %%F
	
	for %%i in (*.*) do (
		IF "%%~xi" == ".vtx" (
			echo Fixing "%%~ni.mdl".
			
			COPY %%i "%%~ni.dx80.vtx"
			COPY %%i "%%~ni.dx90.vtx"
			
			set /a count+=1
		)
	)
)

echo Reconstructed VTXes. Recommended to run cleaner.bat next.

pause
