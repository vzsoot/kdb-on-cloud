\d .log4q
fm:"%c\t[%p]:H=%h:PID[%i]:%d:%t:%f: %m\r\n";
sev:snk:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!();a:{$[1<count x;[h[x 0]::x 1;snk[y],::x 0];[h[x]::{x@y};snk[y],::x;]];};r:{snk::@[snk;y;except;x];};
h:m:()!();m["c"]:{[x;y]string x};m["f"]:{[x;y]string .z.f};m["p"]:{[x;y]string .z.p};m["P"]:{[x;y]string .z.P};m["m"]:{[x;y]y};m["h"]:{[x;y]string .z.h};m["i"]:{[x;y]string .z.i};m["d"]:{[x;y]string .z.d};m["D"]:{[x;y]string .z.D};m["t"]:{[x;y]string .z.t};m["T"]:{[x;y]string .z.T};
l:{ssr/[fm;"%",/:lfm;m[lfm:raze -1_/:2_/:nl where fm like/: nl:"*%",/:(.Q.a,.Q.A),\:"*"].\:(x;y)]};
p:{$[10h~type x:(),x;x;(2~count x) & 10h~type x 0;ssr/[x 0;"%",/:string 1+til count (),x 1;.Q.s1 each (),x 1];.Q.s1 x]};
sevl:$[`log in key .Q.opt .z.x;first `$upper .Q.opt[.z.x]`log;`INFO];
(` sv' ``log4q,/:`$(),/:each[first;string lower key snk]) set' {{@[.log4q.h[x]x;y;{[h;e]'"log4q - ", string[h]," exception:",e}[x]]}[;l[x] p y]@/:snk[x]}@/: key[snk];n:(::);
sev:key[snk]!((s;d;i;w;e;f);(n;d;i;w;e;f);(n;n;i;w;e;f);(n;n;n;w;e;f);(n;n;n;n;e;f);(n;n;n;n;n;f));
a[1;`SILENT`DEBUG`INFO`WARN];a[2;`ERROR`FATAL];
\d .
key[.log4q.snk] set' .log4q.sev .log4q.sevl;

