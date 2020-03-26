

   MEMBER('Control.clw')                                   ! This is a MEMBER module


   INCLUDE('ABRESIZE.INC'),ONCE
   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('CONTROL001.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! Window
!!! </summary>
Main PROCEDURE 

LOC:DisplayTimer     STRING(5)                             !
LOC:MOSTRAR          LONG                                  !
LOC:CONTADOR         LONG                                  !
LOC:INICIO           REAL                                  !
LOC:BANNER           STRING(200)                           !
LOC:BANNER2          STRING(100)                           !
LOC:HORAINICIAL      LONG                                  !
LOC:HORAFINAL        LONG                                  !Hora Final
LOC:CALCULAR         BYTE                                  !
QuickWindow          WINDOW('Temporizador'),AT(,,417,271),FONT('Microsoft Sans Serif',8,,FONT:regular),CENTER,COLOR(COLOR:White), |
  GRAY,IMM,MAX,HLP('Main'),SYSTEM,TIMER(1000)
                       PROMPT('Hora Inicial:'),AT(15,257),USE(?LOC:HORAINICIAL:Prompt),TRN
                       ENTRY(@N_3),AT(57,255,31,14),USE(LOC:HORAINICIAL),FONT('Microsoft Sans Serif',,,FONT:regular), |
  RIGHT(1)
                       PANEL,AT(3,9,413,226),USE(?Panel1),BEVEL(-2,-2),FILL(COLOR:Black)
                       STRING(@s5),AT(8,29,397,152),USE(LOC:DisplayTimer),FONT('Microsoft Sans Serif',160,COLOR:Yellow, |
  FONT:regular,CHARSET:ANSI),CENTER(1),TRN
                       BUTTON('Start'),AT(307,255,49,14),USE(?comienzo)
                       BUTTON('OK'),AT(361,254,55,16),USE(?Ok),LEFT,ICON('WAOK.ICO'),MSG('Bewerking Accepteren'), |
  TIP('Bewerking Accepteren')
                       PROMPT('Hora Final:'),AT(205,257),USE(?LOC:HORAFINAL:Prompt),HIDE,TRN
                       ENTRY(@T7),AT(244,254,33,14),USE(LOC:HORAFINAL),RIGHT(1),HIDE,MSG('Hora Final'),TIP('Hora Final')
                       PROGRESS,AT(8,185,397,44),USE(?PROGRESS1),RANGE(0,100)
                       STRING(@s100),AT(8,171,397),USE(LOC:BANNER),LEFT
                       SLIDER,AT(93,253),USE(?SLIDER1),RANGE(1,99),STEP(1)
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
TakeFieldEvent         PROCEDURE(),BYTE,PROC,DERIVED
TakeWindowEvent        PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
Resizer              CLASS(WindowResizeClass)
Init                   PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)
                     END


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?LOC:HORAINICIAL:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.AddItem(Toolbar)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Ok,RequestCancelled)                    ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Ok,RequestCompleted)                    ! Add the close control to the window manger
  END
  SELF.Open(QuickWindow)                                   ! Open window
  Do DefineListboxStyle
  Resizer.Init(AppStrategy:Centered,Resize:SetMinSize)     ! Don't change the windows controls when window resized
  SELF.AddItem(Resizer)                                    ! Add resizer to window manager
  INIMgr.Fetch('Main',QuickWindow)                         ! Restore window settings from non-volatile store
  Resizer.Resize                                           ! Reset required after window size altered by INI manager
  SELF.SetAlerts()
  ! ------------- INICIO DA APP -----------------
  !  LOC:HORAINICIAL = CLOCK()
   LOC:HORAFINAL = 0   
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('Main',QuickWindow)                      ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?LOC:HORAINICIAL
        LOC:INICIO = LOC:HORAINICIAL * TIME:Minute
        display()
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?comienzo
      ThisWindow.Update()
      	!	LOC:INICIO = LOC:HORAINICIAL * TIME:Minute
      
      		?Progress1{PROP:hide}  = 0
      		?Progress1{PROP:RangeHigh} = LOC:INICIO
      		?Progress1{PROP:Progress} = LOC:INICIO
      ! ---------------- CALCULAR --------------
      		!UPDATE(?LOC:HORAFINAL)
      		LOC:CALCULAR = FALSE
      !		IF LOC:HORAINICIAL < LOC:HORAFINAL
      !			MESSAGE('Hora Inicial no Pode ser menor que a Final','Alerta')
      !		ELSE
      			LOC:MOSTRAR = LOC:HORAINICIAL * TIME:Minute
      			LOC:DisplayTimer = SUB(FORMAT(LOC:MOSTRAR,@t4),4,5)
      			QuickWindow{PROP:TIMER} = 100    ! ----- Timer a 1 Seg.
      			LOC:CALCULAR = TRUE
      !		END
      		SELECT(?LOC:HORAINICIAL)
      
      
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeFieldEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all field specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  CASE FIELD()
  OF ?SLIDER1
    LOC:HORAINICIAL = ?SLIDER1{prop:sliderpos}
    display()
  END
  ReturnValue = PARENT.TakeFieldEvent()
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


ThisWindow.TakeWindowEvent PROCEDURE

ReturnValue          BYTE,AUTO

Looped BYTE
  CODE
  LOOP                                                     ! This method receives all window specific events
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeWindowEvent()
    CASE EVENT()
    OF EVENT:Timer
      ! -------------------- TIMER ------------------------
      		LOC:BANNER2='. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . Delta Som  ................................................................................'
      		LOC:CONTADOR +=1 ; if LOC:CONTADOR>200 then LOC:CONTADOR=1. 
      		LOC:BANNER=sub(LOC:BANNER,LOC:CONTADOR,100)
      		display()
      		IF LOC:CALCULAR
      			LOC:MOSTRAR -= 100
      			LOC:DisplayTimer = SUB(FORMAT(LOC:MOSTRAR,@t4),4,5)
      			DISPLAY(?LOC:DisplayTimer)
      			LOC:CONTADOR +=1 ; if LOC:CONTADOR>200 then LOC:CONTADOR=1. 
      		LOC:BANNER=sub(LOC:BANNER2,LOC:CONTADOR,100)
      		?Progress1{PROP:Progress} = ?Progress1{PROP:Progress} - 100
      		display()
      		IF LOC:MOSTRAR <= LOC:HORAFINAL
      			LOC:MOSTRAR = LOC:HORAFINAL
      			LOC:DisplayTimer = SUB(FORMAT(LOC:MOSTRAR,@t4),4,5)
      			DISPLAY(?LOC:DisplayTimer)
      			QuickWindow{PROP:TIMER} = 1000      ! ----- Aumentar TIMER a 10 Seg.
      			LOC:CALCULAR = FALSE
      			MESSAGE('TERMINO O TEMPO')
      		END
      	END
      
       
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue


Resizer.Init PROCEDURE(BYTE AppStrategy=AppStrategy:Resize,BYTE SetWindowMinSize=False,BYTE SetWindowMaxSize=False)


  CODE
  PARENT.Init(AppStrategy,SetWindowMinSize,SetWindowMaxSize)
  SELF.SetParentDefaults()                                 ! Calculate default control parent-child relationships based upon their positions on the window
  SELF.SetAnchor(?LOC:HORAINICIAL:Prompt,Anchor:Left+Anchor:Bottom)
  SELF.SetAnchor(?LOC:HORAINICIAL,Anchor:Left+Anchor:Bottom)
  SELF.SetAnchor(?Panel1,Anchor:Right+Anchor:Left+Anchor:Top+Anchor:Bottom)
  SELF.SetAnchor(?LOC:DisplayTimer,Anchor:Right+Anchor:Left+Anchor:GrowTop+Anchor:Bottom)
  SELF.SetAnchor(?comienzo,Anchor:Right+Anchor:Bottom)
  SELF.SetAnchor(?Ok,Anchor:Right+Anchor:Bottom)
  SELF.SetAnchor(?LOC:HORAFINAL:Prompt,Anchor:Left+Anchor:Bottom)
  SELF.SetAnchor(?LOC:HORAFINAL,Anchor:Left+Anchor:Bottom)
  SELF.SetAnchor(?PROGRESS1,Anchor:Right+Anchor:Left+Anchor:Bottom)
  SELF.SetAnchor(?LOC:BANNER,Anchor:Right+Anchor:Left+Anchor:Bottom)
  SELF.SetAnchor(?SLIDER1,Anchor:Left+Anchor:Bottom)

