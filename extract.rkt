#lang racket/base

(require net/url
         racket/cmdline
         racket/port
         srfi/19 ; Time data types and procedures
         threading)

(define all (make-parameter #f))

(define date (make-parameter (current-date)))

(command-line
 #:program "racket extract.rkt"
 #:once-each
 [("-a" "--all") "Download all available yield curve data"
                (all #t)]
 [("-d" "--date") d
                  "Download yield curve for specific date (overridden if downloading all)"
                  (date (string->date d "~Y-~m-~d"))])

(call-with-output-file (string-append "/var/tmp/ust/yield-curve/" (date->string (date) "~1") ".xml")
  (λ (out) (~> (if (all)
                   "https://data.treasury.gov/feed.svc/DailyTreasuryYieldCurveRateData"
                   (string-append "https://data.treasury.gov/feed.svc/DailyTreasuryYieldCurveRateData"
                                  "?$filter=day(NEW_DATE) eq " (number->string (date-day (date))) " and "
                                  "month(NEW_DATE) eq " (number->string (date-month (date))) " and "
                                  "year(NEW_DATE) eq " (number->string (date-year (date)))))
               (string->url _)
               (get-pure-port _)
               (copy-port _ out)))
  #:exists 'replace)
