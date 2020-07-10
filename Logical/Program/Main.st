
PROGRAM _INIT
	gMain.Machine.Motion.MpAxisBasic_FB[Axial](MpLink := ADR(gAxisBasicAxial), Enable := TRUE, Parameters := ADR(gMain.Machine.Motion.MpAxisBasicPar[Axial]), Axis := ADR(gAxisAxial));
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad](MpLink :=ADR(gAxisBasicSideLoad), Enable := TRUE, Parameters := ADR(gMain.Machine.Motion.MpAxisBasicPar[SideLoad]), Axis := ADR(gAxisSideLoad));
	
	gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial(Axis := ADR(gAxisAxial));
	gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB(MpLink := ADR(gAxisBasicSideLoad), Enable := TRUE, Parameters :=ADR(gMain.Machine.Motion.SideLoad.MpAxisCyclicSetParType));
	
	gMain.Machine.Alarm.MpAlarmXCore_FB(MpLink :=ADR(gAlarmXCore),Enable := TRUE);
	gMain.Machine.Alarm.MpAlarmXListUI_FB(MpLink := ADR(gAlarmXCore), Enable := TRUE, UISetup := gMain.Machine.Alarm.MpAlarmXListUISetupType, UIConnect := ADR(gMain.Machine.Alarm.MpAlarmXListUIConnectType));
	
	
	gMain.Machine.Motion.AxialMove.CycleAmplitude:=12.7;
	gMain.Machine.Motion.AxialMove.TotalTime:=0.165;
	gMain.Machine.Motion.AxialMove.TotalDistance:=gMain.Machine.Motion.AxialMove.CycleAmplitude*2;
	
	//Velocity and Acceleration Calculations for Axial Move
	IF gMain.Machine.Motion.AxialMove.TotalTime<>0.0 THEN
		gMain.Machine.Motion.AxialMove.Vmax:=5000;  //ABS(gMain.Machine.Motion.AxialMove.TotalDistance/(0.5*(gMain.Machine.Motion.AxialMove.TotalTime)));
		gMain.Machine.Motion.AxialMove.Amax:=5000;//ABS(gMain.Machine.Motion.AxialMove.Vmax/(0.5*gMain.Machine.Motion.AxialMove.TotalTime));
	END_IF;
	
	gMain.Machine.Motion.MpAxisBasicPar[Axial].Acceleration:=gMain.Machine.Motion.AxialMove.Amax;
	gMain.Machine.Motion.MpAxisBasicPar[Axial].Deceleration:=gMain.Machine.Motion.AxialMove.Amax;
	gMain.Machine.Motion.MpAxisBasicPar[Axial].Velocity:=gMain.Machine.Motion.AxialMove.Vmax;
	 
END_PROGRAM

PROGRAM _CYCLIC
	gMain.Machine.Motion.AllAxisReady :=TRUE;
	gMain.Machine.Motion.IsHomedAll := TRUE;
	gMain.Machine.Motion.IsPoweredAll := TRUE;
	gMain.Machine.Motion.Error := FALSE;
	
	
	//	//Set Jog Velocity
	//	IF JogVelocity<> gMain.Machine.Motion.AxisPar.Jog.Velocity THEN
	//		gMain.Machine.Motion.AxisPar.Jog.Velocity:=JogVelocity;
	//		gMain.Machine.Motion.MpAxisBasic_FB.Update:=TRUE;
	//	ELSIF gMain.Machine.Motion.MpAxisBasic_FB.UpdateDone THEN
	//		gMain.Machine.Motion.MpAxisBasic_FB.Update:=FALSE;
	//	END_IF;
	
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
			END_IF;
			
			//Jog Logic
			gMain.Machine.Motion.MpAxisBasic_FB[gMain.Input.Vis.AxisSelector].JogPositive:=gMain.Input.Vis.JogPos;
			gMain.Machine.Motion.MpAxisBasic_FB[gMain.Input.Vis.AxisSelector].JogNegative:=gMain.Input.Vis.JogNeg;
			
		Running:
			IF gMain.Machine.Motion.Error THEN
				gMain.Machine.State:=Error;
			ELSIF gMain.Machine.Motion.IsPoweredAll=FALSE THEN
				gMain.Machine.State:=WaitingForPowerOn;
			END_IF;

	END_CASE;
	
	//Alarms
	gMain.Machine.Alarm.MpAlarmXCore_FB(ErrorReset := gMain.Machine.Motion.ErrorResetAll);
	gMain.Machine.Alarm.MpAlarmXListUI_FB(ErrorReset := gMain.Machine.Motion.ErrorResetAll);
	gMain.Machine.Alarm.AlarmPopupControl:=BOOL_TO_USINT(NOT UDINT_TO_BOOL(gMain.Machine.Alarm.MpAlarmXCore_FB.ActiveAlarms));
	
	
	
	
	//Force Calculation
	gMain.Output.Vis.CalculatedForce:=-1957.5693+(240.0518*(gMain.Input.Vis.AutoCommandedAxialPosition/25.4))-(6.3530*((gMain.Input.Vis.AutoCommandedAxialPosition/25.4))**2);
	gMain.Machine.Motion.SideLoad.TorqueScaled:=gMain.Output.Vis.CalculatedForce*gMain.Machine.Motion.SideLoad.ScalingFactor;
		
	
	//Axial Movement
//	IF NOT gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles THEN
//		IF gMain.Machine.Motion.MpAxisBasic_FB[Axial].Info.MoveDone THEN
//			gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=1;
//			gMain.Machine.Motion.MpAxisBasic_FB[Axial].MoveAbsolute:=FALSE;
//		ELSE
//			gMain.Machine.Motion.MpAxisBasicPar[Axial].Position:=gMain.Input.Vis.AutoCommandedAxialPosition+gMain.Machine.Motion.AxialMove.CycleAmplitude;
//			IF gMain.Machine.Motion.MpAxisBasic_FB[Axial].UpdateDone AND NOT gMain.Machine.Motion.MpAxisBasic_FB[Axial].MoveActive  THEN
//				gMain.Machine.Motion.MpAxisBasic_FB[Axial].Update:=FALSE;
//				gMain.Machine.Motion.MpAxisBasic_FB[Axial].MoveAbsolute:=TRUE;
//			ELSE
//				gMain.Machine.Motion.MpAxisBasic_FB[Axial].Update:=TRUE;
//			END_IF;
//		END_IF;
//	ELSIF gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles THEN
//		IF gMain.Machine.Motion.MpAxisBasic_FB[Axial].Info.MoveDone THEN
//			gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=0;
//			gMain.Machine.Motion.MpAxisBasic_FB[Axial].MoveAbsolute:=FALSE;
//			gMain.Machine.Motion.AxialMove.CycleCount:=gMain.Machine.Motion.AxialMove.CycleCount+1;
//		ELSE
//			gMain.Machine.Motion.MpAxisBasicPar[Axial].Position:=gMain.Input.Vis.AutoCommandedAxialPosition-gMain.Machine.Motion.AxialMove.CycleAmplitude;
//			IF gMain.Machine.Motion.MpAxisBasic_FB[Axial].UpdateDone AND NOT gMain.Machine.Motion.MpAxisBasic_FB[Axial].MoveActive THEN
//				gMain.Machine.Motion.MpAxisBasic_FB[Axial].Update:=FALSE;
//				gMain.Machine.Motion.MpAxisBasic_FB[Axial].MoveAbsolute:=TRUE;
//			ELSE
//				gMain.Machine.Motion.MpAxisBasic_FB[Axial].Update:=TRUE;
//			END_IF;
//			
//		END_IF;
//	ELSIF gMain.Machine.Motion.AxialMove.CycleCount=gMain.Input.Vis.NumberofCycles THEN
//		gMain.Input.Vis.StartProgramButton:=0;
//		gMain.Machine.Motion.AxialMove.CycleCount:=0;
//	END_IF;
	
	
	
	IF NOT gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles THEN
		IF gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial.Done THEN
			gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=1;
			gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial.Execute:=FALSE;
		ELSE
			gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial.Execute:=TRUE;
			gMain.Machine.Motion.AxialMove.CyclicCommandedPosition:=gMain.Input.Vis.AutoCommandedAxialPosition+gMain.Machine.Motion.AxialMove.CycleAmplitude;
		END_IF;
	ELSIF gMain.Machine.Motion.AxialMove.ChangeDirectionFlag AND gMain.Input.Vis.StartProgramButton AND gMain.Machine.Motion.AxialMove.CycleCount<gMain.Input.Vis.NumberofCycles THEN
		IF gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial.Done THEN
			gMain.Machine.Motion.AxialMove.ChangeDirectionFlag:=0;
			gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial.Execute:=FALSE;
			gMain.Machine.Motion.AxialMove.CycleCount:=gMain.Machine.Motion.AxialMove.CycleCount+1;
		ELSE
			gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial.Execute:=TRUE;
			gMain.Machine.Motion.AxialMove.CyclicCommandedPosition:=gMain.Input.Vis.AutoCommandedAxialPosition-gMain.Machine.Motion.AxialMove.CycleAmplitude;
		END_IF;
	ELSIF gMain.Machine.Motion.AxialMove.CycleCount=gMain.Input.Vis.NumberofCycles THEN
		gMain.Input.Vis.StartProgramButton:=0;
		gMain.Machine.Motion.AxialMove.CycleCount:=0;
	END_IF;
	
	//Torque Control Side Load
	
	
	
	
	
	
	//Motion Function Call
	FOR i0:=DINT_TO_USINT(Axial) TO DINT_TO_USINT(SideLoad) DO
		gMain.Machine.Motion.MpAxisBasic_FB[i0](ErrorReset := gMain.Machine.Motion.ErrorResetAll, Power := gMain.Input.Vis.PowerOnAll, Home := gMain.Machine.Motion.HomeAll);
	END_FOR;
	
	//Axial Move Absolute

	gMain.Machine.Motion.AxialMove.MC_MoveAbsoluteFB_Axial(Position := gMain.Machine.Motion.AxialMove.CyclicCommandedPosition, Velocity := gMain.Machine.Motion.AxialMove.Vmax, Acceleration := gMain.Machine.Motion.AxialMove.Amax, Deceleration := gMain.Machine.Motion.AxialMove.Amax);
	
	gMain.Machine.Motion.SideLoad.MpAxisCyclicSet_FB(ErrorReset := gMain.Machine.Motion.ErrorResetAll, Torque := gMain.Machine.Motion.SideLoad.TorqueScaled, CyclicTorque := gMain.Machine.Motion.SideLoad.EnableCyclicTorque);
	
	
	//MpAxisBasic_0(MpLink := , Enable := , ErrorReset := , Parameters := , Update := , Axis := , Power := , Home := , MoveVelocity := , MoveAbsolute := , MoveAdditive := , Stop := , JogPositive := , JogNegative := , Autotune := , Simulate := , TorqueLimit := , ReleaseBrake := );
	
	
END_PROGRAM

PROGRAM _EXIT
	gMain.Machine.Motion.MpAxisBasic_FB[Axial](Enable := FALSE);
	gMain.Machine.Motion.MpAxisBasic_FB[SideLoad](Enable := FALSE);
	 
END_PROGRAM
