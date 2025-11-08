@echo off
echo Creating Attendance feature folder structure...

REM Base directory
set BASE=lib\features\attendance

REM Create folders
mkdir %BASE%
mkdir %BASE%\data
mkdir %BASE%\data\datasources
mkdir %BASE%\data\models
mkdir %BASE%\data\repositories

mkdir %BASE%\domain
mkdir %BASE%\domain\entities
mkdir %BASE%\domain\repositories
mkdir %BASE%\domain\usecases

mkdir %BASE%\presentation
mkdir %BASE%\presentation\providers
mkdir %BASE%\presentation\pages
mkdir %BASE%\presentation\widgets

REM Create empty files

type nul > %BASE%\data\datasources\attendance_remote_ds.dart
type nul > %BASE%\data\models\attendance_model.dart
type nul > %BASE%\data\repositories\attendance_repository_impl.dart

type nul > %BASE%\domain\entities\attendance_entry.dart
type nul > %BASE%\domain\repositories\attendance_repository.dart
type nul > %BASE%\domain\usecases\check_in.dart
type nul > %BASE%\domain\usecases\list_my_attendance.dart

type nul > %BASE%\presentation\providers\attendance_state.dart
type nul > %BASE%\presentation\providers\attendance_controller.dart

type nul > %BASE%\presentation\pages\attendance_page.dart

type nul > %BASE%\presentation\widgets\present_button.dart
type nul > %BASE%\presentation\widgets\attendance_history_list.dart

echo Attendance feature structure created successfully!
pause
