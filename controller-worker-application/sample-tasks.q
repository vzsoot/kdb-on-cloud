// sample tasks with priorities
addTask[({INFO "add1"; :x+y};1;1); 17]
addTask[({INFO "add2"; :x+y};2;2); 7]
addTask[({INFO "add3"; :x+y};3;3); 9]
addTask[({INFO "add4"; :x+y};4;4); 9]
addTask[({INFO "add5"; :x+y};5;5); 1]

// resource intensive task
{[num]
    addTask[({[fileName]
                 sensorData:("IPPFSS";enlist ",") 0: `$":ms://sensors/", fileName;
                 :first value first select sum valFloat from sensorData;
             };"sensors_", num, ".csv"); 1]
 } each string each til 13

// controller state
result
tasks
