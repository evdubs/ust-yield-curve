#lang racket/base

(require gregor
         net/http-easy
         racket/cmdline
         racket/format
         racket/port
         threading)

(define all (make-parameter #f))

(define curve-date (make-parameter (today)))

(command-line
 #:program "racket extract.rkt"
 #:once-each
 [("-a" "--all") "Download all available yield curve data"
                 (all #t)]
 [("-d" "--date") d
                  "Download yield curve for specific date (overridden if downloading all)"
                  (curve-date (iso8601->date d))])

(call-with-output-file* (string-append "/var/tmp/ust/yield-curve/" (~t (curve-date) "yyyy-MM-dd") ".xml")
  (λ (out) (~> (if (all)
                   (string-append "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml"
                                  "?data=daily_treasury_yield_curve&field_tdr_date_value=all")
                   (string-append "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml"
                                  "?data=daily_treasury_yield_curve&field_tdr_date_value_month="
                                  (number->string (->year (curve-date)))
                                  (~a (number->string (->month (curve-date))) #:width 2 #:pad-string "0" #:align 'right)))
               (get _)
               (response-body _)
               (write-bytes _ out)))
  #:exists 'replace)
