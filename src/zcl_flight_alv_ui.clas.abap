class ZCL_FLIGHT_ALV_UI definition
  public
  final
  create public .

public section.

  methods DISPLAY_ALV
    importing
      !IV_TITLE type STRING
    changing
      !CT_TABLE type ANY TABLE
    raising
      CX_SALV_MSG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FLIGHT_ALV_UI IMPLEMENTATION.


  METHOD display_alv.

    DATA(alv) = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen i_appl_events = abap_true ).

    FIELD-SYMBOLS <table> TYPE any.
    ASSIGN ct_table TO <table>.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = DATA(salv)
      CHANGING
        t_table      = <table>
    ).

    DATA(field_cat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns = salv->get_columns( ) r_aggregations = salv->get_aggregations( ) ).

    DATA(lv_layout) = VALUE lvc_s_layo(
      zebra = abap_true
      cwidth_opt = 'A'
      grid_title = iv_title
    ).

    alv->set_table_for_first_display(
      EXPORTING
        i_bypassing_buffer = abap_true
        i_save             = 'A'
        is_layout          = lv_layout
      CHANGING
        it_fieldcatalog    = field_cat
        it_outtab          = <table>
    ).

    cl_gui_alv_grid=>set_focus( control = alv ).

    WRITE: space.

  ENDMETHOD.
ENDCLASS.
