::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim

::vsim -c -do run.do

vsim -%4 -do "do run.do %0 %1 %2 %3" 