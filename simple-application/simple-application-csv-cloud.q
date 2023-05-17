system"l lib/log4q.q"

\t 2000

workloadFn: {
    INFO "Worker processing CSV";

    finData: ("SMFSS***";enlist",") 0:`$":ms://sample-data/incoming/business-price-indexes-september-2022-quarter-csv.csv";

    finTransform: select year_value: avg Data_value by `year$Period from finData;

    headers: enlist ["x-ms-version"]!enlist "2017-11-09";
    opts: ``headers!(::;headers);
    opts[`headers]: ("x-ms-version";"x-ms-blob-type";"Content-Type")!("2017-11-09";"BlockBlob";"text/csv");
    opts[`body]: "\n" sv .h.cd finTransform;
    resp:.kurl.sync ("https://", (getenv[`$"AZURE_STORAGE_ACCOUNT"]), ".blob.core.windows.net/sample-data/outgoing/result_", ssr[string[.z.p]; "[.:]"; ""], ".csv"; `PUT; opts);

    INFO string[resp]
 }

{
    INFO "App initialized";
    .z.ts: workloadFn;
 }[]
