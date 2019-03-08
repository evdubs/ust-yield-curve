CREATE TABLE ust.yield_curve
(
  date date NOT NULL,
  "1_month" numeric,
  "2_month" numeric,
  "3_month" numeric,
  "6_month" numeric,
  "1_year" numeric,
  "2_year" numeric,
  "3_year" numeric,
  "5_year" numeric,
  "7_year" numeric,
  "10_year" numeric,
  "20_year" numeric,
  "30_year" numeric,
  CONSTRAINT yield_curve_pkey PRIMARY KEY (date)
);
