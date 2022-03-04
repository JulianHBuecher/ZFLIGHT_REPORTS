*&---------------------------------------------------------------------*
*& Report ZFLIGHT_AGENCY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zflight_agency.

DATA(carrier_id)    = VALUE s_carr_id( ).
DATA(connection_id) = VALUE s_conn_ID( ).
DATA(flight_date)   = VALUE s_date( ).
DATA(city_from)     = VALUE s_from_cit( ).
DATA(city_to)       = VALUE s_to_city( ).
DATA(airport_from)  = VALUE s_fromairp( ).
DATA(airport_to)    = VALUE s_toairp( ).

SELECTION-SCREEN BEGIN OF BLOCK s01.
  SELECT-OPTIONS:
    so_carr  FOR carrier_id,
    so_conn  FOR connection_id,
    so_fdate FOR flight_date,
    so_cyfr  FOR city_from,
    so_cyto  FOR city_to,
    so_aifr  FOR airport_from,
    so_aito  FOR airport_to.
SELECTION-SCREEN END OF BLOCK s01.

INITIALIZATION.

  so_fdate[] = VALUE #( ( sign = 'I' option = 'BT' low = sy-datum high = sy-datum + 3 )  ).

START-OF-SELECTION.

  SELECT FROM sflight AS flight
    INNER JOIN spfli AS connection
      ON flight~connid = connection~connid
    FIELDS flight~carrid, flight~connid, flight~fldate, connection~cityfrom, connection~cityto,
           connection~airpfrom, connection~airpto, flight~seatsocc, flight~seatsmax
    WHERE flight~carrid       IN @so_carr
      AND flight~connid       IN @so_conn
      AND flight~fldate       IN @so_fdate
      AND connection~cityfrom IN @so_cyfr
      AND connection~cityto   IN @so_cyto
      AND connection~airpfrom IN @so_aifr
      AND connection~airpto   IN @so_aito
      AND flight~fldate       >= @sy-datum
      AND flight~seatsmax     >  flight~seatsocc
    ORDER BY fldate
    INTO TABLE @DATA(flights).

  DATA(alv_ui) = NEW zcl_flight_alv_ui( ).
  alv_ui->display_alv(
    EXPORTING
      iv_title = |Flights|
    CHANGING
      ct_table = flights
   ).
