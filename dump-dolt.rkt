#lang racket/base

(require db
         gregor
         racket/cmdline
         racket/string
         racket/system)

(define base-folder (make-parameter "/var/tmp/dolt/rates"))

(define start-date (make-parameter (~t (today) "yyyy-MM-dd")))

(define end-date (make-parameter (~t (today) "yyyy-MM-dd")))

(define db-user (make-parameter "user"))

(define db-name (make-parameter "local"))

(define db-pass (make-parameter ""))

(command-line
 #:program "racket dump-dolt-dividends.rkt"
 #:once-each
 [("-b" "--base-folder") folder
                         "Base dolt folder. Defaults to /var/tmp/dolt/rates"
                         (base-folder folder)]
 [("-e" "--end-date") end
                      "Final date for history retrieval. Defaults to today"
                      (end-date end)]
 [("-n" "--db-name") name
                     "Database name. Defaults to 'local'"
                     (db-name name)]
 [("-p" "--db-pass") password
                     "Database password"
                     (db-pass password)]
 [("-s" "--start-date") start
                        "Earliest date for history retrieval. Defaults to today"
                        (start-date start)]
 [("-u" "--db-user") user
                     "Database user name. Defaults to 'user'"
                     (db-user user)])

(define dbc (postgresql-connect #:user (db-user) #:database (db-name) #:password (db-pass)))

(define us-treasury-file (string-append (base-folder) "/us-treasury-" (end-date) ".csv"))

(call-with-output-file* us-treasury-file
  (λ (out)
    (displayln "date,1_month,2_month,3_month,6_month,1_year,2_year,3_year,5_year,7_year,10_year,20_year,30_year" out)
    (for-each (λ (row)
                (displayln (string-join (vector->list row) ",") out))
              (query-rows dbc "
select
  date::text,
  coalesce(\"1_month\"::text, ''),
  coalesce(\"2_month\"::text, ''),
  coalesce(\"3_month\"::text, ''),
  coalesce(\"6_month\"::text, ''),
  coalesce(\"1_year\"::text, ''),
  coalesce(\"2_year\"::text, ''),
  coalesce(\"3_year\"::text, ''),
  coalesce(\"5_year\"::text, ''),
  coalesce(\"7_year\"::text, ''),
  coalesce(\"10_year\"::text, ''),
  coalesce(\"20_year\"::text, ''),
  coalesce(\"30_year\"::text, '')
from
  ust.yield_curve
where
  date >= $1::text::date and
  date <= $2::text::date;
"
                          (start-date)
                          (end-date))))
  #:exists 'replace)

(system (string-append "cd " (base-folder) "; /usr/local/bin/dolt table import -u --continue us_treasury us-treasury-" (end-date) ".csv"))

(system (string-append "cd " (base-folder) "; /usr/local/bin/dolt add us_treasury; "
                       "/usr/local/bin/dolt commit -m 'us_treasury " (end-date) " update'; /usr/local/bin/dolt push"))
