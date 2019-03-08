# ust-yield-curve
These Racket programs will download the US Treasury yield curve XML documents and insert the holding data into a PostgreSQL database. 
The intended usage is:

```bash
$ racket extract.rkt
$ racket transform-load.rkt
```

The provided schema.sql file shows the expected schema within the target PostgreSQL instance. 
This process assumes you can write to a /var/tmp/ust folder.
