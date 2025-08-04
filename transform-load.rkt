#lang racket/base

(require db
         gregor
         racket/cmdline
         racket/list
         racket/port
         racket/string
         xml
         xml/path)

(define base-folder (make-parameter "/var/local/ust/yield-curve"))

(define file-date (make-parameter (today)))

(define db-user (make-parameter "user"))

(define db-name (make-parameter "local"))

(define db-pass (make-parameter ""))

(command-line
 #:program "racket transform-load.rkt"
 #:once-each
 [("-b" "--base-folder") folder
                         "US Treasury yield curve base folder. Defaults to /var/local/ust/yield-curve"
                         (base-folder folder)]
 [("-d" "--file-date") date
                       "US Treasury yield curve file date. Defaults to today"
                       (file-date (iso8601->date date))]
 [("-n" "--db-name") name
                     "Database name. Defaults to 'local'"
                     (db-name name)]
 [("-p" "--db-pass") password
                     "Database password"
                     (db-pass password)]
 [("-u" "--db-user") user
                     "Database user name. Defaults to 'user'"
                     (db-user user)])

(define dbc (postgresql-connect #:user (db-user) #:database (db-name) #:password (db-pass)))

(let ([file-name (string-append (base-folder) "/" (~t (file-date) "yyyy-MM-dd") ".xml")])
  (call-with-input-file file-name
    (λ (in) (let ([xexp (string->xexpr (port->string in))])
              (for-each (λ (entry)
                          (with-handlers ([exn:fail? (λ (e) (displayln (string-append "Failed to process yield curve for date "
                                                                                      (~t (file-date) "yyyy-MM-dd")))
                                                       (displayln e)
                                                       (rollback-transaction dbc))])
                            
                            (let ([date (se-path*/list '(content m:properties d:NEW_DATE) entry)]
                                  [1-month (se-path*/list '(content m:properties d:BC_1MONTH) entry)]
                                  [2-month (se-path*/list '(content m:properties d:BC_2MONTH) entry)]
                                  [3-month (se-path*/list '(content m:properties d:BC_3MONTH) entry)]
                                  [6-month (se-path*/list '(content m:properties d:BC_6MONTH) entry)]
                                  [1-year (se-path*/list '(content m:properties d:BC_1YEAR) entry)]
                                  [2-year (se-path*/list '(content m:properties d:BC_2YEAR) entry)]
                                  [3-year (se-path*/list '(content m:properties d:BC_3YEAR) entry)]
                                  [5-year (se-path*/list '(content m:properties d:BC_5YEAR) entry)]
                                  [7-year (se-path*/list '(content m:properties d:BC_7YEAR) entry)]
                                  [10-year (se-path*/list '(content m:properties d:BC_10YEAR) entry)]
                                  [20-year (se-path*/list '(content m:properties d:BC_20YEAR) entry)]
                                  [30-year (se-path*/list '(content m:properties d:BC_30YEAR) entry)])
                              (cond [(not (empty? 10-year))
                                     (start-transaction dbc)
                                     (query-exec dbc "
insert into ust.yield_curve (
  date,
  \"1_month\",
  \"2_month\",
  \"3_month\",
  \"6_month\",
  \"1_year\",
  \"2_year\",
  \"3_year\",
  \"5_year\",
  \"7_year\",
  \"10_year\",
  \"20_year\",
  \"30_year\"
) values (
  $1::text::date,
  case $2
    when '' then null
    else round($2::text::decimal, 4)
  end,
  case $3
    when '' then null
    else round($3::text::decimal, 4)
  end,
  case $4
    when '' then null
    else round($4::text::decimal, 4)
  end,
  case $5
    when '' then null
    else round($5::text::decimal, 4)
  end,
  case $6
    when '' then null
    else round($6::text::decimal, 4)
  end,
  case $7
    when '' then null
    else round($7::text::decimal, 4)
  end,
  case $8
    when '' then null
    else round($8::text::decimal, 4)
  end,
  case $9
    when '' then null
    else round($9::text::decimal, 4)
  end,
  case $10
    when '' then null
    else round($10::text::decimal, 4)
  end,
  round($11::text::decimal, 4),
  case $12
    when '' then null
    else round($12::text::decimal, 4)
  end,
  case $13
    when '' then null
    else round($13::text::decimal, 4)
  end
) on conflict (date) do nothing;
"
                                                 (first date)
                                                 (if (empty? 1-month) "" (first 1-month))
                                                 (if (empty? 2-month) "" (first 2-month))
                                                 (if (empty? 3-month) "" (first 3-month))
                                                 (if (empty? 6-month) "" (first 6-month))
                                                 (if (empty? 1-year) "" (first 1-year))
                                                 (if (empty? 2-year) "" (first 2-year))
                                                 (if (empty? 3-year) "" (first 3-year))
                                                 (if (empty? 5-year) "" (first 5-year))
                                                 (if (empty? 7-year) "" (first 7-year))
                                                 (first 10-year)
                                                 (if (empty? 20-year) "" (first 20-year))
                                                 (if (empty? 30-year) "" (first 30-year)))
                                     (commit-transaction dbc)]))))
                        (se-path*/list '(feed entry) xexp))))))
