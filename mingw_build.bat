SET MINGW=c:\MinGW-full-20101119
SET MSYS=c:\MinGW-full-20101119\msys\1.0
SET MINGW32=c:\MinGW-full-20101119\mingw_32
SET PATH=%MINGW32%\bin;%MINGW%\bin;%MSYS%\bin
rem make clean
make csharplib
cp libs/libpdcsharp.dll csharp/bin/Debug/
