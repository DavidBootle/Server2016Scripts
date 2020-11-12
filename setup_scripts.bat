@echo off
set /p directory = "Enter the absolute directory of the folder containing the scripts: "
setx SCRIPTDIR %directory%
echo "Script directory variable has been set to '%directory%'. Access the variable with %%SCRIPTDIR%%."
pause