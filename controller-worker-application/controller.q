system"l lib/log4q.q"

tasks: ([] id: `guid$(); priority: `int$(); task: ())
result: ([] id: `guid$(); result: (::))

nextTask: {
    :$[0=count tasks; ::; {
        task: first `priority xdesc tasks;
        delId: task `id;
        delete from `tasks where id = delId;
        :task
    }[]]
 }

addTask: {[fn; priority]
    upsert[`tasks; (first 1?0Ng; priority; fn)]
 }

addResult: {[id; result]
    upsert[`result; (id; result)]
 }

workerJoin: {[id]
    INFO "Worker ", id, " joined";
 }

{
    INFO "Controller initialized";
 }[]

