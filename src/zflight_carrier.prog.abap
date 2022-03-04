*&---------------------------------------------------------------------*
*& Report zflight_carrier
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zflight_carrier.

PARAMETERS co_carr TYPE s_carr_id OBLIGATORY.
DATA(conn) = VALUE s_conn_id( ).
SELECT-OPTIONS co_conn FOR conn.
DATA(fdate) = VALUE s_date( ).
SELECT-OPTIONS co_fdate FOR fdate.

SELECT f~fldate as Flight_Date,
       fp~airpfrom as Airport_From,
       fp~airpto as Airport_To,
       fp~deptime as Depature_Time,
       fp~arrtime as Arrival_Time,
       fp~fltime as Flight_Time,
       fp~fltype as Fligh_Type,
       f~planetype as Plane_Type,
       f~seatsmax as Seats_Available,
       f~seatsocc as Seats_Occupied
FROM sflight AS f
INNER JOIN scarr AS c ON f~carrid = c~carrid
INNER JOIN spfli AS fp ON f~carrid = fp~carrid AND f~connid = fp~connid
WHERE f~carrid = @co_carr AND f~connid IN @co_conn AND f~fldate IN @co_fdate
INTO TABLE @DATA(result).

DATA(alvgrid) = new zcl_flight_alv_ui(  ).
alvgrid->display_alv( EXPORTING iv_title = 'Flights' CHANGING ct_table = result ).
