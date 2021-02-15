
PROGRAM _INIT

	
//	
//		gMain.Machine.Motion.AxialMove.CycleAmplitude:=12.7;
//		gMain.Machine.Motion.AxialMove.TotalTime:=0.0825;
//		gMain.Machine.Motion.AxialMove.TotalDistance:=gMain.Machine.Motion.AxialMove.CycleAmplitude*2;
//		gMain.Machine.Motion.AxialMove.PositionOffset:=18.2*25.4;
//	
//	gMain.Machine.Motion.Mc_StopFB[Axial](Axis := ADR(gAxisAxial), Deceleration := 50000);
//	gMain.Machine.Motion.Mc_StopFB[SideLoad](Axis := ADR(gAxisSideLoad), Deceleration := 50000);
//	
//		// Velocity AND Acceleration Calculations FOR Axial MOVE
//		IF gMain.Machine.Motion.AxialMove.TotalTime<>0.0 THEN
//			gMain.Machine.Motion.AxialMove.Vmax:=ABS(gMain.Machine.Motion.AxialMove.TotalDistance/(0.5*(gMain.Machine.Motion.AxialMove.TotalTime)));
//			gMain.Machine.Motion.AxialMove.Amax:=ABS(gMain.Machine.Motion.AxialMove.Vmax/(0.5*gMain.Machine.Motion.AxialMove.TotalTime));
//		END_IF;
//	 
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Acceleration:=gMain.Machine.Motion.AxialMove.Amax;
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Deceleration:=gMain.Machine.Motion.AxialMove.Amax;
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Velocity:=gMain.Machine.Motion.AxialMove.Vmax;
//	
//
//	
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Home.Mode:=mpAXIS_HOME_MODE_ABSOLUTE;
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Home.Position:=1238.54;						//0 position is -610.77
//	
//	gMain.Machine.Motion.MpAxisBasicPar[SideLoad].Home.Mode:=mpAXIS_HOME_MODE_ABSOLUTE;
//	gMain.Machine.Motion.MpAxisBasicPar[SideLoad].Home.Position:=12888.441;

	
	
	
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].MpLink := ADR(gAxisBasicAxial);
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].Enable := TRUE;
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].Parameters := ADR(gMain.Machine.Motion.MpAxisBasicPar[Axial]);
	//gMain.Machine.Motion.MpAxisBasic_FB[Axial].Axis := ADR(gAxisAxial);
	
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].MpLink :=ADR(gAxisBasicSideLoad);
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].Enable := TRUE;
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].Parameters := ADR(gMain.Machine.Motion.MpAxisBasicPar[SideLoad]);
	//gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].Axis := ADR(gAxisSideLoad);
	
	gMain.Machine.Motion.SideLoad.MC_TorqueControl_FB.Axis := ADR(gAxisBasicSideLoad);
	gMain.Machine.Motion.SideLoad.MC_TorqueControl_FB.TorqueRamp := 0.3;
	gMain.Machine.Motion.SideLoad.MC_TorqueControl_FB.Velocity := 10;
	gMain.Machine.Motion.SideLoad.MC_TorqueControl_FB.Acceleration := 10;
	
	gMain.Machine.Alarm.MpAlarmXCore_FB(MpLink :=ADR(gAlarmXCore),Enable := TRUE);
	gMain.Machine.Alarm.MpAlarmXListUI_FB(MpLink := ADR(gAlarmXCore), Enable := TRUE, UISetup := gMain.Machine.Alarm.MpAlarmXListUISetupType, UIConnect := ADR(gMain.Machine.Alarm.MpAlarmXListUIConnectType));
	
//	gMain.Machine.Motion.MpAxisBasicPar[SideLoad].CyclicRead.TorqueMode:=mpAXIS_READ_CYCLIC;
	
	gMain.Output.Vis.LoadCellScaleFactor:= (100.0/-307482);
	gMain.Machine.Motion.SideLoad.ScalingFactor := 0.0034;
	
	gMain.Machine.Motion.MpAxisBasicPar[Axial].Jog.Velocity:=25.4;
	
	
	//Data Logging
	gMain.Services.MpDataRecorder_FB.DeviceName := ADR('Temp');
	gMain.Services.MpDataRecorder_FB.RecordMode := mpDATA_RECORD_MODE_VALUE;
	gMain.Services.MpDataRecorder_FB.MpLink := ADR(gDataRecorder);
	gMain.Services.MpDataRecorder_FB.Enable :=  TRUE;
	
	gMain.Services.MpDataRegPar.MpLink := ADR(gDataRecorder);
	gMain.Services.MpDataRegPar.Enable := TRUE;
	gMain.Services.MpDataRegPar.PVName := ADR('gMain.Input.Vis.StartProgramButton');
	
	
	//Popup Vis
	gMain.Input.Vis.ConfirmPopup := TRUE;
END_PROGRAM

PROGRAM _CYCLIC
	gMain.Machine.Motion.AllAxisReady :=TRUE;
	gMain.Machine.Motion.IsHomedAll := TRUE;
	gMain.Machine.Motion.IsPoweredAll := TRUE;
	gMain.Machine.Motion.Error := FALSE;
	//gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
	
	
	//Check State Loop
	FOR i0:=DINT_TO_USINT(Axial) TO DINT_TO_USINT(SideLoad) DO
		IF NOT gMain.Machine.Motion.MpAxisBasic_FB[i0].Info.ReadyToPowerOn AND NOT gMain.Machine.Motion.MpAxisBasic_FB[i0].Info.ReadyToPowerOn THEN //If not axis initilaized and not ready to power on 
			gMain.Machine.Motion.AllAxisReady := FALSE;  																						   //Then set DrivesReady to FALSE
		END_IF;
		IF gMain.Machine.Motion.MpAxisBasic_FB[i0].IsHomed = FALSE THEN																				//If single axis is not homed
			gMain.Machine.Motion.IsHomedAll := FALSE;																								//Then IsHomedAll is FALSE
		END_IF;
		IF gMain.Machine.Motion.MpAxisBasic_FB[i0].PowerOn = FALSE THEN																				//If drive PowerOn is FALSE for single axis
			gMain.Machine.Motion.IsPoweredAll := FALSE;																								//Then IsPoweredAll is FALSE
		END_IF;
		IF gMain.Machine.Motion.MpAxisBasic_FB[i0].Error THEN
			gMain.Machine.Motion.Error:=TRUE;
		END_IF;
	END_FOR;
	
	
	//Machine State Case Statement
	CASE gMain.Machine.State OF
		Error:
			IF gMain.Machine.Motion.Error THEN
			ELSE
				gMain.Machine.State:=Init;
			END_IF;
			gMain.Input.Vis.PowerOnAll:=FALSE;
			gMain.Output.Vis.StatusLED:=0;
			gMain.Services.MpDataRecorder_FB.Record := FALSE;
		Init:
			IF gMain.Machine.Motion.Error THEN
				gMain.Machine.State:=Error;
			ELSIF gMain.Machine.Motion.AllAxisReady THEN
				gMain.Machine.Motion.HomeAll:=TRUE;
				gMain.Machine.State:=Homing;
			END_IF;
		Homing:
			IF gMain.Machine.Motion.Error THEN
				gMain.Machine.State:=Error;
			ELSIF gMain.Machine.Motion.IsHomedAll THEN
				gMain.Machine.Motion.HomeAll:=FALSE;
				gMain.Machine.State:=WaitingForPowerOn;
			END_IF;
		WaitingForPowerOn:
			IF gMain.Machine.Motion.Error THEN
				gMain.Machine.State:=Error;
			ELSIF NOT gMain.Machine.Motion.IsHomedAll THEN
				gMain.Machine.State:=Init;
			ELSIF gMain.Machine.Motion.IsPoweredAll THEN
				gMain.Machine.State:=Idle;
			END_IF;
			gMain.Output.Vis.StatusLED:=1;
			//			gMain.Input.Vis.PowerButtonVisibility:=FALSE;
			//			gMain.Input.Vis.StopProgramButton:=FALSE;
			//			gMain.Input.Vis.StartProgramButton:=FALSE;
			//			gMain.Input.Vis.PauseProgramButton :=FALSE;
			//			gMain.Machine.Motion.ProgramRunningFlag:=FALSE;
			//			gMain.Machine.Motion.McMoveAbsoluteFB.Execute:=FALSE;
			//			gMain.Output.Vis.CycleCount:=Error;
		Idle:	
			IF gMain.Machine.Motion.Error THEN
				gMain.Machine.State:=Error;
			ELSIF gMain.Machine.Motion.IsPoweredAll=FALSE THEN
				gMain.Machine.State:=WaitingForPowerOn;
			ELSIF gMain.Input.Vis.StartProgramButton THEN
				gMain.Machine.State:=Running;
			END_IF;
			gMain.Output.Vis.StatusLED:=2;
			gMain.Services.MpDataRecorder_FB.Record := TRUE;
			//Jog Logic
			IF gMain.Input.Vis.AxisSelector = 0 THEN
				gMain.Machine.Motion.MpAxisBasic_FB[0].JogPositive:=gMain.Input.Vis.JogNeg;
				gMain.Machine.Motion.MpAxisBasic_FB[0].JogNegative:=gMain.Input.Vis.JogPos;
			ELSE
				gMain.Machine.Motion.MpAxisBasic_FB[1].JogPositive:=gMain.Input.Vis.JogPos;
				gMain.Machine.Motion.MpAxisBasic_FB[1].JogNegative:=gMain.Input.Vis.JogNeg;
			END_IF;
			
			
			
			
			//Manual Move Logic

			gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=gMain.Input.Vis.ManualMoveButton;
			gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=-gMain.Input.Vis.ManualCommandedAxialPosition;
			
			gMain.Machine.Motion.SideLoad.TorqueScaled := gMain.Input.Vis.ManualCommandedSideLoad*gMain.Machine.Motion.SideLoad.ScalingFactor;
			gMain.Machine.Motion.SideLoad.EnableCyclicTorque := gMain.Input.Vis.ManualMoveButton;
			
		Running:
			IF gMain.Machine.Motion.Error THEN
				gMain.Machine.State:=Error;
			ELSIF gMain.Machine.Motion.IsPoweredAll=FALSE THEN
				gMain.Machine.State:=WaitingForPowerOn;
			ELSIF NOT gMain.Input.Vis.StartProgramButton THEN
				gMain.Machine.State:=Idle;
			END_IF;

	END_CASE;
	
	//Alarms
	gMain.Machine.Alarm.MpAlarmXCore_FB(ErrorReset := gMain.Machine.Motion.ErrorResetAll);
	gMain.Machine.Alarm.MpAlarmXListUI_FB(ErrorReset := gMain.Machine.Motion.ErrorResetAll);
	gMain.Machine.Alarm.AlarmPopupControl:=BOOL_TO_USINT(NOT UDINT_TO_BOOL(gMain.Machine.Alarm.MpAlarmXCore_FB.PendingAlarms));

	
	//Button Visibility
	gMain.Input.Vis.PowerOnButtonVisibility:=NOT (gMain.Machine.Motion.AllAxisReady);
	gMain.Input.Vis.StartButtonVisability:= NOT (gMain.Machine.Motion.IsPoweredAll AND NOT gMain.Input.Vis.StartProgramButton);
	gMain.Input.Vis.StopButtonVisibility:= NOT gMain.Input.Vis.StartProgramButton;
	gMain.Input.Vis.ManualGoButtonVis := gMain.Input.Vis.ManualMoveButton;
	gMain.Input.Vis.ManualStopButtonVis := NOT  gMain.Input.Vis.ManualMoveButton;
	

	//Axial Movement
	IF gMain.Machine.Motion.SideLoad.MC_TorqueControl_FB.InTorque THEN
		gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].MoveAbsolute := FALSE;
	
		IF NOT gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles AND gMain.Machine.Motion.AxialMove.FirstMovementFlag THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=1;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=gMain.Input.Vis.OscillationDistance*2;
			END_IF;
		ELSIF gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles (*AND gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB.Info.TorqueControl.InTorque*) THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=0;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
				gMain.Machine.Motion.AxialMove.CycleCount:=gMain.Machine.Motion.AxialMove.CycleCount+1;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=-gMain.Input.Vis.OscillationDistance*2;
			END_IF;
		ELSIF NOT gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles AND NOT gMain.Machine.Motion.AxialMove.FirstMovementFlag THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=1;
				gMain.Machine.Motion.AxialMove.FirstMovementFlag:=1;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=gMain.Input.Vis.OscillationDistance;
			END_IF;
		
		ELSIF gMain.Machine.Motion.AxialMove.CycleCount=gMain.Input.Vis.NumberofCycles AND gMain.Input.Vis.StartProgramButton THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			
				gMain.Input.Vis.StartProgramButton:=0;
				gMain.Machine.Motion.AxialMove.CycleCount:=0;
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=0;
				gMain.Machine.Motion.AxialMove.FirstMovementFlag:=0;
				gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].MoveAbsolute := TRUE;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=gMain.Input.Vis.OscillationDistance;
			END_IF;
		END_IF;
	END_IF;
	
	

	
	
	
	
	
	
	
	
	
	//Torque Control Side Load
	gMain.Input.Vis.NominalPosition :=LREAL_TO_REAL(gMain.Machine.Motion.MpAxisBasic_FB[Axial].Position)+gMain.Input.Vis.AutoCommandedAxialPosition;
	gMain.Output.Vis.DisplayedForceFeedback:= (gMain.Input.Physical.StrainGauge-16275)*gMain.Output.Vis.LoadCellScaleFactor;
	//gMain.Machine.Motion.SideLoad.TorqueScaled:=gMain.Output.Vis.DisplayedForceFeedback*gMain.Machine.Motion.SideLoad.ScalingFactor;
	
	IF gMain.Input.Vis.StartProgramButton AND NOT gMain.Machine.Motion.AtNominalFlag THEN
		//Force Calculation
		gMain.Output.Vis.CalculatedForce:=-1957.5693+(240.0518*(gMain.Input.Vis.NominalPosition/25.4))-(6.3530*((gMain.Input.Vis.NominalPosition/25.4))**2);
		gMain.Machine.Motion.SideLoad.TorqueScaled:=gMain.Output.Vis.CalculatedForce*gMain.Machine.Motion.SideLoad.ScalingFactor;
		
		gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance := gMain.Input.Vis.AutoCommandedAxialPosition;
		gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute := TRUE;
		IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
			gMain.Machine.Motion.AtNominalFlag := TRUE;
			gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute := FALSE;
		END_IF;
	ELSIF gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AtNominalFlag THEN
		gMain.Input.Vis.ConfirmPopup := TRUE;
		gMain.Machine.Motion.SideLoad.EnableCyclicTorque:=TRUE;
	ELSIF NOT gMain.Input.Vis.StartProgramButton AND NOT gMain.Input.Vis.ManualMoveButton THEN
		gMain.Machine.Motion.SideLoad.EnableCyclicTorque:=FALSE;
		gMain.Machine.Motion.AtNominalFlag := FALSE;
		gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute := FALSE;
	END_IF;
	
	
	//EStop Logic	
	IF gMain.Input.Vis.EStop THEN
		gMain.Input.Vis.EStopPopup:=0;
		FOR i0:=DINT_TO_USINT(Axial) TO DINT_TO_USINT(SideLoad) DO
		
			gMain.Input.Vis.PowerOnAll:=FALSE;
			gMain.Machine.Motion.SideLoad.EnableCyclicTorque:=FALSE;
			gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			gMain.Input.Vis.StartProgramButton:=0;
			gMain.Machine.Motion.AxialMove.CycleCount:=0;
			gMain.Machine.Motion.AxialMove.FirstMovementFlag:=0;
		END_FOR;
		
	ELSE
		gMain.Input.Vis.EStopPopup:=1;
		gMain.Machine.Motion.Mc_StopFB[i0].Execute:=FALSE;
	END_IF;
		
	//Data Logging
	IF gMain.Services.MpDataRecorder_FB.Error THEN
		gMain.Services.MpDataRecorder_FB.ErrorReset := TRUE;
		gMain.Services.MpDataRecorder_FB.Record := FALSE;
	ELSIF gMain.Services.MpDataRecorder_FB.ErrorReset OR (gMain.Machine.State > Homing AND NOT gMain.Services.MpDataRecorder_FB.Record) THEN
		gMain.Services.MpDataRecorder_FB.ErrorReset := FALSE;
		gMain.Services.MpDataRecorder_FB.Record := TRUE;
	END_IF;
	
	gMain.Services.MpDataRegPar();
	gMain.Services.MpDataRecorder_FB();
	
		
		
	
		
	//Axial Move Absolute
	IF gMain.Machine.Motion.SideLoad.TorqueScaled > MAX_TORQUE THEN
		gMain.Machine.Motion.SideLoad.TorqueScaled := MAX_TORQUE;
	END_IF;
	
	gMain.Machine.Motion.SideLoad.MC_TorqueControl_FB(Execute := gMain.Machine.Motion.SideLoad.EnableCyclicTorque, Torque := gMain.Machine.Motion.SideLoad.TorqueScaled);
		
	//Move Addative
	gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial(Velocity := 25.4, Acceleration := 25.4, Deceleration := 25.4);
	gMain.Machine.Motion.SideLoad.MC_MoveAdditive_SideLoad(Velocity := 12.7, Acceleration := 25.4, Deceleration := 25.4);
	
	//Motion Function Call
	FOR i0:=DINT_TO_USINT(Axial) TO DINT_TO_USINT(SideLoad) DO
		gMain.Machine.Motion.MpAxisBasic_FB[i0](ErrorReset := gMain.Machine.Motion.ErrorResetAll, Power := gMain.Input.Vis.PowerOnAll, Home := gMain.Machine.Motion.HomeAll);
		gMain.Machine.Motion.Mc_StopFB[i0]();
	END_FOR;
	
END_PROGRAM
PROGRAM _EXIT
	gMain.Machine.Motion.MpAxisBasic_FB[Axial](Enable := FALSE);
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad](Enable := FALSE);
	 
END_PROGRAM

