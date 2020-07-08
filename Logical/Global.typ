
TYPE
	InputPhysical_Type : 	STRUCT 
		New_Member : USINT;
	END_STRUCT;
	Output_Type : 	STRUCT 
		Physical : OutputPhysical_Type;
		Vis : OutputVis_Type;
	END_STRUCT;
	OutputVis_Type : 	STRUCT 
		CalculatedForce : REAL;
	END_STRUCT;
	OutputPhysical_Type : 	STRUCT 
		New_Member : USINT;
	END_STRUCT;
	InputVis_Type : 	STRUCT 
		NumberofCycles : USINT;
		ManualCommandedAxialPosition : USINT;
		ManualCommandedSideLoad : REAL;
		AxisSelector : USINT;
		JogNeg : BOOL;
		JogPos : BOOL;
		ManualMoveButton : BOOL;
		StartProgramButton : BOOL;
		AutoCommandedAxialPosition : REAL;
		PowerOnAll : BOOL;
	END_STRUCT;
	Input_Type : 	STRUCT 
		Vis : InputVis_Type;
	END_STRUCT;
	Motion_Type : 	STRUCT 
		MpAxisBasicPar : ARRAY[0..1]OF MpAxisBasicParType;
		MpAxisBasic_FB : ARRAY[0..1]OF MpAxisBasic;
		Error : BOOL;
		HomeAll : BOOL;
		IsHomedAll : BOOL;
		AllAxisReady : BOOL;
		ErrorResetAll : BOOL;
		AxialMove : AxialMove_Type;
		IsPoweredAll : BOOL;
	END_STRUCT;
	Machine_Type : 	STRUCT 
		State : StateEnum;
		Motion : Motion_Type;
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
	Main_Type : 	STRUCT 
		Output : Output_Type;
		Input : Input_Type;
		Machine : Machine_Type;
	END_STRUCT;
	AxialMove_Type : 	STRUCT 
		Amax : REAL;
		TotalDistance : REAL;
		Vmax : REAL;
		TotalTime : REAL;
		CyclicCommandedPosition : REAL;
		CycleAmplitude : REAL;
		ChangeDirectionFlag : BOOL;
		CycleCount : UDINT;
		MC_MoveAbsoluteFB_Axial : MC_MoveAbsolute;
	END_STRUCT;
END_TYPE
