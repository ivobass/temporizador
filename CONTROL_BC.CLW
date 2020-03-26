  MEMBER('Control.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('Control_BC0.CLW')
Control_BC0:DctInit             PROCEDURE
Control_BC0:DctKill             PROCEDURE
Control_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  Control_BC0:DctInit
  Control_BC0:FilesInit


DctKill PROCEDURE
  CODE
  Control_BC0:DctKill

