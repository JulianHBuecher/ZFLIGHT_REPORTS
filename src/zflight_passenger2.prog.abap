*&---------------------------------------------------------------------*
*& Report ZFLIGHT_PASSENGER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zflight_passenger2.

TYPES:
  BEGIN OF ty_flights,
    carrid   TYPE s_carr_id,
    connid   TYPE s_conn_id,
    fldate   TYPE s_date,
    bookid   TYPE s_book_id,
    customid TYPE s_customer,
    name     TYPE s_custname,
  END OF ty_flights,
  ty_tt_flights TYPE STANDARD TABLE OF ty_flights,

  BEGIN OF ty_booking,
    carrid     TYPE s_carr_id,
    connid     TYPE s_conn_id,
    fldate     TYPE s_date,
    bookid     TYPE s_book_id,
    customid   TYPE s_customer,
    order_date TYPE s_bdate,
    luggweight TYPE s_lugweigh,
    forcuram   TYPE s_f_cur_pr,
    forcurkey  TYPE s_curr,
  END OF ty_booking,
  ty_tt_bookings TYPE STANDARD TABLE OF ty_booking.

DATA(carrier_id) = VALUE s_carr_id( ).
DATA(connection_id) = VALUE s_conn_id( ).
DATA(flight_date) = VALUE s_date( ).
DATA(booking_id) = VALUE s_book_id( ).
DATA(customer_id) = VALUE s_customer( ).
DATA(customer_name) = VALUE s_custname( ).

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.

    DATA: mt_flights  TYPE ty_tt_flights,
          mt_bookings TYPE ty_tt_bookings.

    METHODS: constructor
      IMPORTING
        it_table TYPE ty_tt_flights.

    METHODS: init_grid.

  PROTECTED SECTION.

    DATA: o_grid        TYPE REF TO cl_gui_alv_grid,
          mo_grid_child TYPE REF TO cl_gui_alv_grid.

    METHODS: on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id.

    METHODS: on_button_click FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING
        es_col_id
        es_row_no.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD constructor.
    o_grid = NEW #( i_parent = cl_gui_container=>default_screen i_appl_events = abap_true ).
    mt_flights = it_table.
  ENDMETHOD.

  METHOD init_grid.

    FIELD-SYMBOLS <table> TYPE any.
    ASSIGN mt_flights TO <table>.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = DATA(salv)
      CHANGING
        t_table      = <table>
    ).

    DATA(field_cat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns = salv->get_columns( ) r_aggregations = salv->get_aggregations( ) ).
    READ TABLE field_cat ASSIGNING FIELD-SYMBOL(<field_cat>) WITH KEY fieldname = 'CUSTOMID'.
    IF sy-subrc IS INITIAL.
      <field_cat>-hotspot = abap_true.
    ENDIF.

    DATA(ls_layout) = VALUE lvc_s_layo(
      zebra = abap_true
      cwidth_opt = 'A'
      grid_title = |Flights|
    ).

    WRITE: space.

    SET HANDLER on_hotspot_click FOR o_grid.
    SET HANDLER on_button_click FOR o_grid.

    o_grid->set_table_for_first_display(
      EXPORTING
        is_layout = ls_layout
        i_bypassing_buffer = abap_true
        i_save             = 'A'
      CHANGING
        it_outtab = <table>
        it_fieldcatalog = field_cat
    ).

    cl_gui_alv_grid=>set_focus( control = o_grid ).

  ENDMETHOD.

  METHOD on_hotspot_click.

    READ TABLE mt_flights ASSIGNING FIELD-SYMBOL(<ls_table>) INDEX e_row_id-index.
    IF sy-subrc IS INITIAL.
      SELECT FROM sbook
        FIELDS carrid, connid, fldate, bookid, customid, order_date, luggweight, forcuram, forcurkey
        WHERE customid = @<ls_table>-customid
        INTO TABLE @mt_bookings.
    ENDIF.

    IF mo_grid_child IS NOT BOUND.
      mo_grid_child = NEW cl_gui_alv_grid( i_parent = NEW cl_gui_docking_container( side = cl_gui_docking_container=>dock_at_right
                                                           ratio = 50
                                                           no_autodef_progid_dynnr = abap_true ) i_appl_events = abap_true ).
    ELSE.
      DATA(lv_refresh) = abap_true.
    ENDIF.

    FIELD-SYMBOLS: <table> TYPE any.
    ASSIGN mt_bookings TO <table>.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = DATA(salv)
      CHANGING
        t_table      = <table>
    ).

    "cl_demo_output=>display( bookings ).

    DATA(field_cat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns = salv->get_columns( ) r_aggregations = salv->get_aggregations( ) ).

    DATA(lv_layout) = VALUE lvc_s_layo(
      zebra = abap_true
      cwidth_opt = 'A'
      grid_title = |Bookings|
    ).

    IF lv_refresh = abap_false.
      mo_grid_child->set_table_for_first_display( EXPORTING
                                         is_layout = lv_layout
                                         i_bypassing_buffer = abap_true
                                         i_save             = 'A'
                                       CHANGING
                                         it_outtab = <table>
                                         it_fieldcatalog = field_cat ).
    ELSE.
      mo_grid_child->refresh_table_display( ).
    ENDIF.
  ENDMETHOD.

  METHOD on_button_click.

  ENDMETHOD.


ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK s01.
  SELECT-OPTIONS:
    so_carr  FOR carrier_id,
    so_conn  FOR connection_id,
    so_fdate FOR flight_date,
    so_book  FOR booking_id,
    so_cid   FOR customer_id MATCHCODE OBJECT scustom,
    so_cname FOR customer_name.
SELECTION-SCREEN END OF BLOCK s01.

START-OF-SELECTION.

  SELECT FROM sflight AS flight
     INNER JOIN sbook AS booking
       ON booking~carrid = flight~carrid AND
          booking~connid = flight~connid AND
          booking~fldate = flight~fldate
     INNER JOIN scustom AS customer
       ON customer~id = booking~customid
    FIELDS flight~carrid, flight~connid, flight~fldate, booking~bookid, booking~customid, customer~name
    WHERE flight~carrid    IN @so_carr
      AND flight~connid    IN @so_conn
      AND flight~fldate    IN @so_fdate
      AND booking~bookid   IN @so_book
      AND booking~customid IN @so_cid
      AND customer~name    IN @so_cname
    ORDER BY flight~fldate, booking~bookid
    INTO TABLE @DATA(flights).

  DATA(lo_main) = NEW lcl_main( it_table = flights ).
  lo_main->init_grid( ).
