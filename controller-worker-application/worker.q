system "l lib/log4q.q"

\t 1000

workloadFn:{
    task:controller (`nextTask;());
    $[99h=type task; {[id;task]
        INFO "Invoke task with id: ",string id;
        result: eval task;
        controller (`addResult; id; result);
    }[task`id; task`task];];
 }

{
    params:.Q.opt .z.X;
    workerId::first params`workerId;
    controllerAddr::first params`controllerAddr;

    INFO "Worker initialized with params controllerAddr: ",controllerAddr;
    INFO "Worker Running!";

    controller:: `$":",controllerAddr;

    controller (`workerJoin;workerId);

    INFO "Waiting for tasks";
    .z.ts:workloadFn;
 }[]

