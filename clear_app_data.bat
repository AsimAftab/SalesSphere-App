@echo off
echo ========================================
echo  Clearing SalesSphere App Data
echo ========================================
echo.
echo This will:
echo - Uninstall the app completely
echo - Clean Flutter build cache
echo - Rebuild and reinstall
echo.
pause

echo Uninstalling app...
adb uninstall com.salessphere

echo Cleaning Flutter build...
flutter clean

echo Rebuilding and installing...
flutter run

echo.
echo ========================================
echo  Done! You should now see:
echo  1. Blue native splash with your logo
echo  2. Custom animated splash (4s)
echo  3. Onboarding screens (3 pages)
echo ========================================
