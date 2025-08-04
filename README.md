# ust-yield-curve
These Racket programs will download the US Treasury yield curve XML documents and insert the holding data into a PostgreSQL database. 
The intended usage is:

```bash
$ racket extract.rkt
$ racket transform-load.rkt
```

You will need to provide a database password for `transform-load.rkt`. The available parameters are:

```bash
$ racket extract.rkt -h
racket extract.rkt [ <option> ... ]
 where <option> is one of
  -a, --all : Download all available yield curve data
  -d <d>, --date <d> : Download yield curve for specific date (overridden if downloading all)
  --help, -h : Show this help
  -- : Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after one `-`. For
  example: `-h-` is the same as `-h --`

$ racket transform-load.rkt -h
racket transform-load.rkt [ <option> ... ]
 where <option> is one of
  -b <folder>, --base-folder <folder> : US Treasury yield curve base folder. Defaults to /var/local/ust/yield-curve
  -d <date>, --file-date <date> : US Treasury yield curve file date. Defaults to today
  -n <name>, --db-name <name> : Database name. Defaults to 'local'
  -p <password>, --db-pass <password> : Database password
  -u <user>, --db-user <user> : Database user name. Defaults to 'user'
  --help, -h : Show this help
  -- : Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after one `-`. For
  example: `-h-` is the same as `-h --`
```

The provided `schema.sql` file shows the expected schema within the target PostgreSQL instance. 
This process assumes you can write to a `/var/local/ust` folder.

### Dependencies

It is recommended that you start with the standard Racket distribution. With that, you will need to install the following packages:

```bash
$ raco pkg install --skip-installed gregor http-easy threading
```
