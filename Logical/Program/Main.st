
PROGRAM _INIT

	
	
	//	gMain.Machine.Motion.AxialMove.CycleAmplitude:=12.7;
	//	gMain.Machine.Motion.AxialMove.TotalTime:=0.0825;
	//	gMain.Machine.Motion.AxialMove.TotalDistance:=gMain.Machine.Motion.AxialMove.CycleAmplitude*2;
	//	gMain.Machine.Motion.AxialMove.PositionOffset:=18.2*25.4;
	
	//gMain.Machine.Motion.Mc_StopFB[Axial](Axis := ADR(gAxisAxial), Deceleration := 50000);
	//gMain.Machine.Motion.Mc_StopFB[SideLoad](Axis := ADR(gAxisSideLoad), Deceleration := 50000);
	
	//	//Velocity and Acceleration Calculations for Axial Move
	//	IF gMain.Machine.Motion.AxialMove.TotalTime<>0.0 THEN
	//		gMain.Machine.Motion.AxialMove.Vmax:=ABS(gMain.Machine.Motion.AxialMove.TotalDistance/(0.5*(gMain.Machine.Motion.AxialMove.TotalTime)));
	//		gMain.Machine.Motion.AxialMove.Amax:=ABS(gMain.Machine.Motion.AxialMove.Vmax/(0.5*gMain.Machine.Motion.AxialMove.TotalTime));
	//	END_IF;
	 
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Acceleration:=gMain.Machine.Motion.AxialMove.Amax;
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Deceleration:=gMain.Machine.Motion.AxialMove.Amax;
//	gMain.Machine.Motion.MpAxisBasicPar[Axial].Velocity:=gMain.Machine.Motion.AxialMove.Vmax;
	

	
//	gMain.Machine.Motion.AxisPar.Home.Mode:=mpAXIS_HOME_MODE_ABSOLUTE;
//	gMain.Machine.Motion.AxisPar.Home.Position:=544.69;
	
	

	
	
	
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].MpLink := ADR(gAxisBasicAxial);
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].Enable := TRUE;
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].Parameters := ADR(gMain.Machine.Motion.MpAxisBasicPar[Axial]);
	gMain.Machine.Motion.MpAxisBasic_FB[Axial].Axis := ADR(gAxisAxial);
	
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].MpLink :=ADR(gAxisBasicSideLoad);
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].Enable := TRUE;
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].Parameters := ADR(gMain.Machine.Motion.MpAxisBasicPar[SideLoad]);
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad].Axis := ADR(gAxisSideLoad);
	
	gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB(MpLink := ADR(gAxisBasicSideLoad), Enable := TRUE, Parameters :=ADR(gMain.Machine.Motion.SideLoad.MpAxisCyclicSetParType));
	
	gMain.Machine.Alarm.MpAlarmXCore_FB(MpLink :=ADR(gAlarmXCore),Enable := TRUE);
	gMain.Machine.Alarm.MpAlarmXListUI_FB(MpLink := ADR(gAlarmXCore), Enable := TRUE, UISetup := gMain.Machine.Alarm.MpAlarmXListUISetupType, UIConnect := ADR(gMain.Machine.Alarm.MpAlarmXListUIConnectType));
	
	gMain.Machine.Motion.MpAxisBasicPar[SideLoad].CyclicRead.TorqueMode:=mpAXIS_READ_CYCLIC;
	
	gMain.Output.Vis.LoadCellScaleFactor:=(0.0000019663)*(500.0/16.5);
	
	gMain.Input.Vis.AutoCommandedAxialPosition:=gMain.Machine.Motion.AxialMove.PositionOffset;
	gMain.Machine.Motion.MpAxisBasicPar[Axial].Jog.Velocity:=25.4;
END_PROGRAM

PROGRAM _CYCLIC
	gMain.Machine.Motion.AllAxisReady :=TRUE;
	gMain.Machine.Motion.IsHomedAll := TRUE;
	gMain.Machine.Motion.IsPoweredAll := TRUE;
	gMain.Machine.Motion.Error := FALSE;
	gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
	
	
	//Check State Loop
	FOR i0:=DINT_TO_USINT(Axial) TO DINT_TO_USINT(SideLoad) DO
		IF NOT gMain.Machine.Motion.MpAxisBasic_FB[i0].Info.AxisInitialized AND NOT gMain.Machine.Motion.MpAxisBasic_FB[i0].Info.ReadyToPowerOn THEN //If not axis initilaized and not ready to power on 
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
			//Jog Logic
			gMain.Machine.Motion.MpAxisBasic_FB[gMain.Input.Vis.AxisSelector].JogPositive:=gMain.Input.Vis.JogPos;
			gMain.Machine.Motion.MpAxisBasic_FB[gMain.Input.Vis.AxisSelector].JogNegative:=gMain.Input.Vis.JogNeg;
			
			
			
			//Manual Move Logic

			gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=gMain.Input.Vis.ManualMoveButton;
			gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=gMain.Input.Vis.ManualCommandedAxialPosition;
			
			gMain.Machine.Motion.SideLoad.MC_MoveAdditive_SideLoad.Execute:=gMain.Input.Vis.ManualMoveButton;
			gMain.Machine.Motion.SideLoad.MC_MoveAdditive_SideLoad.Distance:=gMain.Input.Vis.ManualCommandedSideLoad;	
			
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
	gMain.Machine.Alarm.AlarmPopupControl:=BOOL_TO_USINT(NOT UDINT_TO_BOOL(gMain.Machine.Alarm.MpAlarmXCore_FB.ActiveAlarms));

	
	//Button Visibility
	gMain.Input.Vis.PowerOnButtonVisibility:=NOT (gMain.Machine.Motion.AllAxisReady);
	gMain.Input.Vis.StartButtonVisability:= NOT (gMain.Machine.Motion.IsPoweredAll AND NOT gMain.Input.Vis.StartProgramButton);
	gMain.Input.Vis.StopButtonVisibility:= NOT gMain.Input.Vis.StartProgramButton;
	
	
	//Force Calculation
	gMain.Output.Vis.CalculatedForce:=-1957.5693+(240.0518*(gMain.Input.Vis.AutoCommandedAxialPosition/25.4))-(6.3530*((gMain.Input.Vis.AutoCommandedAxialPosition/25.4))**2);
	gMain.Machine.Motion.SideLoad.TorqueScaled:=gMain.Output.Vis.CalculatedForce*gMain.Machine.Motion.SideLoad.ScalingFactor;
		
	
	//Axial Movement
	IF gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB.Info.TorqueControl.InTorque; THEN
	
	
		IF NOT gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles AND gMain.Machine.Motion.AxialMove.FirstMovementFlag THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=1;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=25.4;
			END_IF;
		ELSIF gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles (*AND gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB.Info.TorqueControl.InTorque*) THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=0;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
				gMain.Machine.Motion.AxialMove.CycleCount:=gMain.Machine.Motion.AxialMove.CycleCount+1;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=-25.4;
			END_IF;
		ELSIF NOT gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles AND NOT gMain.Machine.Motion.AxialMove.FirstMovementFlag THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=1;
				gMain.Machine.Motion.AxialMove.FirstMovementFlag:=1;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=12.7;
			END_IF;
		
		ELSIF gMain.Machine.Motion.AxialMove.CycleCount=gMain.Input.Vis.NumberofCycles AND gMain.Input.Vis.StartProgramButton THEN
			IF gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Done THEN
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
			
				gMain.Input.Vis.StartProgramButton:=0;
				gMain.Machine.Motion.AxialMove.CycleCount:=0;
				gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=0;
				gMain.Machine.Motion.AxialMove.FirstMovementFlag:=0;
			ELSE
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=TRUE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Distance:=12.7;
			END_IF;
		END_IF;
	END_IF;
	
	

	
	
	
	
	
	
	
	
	
	//Torque Control Side Load
	gMain.Output.Vis.DisplayedForceFeedback:= gMain.Input.Physical.StrainGauge*gMain.Output.Vis.LoadCellScaleFactor;
	gMain.Machine.Motion.SideLoad.TorqueScaled:=gMain.Output.Vis.DisplayedForceFeedback;
	
	IF gMain.Input.Vis.StartProgramButton THEN
		gMain.Machine.Motion.SideLoad.EnableCyclicTorque:=TRUE;
	ELSE
		gMain.Machine.Motion.SideLoad.EnableCyclicTorque:=FALSE;
	END_IF;
	
	
	//EStop Logic	
	IF gMain.Input.Vis.EStop THEN
		gMain.Input.Vis.EStopPopup:=0;
		FOR i0:=DINT_TO_USINT(Axial) TO DINT_TO_USINT(SideLoad) DO
			gMain.Machine.Motion.Mc_StopFB[i0].Execute:=TRUE;
			IF gMain.Machine.Motion.Mc_StopFB[i0].Done THEN
				gMain.Input.Vis.PowerOnAll:=FALSE;
				gMain.Machine.Motion.SideLoad.EnableCyclicTorque:=FALSE;
				gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial.Execute:=FALSE;
				gMain.Input.Vis.StartProgramButton:=0;
				gMain.Machine.Motion.AxialMove.CycleCount:=0;
				gMain.Machine.Motion.AxialMove.FirstMovementFlag:=0;
			END_IF;
		END_FOR;
		
	ELSE
		gMain.Input.Vis.EStopPopup:=1;
		gMain.Machine.Motion.Mc_StopFB[i0].Execute:=FALSE;
	END_IF;
		
		
		
	
		
	//Axial Move Absolute
	
	gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB(ErrorReset := gMain.Machine.Motion.ErrorResetAll, Torque := gMain.Machine.Motion.SideLoad.TorqueScaled, CyclicTorque := gMain.Machine.Motion.SideLoad.EnableCyclicTorque);
		
	//Move Addative
	gMain.Machine.Motion.AxialMove.MC_MoveAdditive_Axial(Axis := ADR(gAxisAxial),Velocity := 12.7, Acceleration := 25.4, Deceleration := 25.4);
	gMain.Machine.Motion.SideLoad.MC_MoveAdditive_SideLoad(Axis := ADR(gAxisSideLoad),Velocity := 12.7, Acceleration := 25.4, Deceleration := 25.4);
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

