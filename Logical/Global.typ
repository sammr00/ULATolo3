
TYPE
	Alarm_Type : 	STRUCT 
		MpAlarmXListUI_FB : MpAlarmXListUI;
		MpAlarmXAcknowledgeAll_FB : MpAlarmXAcknowledgeAll;
		MpAlarmXListUISetupType : MpAlarmXListUISetupType;
		MpAlarmXListUIConnectType : MpAlarmXListUIConnectType;
		AlarmPopupControl : USINT;
		MpAlarmXCore_FB : MpAlarmXCore;
	END_STRUCT;
	InputPhysical_Type : 	STRUCT 
		LoadtoTorqueScaleFactor : REAL;
		StrainGauge : DINT;
	END_STRUCT;
	Output_Type : 	STRUCT 
		Physical : OutputPhysical_Type;
		Vis : OutputVis_Type;
	END_STRUCT;
	OutputVis_Type : 	STRUCT 
		DisplayedForceFeedback : REAL;
		StatusLED : USINT;
		LoadCellScaleFactor : REAL;
		CalculatedForce : REAL;
	END_STRUCT;
	OutputPhysical_Type : 	STRUCT 
		New_Member : USINT;
	END_STRUCT;
	InputVis_Type : 	STRUCT 
		NumberofCycles : USINT;
		ManualCommandedAxialPosition : REAL;
		ManualReturnButton : BOOL;
		ManualCommandedSideLoad : REAL;
		AxisSelector : USINT;
		JogNeg : BOOL;
		JogPos : BOOL;
		ManualMoveButton : BOOL;
		StartProgramButton : BOOL;
		NominalPosition : REAL;
		AutoCommandedAxialPosition : REAL;
		PowerOnButtonVisibility : USINT;
		JogButtonVisibility : USINT;
		StopButtonVisibility : USINT;
		StartButtonVisability : USINT;
		EStopPopup : USINT;
		EStop : BOOL;
		PowerOnAll : BOOL;
		OscillationDistance : REAL;
		ManualStopButtonVis : UINT;
		ConfirmPopup : USINT;
		ManualGoButtonVis : UINT;
	END_STRUCT;
	Input_Type : 	STRUCT 
		Physical : InputPhysical_Type;
		Vis : InputVis_Type;
	END_STRUCT;
	Motion_Type : 	STRUCT 
		MpAxisBasicPar : ARRAY[Axial..SideLoad]OF MpAxisBasicParType;
		Mc_StopFB : ARRAY[Axial..SideLoad]OF MC_Stop;
		MpAxisBasic_FB : ARRAY[Axial..SideLoad]OF MpAxisBasic;
		Error : BOOL;
		HomeAll : BOOL;
		IsHomedAll : BOOL;
		AllAxisReady : BOOL;
		ErrorResetAll : BOOL;
		SideLoad : SideLoad_Type;
		AxialMove : AxialMove_Type;
		IsPoweredAll : BOOL;
		AtNominalFlag : BOOL;
	END_STRUCT;
	Machine_Type : 	STRUCT 
		State : StateEnum;
		Alarm : Alarm_Type;
		Motion : Motion_Type;
	END_STRUCT;
	Main_Type : 	STRUCT 
		Output : Output_Type;
		Input : Input_Type;
		Machine : Machine_Type;
		Services : Services_Type;
	END_STRUCT;
	SideLoad_Type : 	STRUCT 
		ScalingFactor : REAL;
		EnableCyclicTorque : BOOL;
		TorqueScaled : REAL;
		MC_TorqueControl_FB : MC_TorqueControl;
		MC_MoveAdditive_SideLoad : MC_MoveAdditive;
	END_STRUCT;
	AxialMove_Type : 	STRUCT 
		Amax : REAL;
		TotalDistance : REAL;
		Vmax : REAL;
		TotalTime : REAL;
		CyclicCommandedPosition : REAL;
		CycleAmplitude : REAL;
		FirstMovementFlag : BOOL;
		ChangeDirectionFlag : BOOL;
		CycleCount : UDINT;
		PositionOffset : REAL;
		MC_MoveAdditive_Axial : MC_MoveAdditive;
	END_STRUCT;
	AxisEnum : 
		(
		SideLoad := 1,
		Axial := 0
		);
	StateEnum : 
		(
		Running := 6,
		Idle := 5,
		WaitingForPowerOn := 4,
		Homing := 3,
		AxisReady := 2,
		Init := 1,
		Error := 0
		);
	Services_Type : 	STRUCT 
		MpDataRegPar : MpDataRegPar;
		MpDataRecorder_FB : MpDataRecorder;
	END_STRUCT;
END_TYPE
