"C:\Program Files\ANSYS Inc\v211\aisol\BladeModeler\BladeGen\BladeBatch.exe" "D:\Kalpana101\BG.bgi" -TG "D:\Kalpana101\curves"
"C:\Program Files\ANSYS Inc\v211\TurboGrid\bin\cfxtg.exe" -batch "D:\Kalpana101\batchturbo.tse"
"C:\Program Files\ANSYS Inc\v211\CFX\bin\cfx5pre.exe" -batch "D:\Kalpana101\cfxpre.pre"
"C:\Program Files\ANSYS Inc\v211\CFX\bin\cfx5solve.exe" -def "D:\Kalpana101\BATCH_SOLVERINPUT.def" -ccl "D:\Kalpana101\ccl.ccl"
"C:\Program Files\ANSYS Inc\v211\CFX\bin\cfx5post.exe" -res "D:\Kalpana101\BATCH_SOLVERINPUT_002.res" -batch "D:\Kalpana101\cfdpost1.cse"




