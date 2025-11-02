@echo off
REM =====================================================
REM  Flutter Attendance App File Structure Creator
REM  This script creates folders and empty Dart files
REM =====================================================

REM --- Create main lib folder structure ---
mkdir lib
cd lib

REM Core files
mkdir core
cd core
echo.> env.dart
echo.> http.dart
cd ..

REM Data layer
mkdir data
cd data
mkdir models
mkdir api
cd models
echo.> user.dart
echo.> division.dart
echo.> attendance.dart
cd ..
cd api
echo.> attendance_api.dart
cd ..
cd ..

REM Features (check-in flow)
mkdir features
cd features
mkdir checkin
cd checkin
echo.> check_in_page.dart
echo.> providers.dart
cd ..
cd ..

REM Main entry
echo.> main.dart

cd ..
echo.> .env

echo.
echo ✅ Flutter folder structure created successfully!
echo.
echo Structure created:
echo   lib/core/env.dart
echo   lib/core/http.dart
echo   lib/data/models/user.dart
echo   lib/data/models/division.dart
echo   lib/data/models/attendance.dart
echo   lib/data/api/attendance_api.dart
echo   lib/features/checkin/check_in_page.dart
echo   lib/features/checkin/providers.dart
echo   lib/main.dart
echo   .env
echo.
echo Done!
