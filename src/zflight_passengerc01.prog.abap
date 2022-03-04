*&---------------------------------------------------------------------*
*& Include          ZFLIGHT_PASSENGERC01
*&---------------------------------------------------------------------*



*CLASS c2 DEFINITION INHERITING FROM c1.
*  PUBLIC SECTION.
*    EVENTS e2.
*ENDCLASS.

*CLASS c3 DEFINITION.
*  PUBLIC SECTION.
*    CLASS-METHODS  h1 FOR EVENT e1 OF c1.
*          METHODS: h2 FOR EVENT e2 OF c2,
*                   h3 FOR EVENT ce1 OF c1.
*ENDCLASS.


*DATA: trigger TYPE REF TO c2,
*      handler TYPE REF TO c3.
*
*SET HANDLER: c3=>h1 handler->h2 FOR trigger,
*             handler->h3.
