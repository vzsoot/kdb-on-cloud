system"l lib/log4q.q"

\t 2000

workloadFn: {
    INFO "Looking for files ...";

    files: key `$":", inputDir;
    fileName: string first files where not files like "done_*";

    if["" ~ trim fileName; :`x];

    INFO "Converting file: ", fileName;

    {system "mv ", y, "/", x, " ", y, "/done_", x}[fileName; inputDir];

    finData: ("SMFSS***";enlist",") 0:`$inputDir, "/done_", fileName;

    finTransform: select year_value: avg Data_value by `year$Period from finData;

    resultFile: outputDir, "/result-", string[.z.p], ".csv";
    (`$resultFile) 0: csv 0: finTransform;

    INFO "Result generated to: ", resultFile;
 }

{
    params: .Q.opt .z.X;
    inputDir:: first params`inputDir;
    outputDir:: first params`outputDir;

    INFO "App initialized with params inputDir: ", inputDir, " outputDir: ", outputDir;
    INFO "Worker Running!";
    .z.ts: workloadFn;
 }[]

