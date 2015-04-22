@ECHO OFF
title L4D2 VTX Constructor Post-Process

echo VTX Re-construction cleaner initiated...

set /a count=0

for /r %%F in (.) do (
	Pushd %%F
	
	for %%i in (*.*) do (
		if "%%~xi" == ".mdl" (
			echo Checking %%~ni.mdl for duplicates.
			
			IF EXIST %%~ni.dx80.dx80.vtx (
				del %%~ni.dx80.dx80.vtx
				del %%~ni.dx90.dx90.vtx
				del %%~ni.dx80.dx90.vtx
				del %%~ni.dx90.dx80.vtx
				
				echo Cleaned up duplicate VTXs for %%~ni.mdl
			)
		)
	)
)

echo Re-construction cleaner finished.

pause