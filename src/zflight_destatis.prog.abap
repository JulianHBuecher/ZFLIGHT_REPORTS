*&---------------------------------------------------------------------*
*& Report zflight_destatis
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zflight_destatis.

TYPES:
  BEGIN OF statsline,
    country     TYPE land1,
    countryname TYPE landx50,
    city        TYPE s_city,
    airport     TYPE s_airport,
    arrivals    TYPE zfapparrival,
    departures  TYPE zfappdeparture,
  END OF statsline,
  countrylist TYPE STANDARD TABLE OF statsline WITH DEFAULT KEY.

DATA(result) = VALUE countrylist(  ).

DATA(ctry) = VALUE land1( ).
SELECT-OPTIONS co_ctry FOR ctry MATCHCODE OBJECT /mva/amd_country_es.
DATA(cty) = VALUE s_city( ).
SELECT-OPTIONS co_cty FOR cty MATCHCODE OBJECT zsh_fapp_airport.
DATA(airp) = VALUE s_airport(  ).
SELECT-OPTIONS co_airp FOR airp MATCHCODE OBJECT zsh_fapp_airport2.
DATA(flight_date) = VALUE s_date( ).
SELECT-OPTIONS so_fldat FOR flight_date.

SELECT fp~countryto AS country, text~landx50 AS countrytext, fp~cityto AS city, fp~airpto AS airport, COUNT( * ) AS arrivals
FROM sflight AS f
INNER JOIN spfli AS fp ON f~carrid = fp~carrid AND f~connid = fp~connid
LEFT OUTER JOIN t005t AS text ON text~land1 = fp~countryto AND text~spras = @sy-langu
WHERE fp~countryto IN @co_ctry AND fp~cityto IN @co_cty AND fp~airpto IN @co_airp AND f~fldate IN @so_fldat
GROUP BY fp~countryto, text~landx50, fp~cityto, fp~airpto
ORDER BY fp~countryto, fp~cityto, fp~airpto
INTO TABLE @DATA(arrivals).

SELECT fp~countryfr AS country, text~landx50 AS countrytext, fp~cityfrom AS city, fp~airpfrom AS airport, COUNT( * ) AS departures
FROM sflight AS f
INNER JOIN spfli AS fp ON f~carrid = fp~carrid AND f~connid = fp~connid
 LEFT OUTER JOIN t005t AS text ON text~land1 = fp~countryfr AND text~spras = @sy-langu
WHERE fp~countryfr IN @co_ctry AND fp~cityfrom IN @co_cty AND fp~airpfrom IN @co_airp AND f~fldate IN @so_fldat
GROUP BY fp~countryfr, text~landx50, fp~cityfrom, fp~airpfrom
INTO TABLE @DATA(departures).


SORT departures BY country city airport.
LOOP AT arrivals REFERENCE INTO DATA(arrival).
  READ TABLE departures REFERENCE INTO DATA(departure) WITH KEY country = arrival->country city = arrival->city airport = arrival->airport BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    APPEND VALUE #( country = arrival->country countryname = arrival->countrytext city = arrival->city airport = arrival->airport arrivals = arrival->arrivals departures = departure->departures ) TO result.
  ENDIF.
ENDLOOP.

DATA(alvgrid) = NEW zcl_flight_alv_ui(  ).
alvgrid->display_alv( EXPORTING iv_title = 'Flights' CHANGING ct_table = result ).
