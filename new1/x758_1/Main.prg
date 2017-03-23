Global String CmdRev$, CmdSend$, MsgSend$
Global String CmdRevStr$(20)
Global Integer CurPosition_Num, TargetPosition_Num

Global Boolean NeedChancel(4)

Global Preserve Boolean Tester_Select(4), Tester_Fill(4)
Global Boolean Tester_Testing(4)
Global Preserve Integer Tester_Pass(4), Tester_Ng(4), Tester_Timeout(4)
'治具中的产品为复测产品标志
'0:New
'1:复测1次,A
'2:复测2次,AA
'3:复测3次
Global Preserve Integer Tester_ReTestFalg(4)
Global String PickAorC$(4)

Global Integer NgContinue(4)
Global Preserve Integer NgContinueNum
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4
Global Integer Pick_P_Msg(4)
Global Real TesterTimeElapse(4)

Global Integer ScanResult
Global Preserve Boolean PreFeedFill(6)
Global Preserve Boolean FeedFill(6)

Global Boolean PickHave(4)
Global Preserve Integer PassTrayPalletNum, NgTrayPalletNum
Global Integer FeedReadySigleDown, PassTraySigleDown, NgTraySigleDown, INP_HomeSigleDown

Global Preserve Integer FeedPanelNum

Global Preserve Boolean ReTest_

Global Integer Discharge

Global Integer S_Position

'路径规划用
Global Integer PassStepNum
'主函数
Global Integer LoopTestFlexIndex

Global Boolean IsLoopTestMode

Global Boolean NeedAnotherMove(4)
Global Boolean isInWaitPosition(4)
Global Boolean isXqtting
'Global Boolean Position2NeedNeedAnotherMove

Global Preserve Integer BarcodeMode

Global Boolean NeedCleanAction
Global Boolean CleanActionFlag
Global Boolean CleanActionFinishFlag

Global Boolean CheckFlexVoccum(4)


Global Integer ResetCMDComplete


Global Integer NowFlexIndex

Global Integer Ftarget
Global Integer Ttarget
Global Integer Fcurrent
Global Integer Tcurrent

Global Boolean needreleaseadjust

'Global Integer TMoveComplete
'Global Integer FMoveComplete

Function main
	
	Do
		Wait 1
		
		
		
		
		
		
	Loop

Fend

Function main2
	

	Integer i
	Integer fillNum, selectNum
	Trap Emergency Xqt TrapInterruptAbort
	Trap Abort Xqt TrapInterruptAbort
	Trap Error Xqt TrapInterruptAbort
	
	Wait 0.2
	Xqt TesterStart1, NoEmgAbort
	Wait 0.2
	Xqt TesterStart2, NoEmgAbort
	Wait 0.2
	Xqt TesterStart3, NoEmgAbort
	Wait 0.2
	Xqt TesterStart4, NoEmgAbort
	Xqt AllMonitor, NoEmgAbort
'	Call InitAction
	Wait 0.2
	Off Discharing
	Print "请按继续，开始复位"
	MsgSend$ = "请按继续，开始复位"
	Pause
	Call TrapInterruptAbort
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf
    
	
	Call HomeReturnAction

	If Sw(FeedReady) = 0 Then
		Print "等待上料结束"
		MsgSend$ = "等待上料结束"
		On FeedEmpty
		Off AdjustValve
		FeedReadySigleDown = 0
		FeedPanelNum = 0
	EndIf
	Wait Sw(FeedReady) = 1
	FeedReadySigleDown = 1
	
main_label1:
	Wait 0.2
	If CleanActionFlag Then
		Print "清洁操作，开始"
		MsgSend$ = "清洁操作，开始"
		Call CleanActionProcess
		Print "清洁操作，结束"
		MsgSend$ = "清洁操作，结束"
		CleanActionFlag = False
		CleanActionFinishFlag = True
		Discharge = 0
		Off Discharing, Forced
	EndIf
	
	If Not CleanActionFinishFlag Then
		Print "请按继续，开始运行"
		MsgSend$ = "请按继续，开始运行"
		Pause
	Else
		CleanActionFinishFlag = False
	EndIf

	Do
		

		selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)

		If Discharge <> 0 And fillNum = 0 And PickHave(0) = False And PickHave(1) = False Then
			
			
			TargetPosition_Num = 1
			
			FinalPosition = ChangeHandL
						
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			Print "排料完成"
			MsgSend$ = "排料完成"
			If NeedCleanAction Then
				NeedCleanAction = False
				CleanActionFlag = True
			Else
				Discharge = 0
				Off Discharing, Forced
			EndIf
			Exit Do
		EndIf
			If PickHave(0) = False And PickHave(1) = False Then
				Call PickFeedOperate1
			EndIf
			Call UnloadOperate(0)
			'处理A爪头
			Call TesterOperate1
			Call UnloadOperate(1)
	        '处理B爪头
			Call TesterOperate2
			Call UnloadOperate(0)

	Loop
	GoTo main_label1
Fend
Function CleanActionProcess
	Integer i, rearnum
	For i = 0 To 3
		If Tester_Select(i) Then
			GoSub CleanBlowSub
			Print "测试机" + Str$(i + 1) + "，清洁完成"
			MsgSend$ = "测试机" + Str$(i + 1) + "，清洁完成"
		EndIf
	Next
	TargetPosition_Num = 1
	If Hand = 1 Then
		FinalPosition = ChangeHandL /R :Z(-10)
	Else
		FinalPosition = ChangeHandL /L :Z(-10)
	EndIf
	
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Exit Function
CleanBlowSub:
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(8) -X(5)
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(8) -X(5)
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(8) -X(5)
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(8) -X(5)
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call CleanBlowAction(1, i + 1)
Return
Fend
Function InitAction
	
	Integer i
	PickHave(0) = False

	'PASS Cui 阵列
	Pallet 1, PCui1_1, PCui1_2, PCui1_3, 2, 2
	Pallet 2, PCui2_1, PCui2_2, PCui2_3, 2, 2
	Pallet 3, PCui3_1, PCui3_1, PCui3_2, 1, 2
	Pallet 4, PCui4_1, PCui4_1, PCui4_2, 1, 2
	
	Pallet 6, PCui1_1_A, PCui1_2_A, PCui1_3_A, 2, 2
	Pallet 7, PCui2_1_A, PCui2_2_A, PCui2_3_A, 2, 2
	Pallet 8, PCui3_1_A, PCui3_1_A, PCui3_2_A, 1, 2
	Pallet 9, PCui4_1_A, PCui4_1_A, PCui4_2_A, 1, 2
	
	'NG Cui 阵列
'	Pallet 5, NCui1, NCui2, NCui3, 2, 8
	Pallet 5, NCui_1, NCui_2, NCui_3, 2, 7
	Pallet 10, NCui_1_A, NCui_2_A, NCui_3_A, 2, 7
	PassStepNum = 0
	
'	For i = 0 To 5
'		PreFeedFill(i) = False
'	Next
	For i = 0 To 3
		NeedAnotherMove(i) = False
		isInWaitPosition(i) = False
	Next
	FeedPanelNum = 0
'	PassTrayPalletNum = 1
'	NgTrayPalletNum = 1
'	Position2NeedNeedAnotherMove = False
    NeedCleanAction = False;
    CleanActionFlag = False;
    CleanActionFinishFlag = False;
    Discharge = 0
Fend
Function ClearAction
	Integer i
	For i = 0 To 3
		Tester_Pass(i) = 0
		Tester_Ng(i) = 0
		Tester_Timeout(i) = 0
		Tester_Fill(i) = False
		Tester_Testing(i) = False
		
		
	'	Tester_Ng(4), Tester_Timeout(4)
	Next
	FeedPanelNum = 0
'	For i = 0 To 5
'		FeedFill(i) = True
'	Next
'	For i = 0 To 5
'		PreFeedFill(i) = True
'	Next
'	FeedReadySigleDown = 1
'	PassTraySigleDown = 1
'	NgTrayPalletNum = 1
'	NgTraySigleDown = 1

	
Fend
Function XQTAction(num As Integer)
'1:上料命令
'2:下料命令
	isXqtting = True
	Select num
		Case 1
			Off RollValve, Forced
			Off FeedEmpty, Forced
			Wait 0.5
			On FeedEmpty, Forced
			FeedReadySigleDown = 0
			PassTrayPalletNum = 1
			Wait 0.5
			Off FeedEmpty, Forced
			FeedPanelNum = 0
		Case 2
'			Off PassTrayFull, Forced
'			Wait 0.5
'			On PassTrayFull, Forced
'			PassTraySigleDown = 0
'			PassTrayPalletNum = 1
'			Wait 0.5
'			Off PassTrayFull, Forced
		Case 3
'			Off SHome, Forced
'			Wait 0.5
'			On SHome, Forced
'			INP_HomeSigleDown = 0
'
'			Wait 0.5
'			Off SHome, Forced
			
	Send
	isXqtting = False
Fend
Function AllMonitor
	
	Integer FeedReady_, PassTrayRdy_, INP_Home_, i, NgTrayRdy_
	FeedReady_ = Sw(FeedReady)

	Do
		Wait 0.1
		If FeedReady_ <> Sw(FeedReady) Then
			FeedReady_ = Sw(FeedReady)
			If Sw(FeedReady) = 1 Then
				
'				For i = 0 To 5
'					If Sw(535 + i) = 1 Then
'						FeedFill(i) = True
'					Else
'						FeedFill(i) = False
'					EndIf
''					FeedFill(i) = PreFeedFill(i)
'				Next
				If Sw(PreFill2) = 1 Then
					FeedFill(0) = True
				Else
					FeedFill(0) = False
				EndIf
				If Sw(PreFill4) = 1 Then
					FeedFill(1) = True
				Else
					FeedFill(1) = False
				EndIf
				If Sw(PreFill6) = 1 Then
					FeedFill(2) = True
				Else
					FeedFill(2) = False
				EndIf
				If Sw(PreFill5) = 1 Then
					FeedFill(3) = True
				Else
					FeedFill(3) = False
				EndIf
				If Sw(PreFill3) = 1 Then
					FeedFill(4) = True
				Else
					FeedFill(4) = False
				EndIf
				If Sw(PreFill1) = 1 Then
					FeedFill(5) = True
				Else
					FeedFill(5) = False
				EndIf
				
				Off FeedEmpty, Forced
				On AdjustValve, Forced
				Wait 0.5
				FeedReadySigleDown = 1
				FeedPanelNum = 0
			Else
'				FeedReadySigleDown = 1
				Off FeedEmpty, Forced
			EndIf
		EndIf
		

		
	
	Loop
Fend
Function test1
'	MemOutW 0, 65535
'	P500 = XY(MemInW(0), 0, 0, 0)
'	Print CX(P500)
'	PLabel 500, "XtestP1"
'	SavePoints "robot1.pts"
'	OutW SpositionY, 65534




Fend
Function test2

Fend
'单爪手取操作
Function PickFeedOperate0

	Boolean scanflag, pickfeedflag, fullflag
PickFeedOperatelabel1:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Discharge = 0 Then
		'上料等
		TargetPosition_Num = 1
		If Hand = 1 Then
			FinalPosition = ChangeHandL /R :Z(-10)
		Else
			FinalPosition = ChangeHandL /L :Z(-10)
		EndIf
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "上料盘，未准备好"
		MsgSend$ = "上料盘，未准备好"
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0
			Wait 0.2
			If Discharge <> 0 Then
                Exit Do
			EndIf
		Loop
		If Discharge = 0 Then
			Print "上料盘，准备好"
			MsgSend$ = "上料盘，准备好"
		EndIf
	EndIf
	
	If Discharge = 0 Then
		If FeedFill(FeedPanelNum) = True Then
			scanflag = ScanBarcodeOpetate(FeedPanelNum Mod 3, "A")
			If scanflag Then
				TargetPosition_Num = 1
				If Hand = 1 Then
					FinalPosition = P(20 + FeedPanelNum)
				Else
					FinalPosition = P(11 + FeedPanelNum)
				EndIf
				
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				pickfeedflag = PickAction(0)
				If pickfeedflag = False Then
					Wait 1
					pickfeedflag = PickAction(0)
				EndIf
				
				FeedFill(FeedPanelNum) = False
				PickHave(0) = pickfeedflag
				If pickfeedflag Then
					MemOn 99
					Sense MemSw(99)
					If Hand = 1 Then
						Jump ChangeHandL /R Sense
					Else
						Jump ChangeHandL /L Sense
					EndIf
					
					FeedPanelNum = FeedPanelNum + 1
					Call IsFeedPanelEmpty(False)
				Else
					Print "上料盘，吸取失败"
					MsgSend$ = "上料盘，吸取失败"
					Go Here +Z(30)
					Pause
					
					BlowSuckFail(0)
					FeedPanelNum = FeedPanelNum + 1
					fullflag = IsFeedPanelEmpty(True)
					If fullflag Then
						GoTo PickFeedOperatelabel1
					EndIf
				EndIf
				
			Else
				'没扫上，则为石刻不良
				Print "蚀刻不良"
				MsgSend$ = "蚀刻不良"
				Pause
				
				TargetPosition_Num = 1
				If Hand = 1 Then
					FinalPosition = P(20 + FeedPanelNum)
				Else
					FinalPosition = P(11 + FeedPanelNum)
				EndIf
				
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				pickfeedflag = PickAction(0)
				If pickfeedflag = False Then
					Wait 1
					pickfeedflag = PickAction(0)
				EndIf
				FeedFill(FeedPanelNum) = False
				PickHave(0) = pickfeedflag
				If pickfeedflag Then
					TargetPosition_Num = 11
					FinalPosition = P(Int(Rnd(40) / 10) + 110)
					Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
					ReleaseAction(0, -1)
					PickHave(0) = False
					FeedPanelNum = FeedPanelNum + 1
					fullflag = IsFeedPanelEmpty(False)
				Else
					Print "上料盘，吸取失败"
					MsgSend$ = "上料盘，吸取失败"
					Go Here +Z(30)
					Pause
					FeedPanelNum = FeedPanelNum + 1
					fullflag = IsFeedPanelEmpty(True)
				EndIf
				

				If fullflag Then
					GoTo PickFeedOperatelabel1
				EndIf
			EndIf
		Else
			FeedPanelNum = FeedPanelNum + 1;
			Call IsFeedPanelEmpty(True)
		EndIf

		
	EndIf
	
Fend
'爪手A取操作
Function PickFeedOperate1
	Boolean pickfeedflag, fullflag, InWaitPosition
	Integer scanflag
	InWaitPosition = False
PickFeedOperatelabel1:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Discharge = 0 Then
	
		TargetPosition_Num = 1
		FinalPosition = ChangeHandL
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		
		Print "上料盘，未准备好"
		MsgSend$ = "上料盘，未准备好"
		Off AdjustValve
		Off DangerOut
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0 Or Sw(DangerIn) = 1
			Wait 0.2
			If Discharge <> 0 And Sw(DangerIn) = 0 Then
                Exit Do
			EndIf
		Loop
		If Discharge = 0 Then
			Print "上料盘，准备好"
			MsgSend$ = "上料盘，准备好"
		EndIf
		On AdjustValve
		Wait 0.5
		
	EndIf
	
	If Discharge = 0 Then
		On DangerOut
		If Sw(RollReset) = 0 And Sw(RollSet) = 0 Then
			Print "等待 旋转盘到位"
			MsgSend$ = "等待 旋转盘到位"
			Wait Sw(RollReset) = 1 Or Sw(RollSet) = 1
			Wait 1.5
		EndIf
		
		
'		If Tcurrent = 1 Then
'			Print "下料轴，与取料位置可能存在干涉"
'			MsgSend$ = "下料轴，与取料位置可能存在干涉"
'			If Ttarget = 1 Then
'				Ttarget = 2
'				If CmdSend$ <> "" Then
'					Print "有命令 " + CmdSend$ + " 待发送！"
'				EndIf
'				Do While CmdSend$ <> ""
'					Wait 0.1
'				Loop
'				CmdSend$ = "TMOVE,2"
'			EndIf
'		EndIf
'		Wait Tcurrent <> 1
		
		If FeedFill(FeedPanelNum) = True Then
			
			TargetPosition_Num = 1
			
			FinalPosition = P(11 + FeedPanelNum)
			
			
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			needreleaseadjust = True
			pickfeedflag = PickAction(0)
			If pickfeedflag = False Then
				Wait 0.01
				pickfeedflag = PickAction(0)
			EndIf
			needreleaseadjust = False
			FeedFill(FeedPanelNum) = False
			PickHave(0) = pickfeedflag
			If pickfeedflag Then
				Go Here +Z(10)
				On AdjustValve
				FeedPanelNum = FeedPanelNum + 1
				
				scanflag = ScanBarcodeOpetateP3("A")
				fullflag = IsFeedPanelEmpty(False)
				Select scanflag
					Case 1
						Print "扫码成功"
						Pick_P_Msg(0) = -1

					Default
						Print "扫码不良"
						MsgSend$ = "扫码不良"
'						Pause
						Pick_P_Msg(0) = 1
						
				Send

				

			Else
				Print "上料盘，吸取失败"
				MsgSend$ = "上料盘，吸取失败"
				Go Here +Z(10)
				Pause
				On AdjustValve
				BlowSuckFail(0)
				FeedPanelNum = FeedPanelNum + 1
				fullflag = IsFeedPanelEmpty(True)
				If fullflag Then
					GoTo PickFeedOperatelabel1
				EndIf
			EndIf
				

		Else
			FeedPanelNum = FeedPanelNum + 1;
			Call IsFeedPanelEmpty(True)
		EndIf

		
	EndIf

Fend
'爪手B取操作
Function PickFeedOperate2
	Integer i
	Boolean scanflag, pickfeedflag
PickFeedOperatelabel2:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Discharge = 0 Then
		TargetPosition_Num = 1
		FinalPosition = ChangeHandL
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0
			Wait 0.2
			If Discharge <> 0 Then
				Exit Do
            EndIf
		Loop
	EndIf
	If Discharge = 0 Then
		For i = 3 To 5
			If FeedFill(i) Then
				Exit For
			EndIf
		Next
		If i > 5 Then
			For i = 0 To 2
				If FeedFill(i) Then
					Exit For
				EndIf
			Next
			If i > 2 Then
				'料盘空了
'				Call IsFeedPanelEmpty
	'			GoTo PickFeedOperatelabel2
			Else
				GoTo PickFeedOperatelabel2_2
			EndIf
		Else
PickFeedOperatelabel2_2:
			scanflag = ScanBarcodeOpetate(i, "C")
			If scanflag Then
				TargetPosition_Num = 1
				FinalPosition = P(21 + i)
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				pickfeedflag = PickAction(2)
				FeedFill(i) = False
				PickHave(2) = pickfeedflag
				If pickfeedflag Then
					
'					Call IsFeedPanelEmpty
				Else
					BlowSuckFail(2)
'					Call IsFeedPanelEmpty
					GoTo PickFeedOperatelabel2
				EndIf
				
			Else
				FeedFill(i) = False
				GoTo PickFeedOperatelabel2
			EndIf
		EndIf
    EndIf

Fend
'判断上料盘是否取空
Function IsFeedPanelEmpty(needwait As Boolean) As Boolean
'	Integer i, j
    LimZ -24
	If FeedPanelNum > 5 Then
		'料盘空了
		If CurPosition_Num = 1 Then
			If CU(Here) - CU(ChangeHandL) > 90 Or CU(Here) - CU(ChangeHandL) < -90 Then
				Pass ScanPositionP3L;
			EndIf
			
			Go ChangeHandL

		EndIf

		
		Off RollValve
		Off AdjustValve
		If needwait Then
			Wait Sw(RollReset) = 1
			Wait 1.5
		EndIf
		On FeedEmpty
		FeedReadySigleDown = 0
		IsFeedPanelEmpty = True
		FeedPanelNum = 0

	Else
		If FeedPanelNum = 3 Then
			On RollValve
			If needwait Then
				Wait Sw(RollSet) = 1
				Wait 1.5
			EndIf
		EndIf
		IsFeedPanelEmpty = False
	EndIf
Fend
'循环单台测试，取
Function TesterOperate001(i As Integer)
	
	Boolean scanflag, pickfeedflag
	Integer rearnum
	If PickHave(i) = False Then
		If Tester_Fill(i) = False Then
		'从上料盘取料	
'			scanflag = ScanBarcodeOpetate(0, "A")
			scanflag = True
			If scanflag = True Then
				TargetPosition_Num = 1
				If Hand = 1 Then
					FinalPosition = P(20 + FeedPanelNum)
				Else
					FinalPosition = P(11 + FeedPanelNum)
				EndIf
				
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				pickfeedflag = PickAction(0)
				PickHave(0) = pickfeedflag
				If pickfeedflag Then
					MemOn 99
					Sense MemSw(99)
					If Hand = 1 Then
						Jump ChangeHandL /R Sense
					Else
						Jump ChangeHandL /L Sense
					EndIf
				Else
					Print "上料盘，吸取失败"
					MsgSend$ = "上料盘，吸取失败"
					Go Here +Z(20)
					Pause
				EndIf
			Else
				Print "扫码失败"
				MsgSend$ = "扫码失败"
				Pause
			EndIf
		Else
		'从治具取料				
			If Tester_Select(i) = False Then
				Print "测试机,未选择"
				MsgSend$ = "测试机,未选择"
				Do
					If Tester_Select(i) = True Then
						Exit Do
					EndIf
					Wait 1
				Loop
			EndIf
			If Tester_Testing(i) = True Then
				Print "测试机,正在测试过程中。前往等待位置。"
				MsgSend$ = "测试机,正在测试过程中。前往等待位置。"
				Select i
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = A1PASS1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS1
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = A4PASS3
				Send
				FinalPosition = FinalPosition1
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				Do
					If Tester_Testing(i) = False Then
						Exit Do
					EndIf
					Wait 0.2
				Loop
				GoTo TesterOperate001Label1
			
			Else
TesterOperate001Label1:
				GoSub TesterOperate001SuckSub
			EndIf
			
			
		EndIf
	EndIf
	Exit Function
TesterOperate001SuckSub:
	'取

	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
			Off AL_Suck
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
			Off AR_Suck
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
			Off BL_Suck
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
			Off BR_Suck
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	
	PickHave(0) = PickAction(0)

	Tester_Fill(i) = False;
	
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	Go FinalPosition1
	
	If PickHave(0) = False Then

		Print "测试机" + Str$(i + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，吸取失败"
		Pause
		Off i * 2
	Else
		Print "测试机" + Str$(i + 1) + "，测试完成"
		MsgSend$ = "测试机" + Str$(i + 1) + "，测试完成"
		Pause
		MsgSend$ = "单穴测试，一次完成"
	EndIf
Return
Fend
'循环单台测试，放
Function TesterOperate002(i As Integer)
	Integer rearnum
	If PickHave(i) = True Then
	'向治具放料				
		If Tester_Select(i) = False Then
			Print "测试机,未选择"
			MsgSend$ = "测试机,未选择"
			Do
				If Tester_Select(i) = True Then
					Exit Do
				EndIf
				Wait 1
			Loop
		EndIf
		If Tester_Fill(i) = True Then
			Print "测试机,有料。前往等待位置。"
			MsgSend$ = "测试机,有料。前往等待位置。"
			Select i
				Case 0
					TargetPosition_Num = 2
					'A_1，依据TesterOperate1更改
					FinalPosition1 = A1PASS1
				Case 1
					TargetPosition_Num = 3
					FinalPosition1 = A2PASS1
				Case 2
					TargetPosition_Num = 4
					FinalPosition1 = A3PASS1
				Case 3
					TargetPosition_Num = 5
					FinalPosition1 = A4PASS3
			Send
			FinalPosition = FinalPosition1
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			Wait 0.2
			Print "测试机,有料。请先将其取走。"
			MsgSend$ = "测试机,有料。请先将其取走。"
			Pause
			Tester_Fill(i) = False
			GoTo TesterOperate002Label1
		
		Else
TesterOperate002Label1:
			GoSub TesterOperate002ReleaseSub
		EndIf
	EndIf
	Exit Function
TesterOperate002ReleaseSub:
'有空穴
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(0, i + 1)
	PickHave(0) = False
	Tester_Fill(i) = True;
	'退出来，发送启动命令
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	Go FinalPosition1
'	Tester_Testing(i) = True
	PickAorC$(i) = "A"
Return
Fend
'单爪手处理测试机程序，取
Function TesterOperate01
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(0) = False Then
		'判断是否全为选测试机
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "未选择测试机,参与测试！"
				MsgSend$ = "未选择测试机，参与测试！"
			Else
				Exit Do
			EndIf
		Loop

		For i = 0 To 3
			
			'存在穴满，也测试完成
			If Tester_Fill(i) = True And Tester_Testing(i) = False Then
				Exit For
			EndIf
		Next
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
		'未空
		If fillNum <> 0 Then
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "测试机，都在测试中。前往预判位置。"
				MsgSend$ = "测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 0
				For i = 0 To 3
					If Tester_Select(i) = True And Tester_Fill(i) = True Then
						If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
							realbox = TesterTimeElapse(i)
							i_index = i
						EndIf
					EndIf
				Next
				Select i_index
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = A1PASS1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS1
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = A4PASS3
				Send
				FinalPosition = FinalPosition1
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
TesterOperate1_lable4:
				For i = 0 To 3
					If Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				Next
				If i > 3 Then
					Wait 0.2
					'一直判断
					GoTo TesterOperate1_lable4
				EndIf
				GoTo TesterOperate1_lable5
			Else
TesterOperate1_lable5:
				
                GoSub TesterOperate1SuckSub

				If NeedChancel(i) = True Then
					Tester_Select(i) = False
					NeedChancel(i) = False
				EndIf
			EndIf
		Else
		'所有治具都为空
		EndIf

	EndIf
	Exit Function
'取产品子函数	
TesterOperate1SuckSub:
	'取

	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'	If CmdSend$ <> "" Then
'		Print "有命令 " + CmdSend$ + " 待发送！"
'	EndIf
'	Do While CmdSend$ <> ""
'		Wait 0.1
'	Loop
'	CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",A"
	
	PickHave(0) = PickAction(0)

	Tester_Fill(i) = False;
	
	If PickHave(0) = True Then
		If Tester_Pass(i) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4					
			Pick_P_Msg(0) = 0
			NgContinue(i) = 0
		Else
			

			Pick_P_Msg(0) = 1
	
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Print "测试机" + Str$(i + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(i + 1) + "，连续NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
		EndIf
	Else
		Select i
			Case 0
				TargetPosition_Num = 2
				'A_1，依据TesterOperate1更改
				FinalPosition1 = A1PASS1
				rearnum = 4
			Case 1
				TargetPosition_Num = 3
				FinalPosition1 = A2PASS1
				rearnum = 5
			Case 2
				TargetPosition_Num = 4
				FinalPosition1 = A3PASS1
				rearnum = 14
			Case 3
				TargetPosition_Num = 5
				FinalPosition1 = A4PASS3
				rearnum = 15
		Send
		Go FinalPosition1
		Print "测试机" + Str$(i + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，吸取失败"
		Pause
		Off i * 2
	EndIf
Return

Fend
'单爪手处理测试机程序，放
Function TesterOperate02
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(0) = True Then
		'判断是否全为选测试机
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "未选择测试机,参与测试！"
				MsgSend$ = "未选择测试机，参与测试！"
			Else
				Exit Do
			EndIf
		Loop
		'判断是否存在空穴
		For i = 0 To 3

			If Tester_Select(i) = True And Tester_Fill(i) = False Then
				Exit For
			EndIf

		Next
		If i > 3 Then
		'都满
			Print "测试机都满,无法再放产品!"
			MsgSend$ = "测试机都满,无法再放产品!"
			Pause
		Else
'单放
			GoSub TesterOperate1ReleaseSub
		EndIf

	EndIf
	Exit Function

TesterOperate1ReleaseSub:
'有空穴
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(0, i + 1)
	PickHave(0) = False
	Tester_Fill(i) = True;
	'退出来，发送启动命令
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	Go FinalPosition1
	Tester_Testing(i) = True
	PickAorC$(i) = "A"
Return

Fend
'A抓手处理测试机程序
Function TesterOperate1
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	Boolean isA_NeedReJuge
	If PickHave(0) = True Then
		'判断是否全为选测试机
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "未选择测试机,参与测试！"
				MsgSend$ = "未选择测试机，参与测试！"
			Else
				Exit Do
			EndIf
		Loop
		'判断是否存在空穴
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg，依据TesterOperate1更改
				If Tester_Select(i) = True And Tester_Fill(i) = False And (Pick_P_Msg(0) - 2) <> i Then
					If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And i <= 1 Then
						Exit For
					ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And i >= 2 Then
						Exit For
					ElseIf Pick_P_Msg(0) - 2 < 0 Then
						Exit For
					EndIf
					
				EndIf
			Else
				If Tester_Select(i) = True And Tester_Fill(i) = False Then
					Exit For
				EndIf
			EndIf
		Next
		If i > 3 Then
		'都满穴 或 排料
'			selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
'			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
'			testingNum = 8 * Tester_Testing(3) + 4 * Tester_Testing(2) + 2 * Tester_Testing(1) + Tester_Testing(0)
			For i = 0 To 3
				If ReTest_ Then
					If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i And Tester_Testing(i) = False Then
						If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And i <= 1 Then
							Exit For
						ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And i >= 2 Then
							Exit For
						ElseIf Pick_P_Msg(0) - 2 < 0 Then
							Exit For
						EndIf
					EndIf
				Else
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				EndIf
			Next
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "所有选中的测试机，都在测试中。前往预判位置。"
				MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 0
				For i = 0 To 3
'					If ReTest_ Then
'						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i Then
'							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
'								realbox = TesterTimeElapse(i)
'								i_index = i
'							EndIf
'							
'						EndIf
'					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
'					EndIf
				Next
				Select i_index
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = A1PASS1
'						Position2NeedNeedAnotherMove = True
						
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS1
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = A4PASS3
				Send
				FinalPosition = FinalPosition1
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				isInWaitPosition(i_index) = True
TesterOperate1_lable1:
				For i = 0 To 3
					If ReTest_ Then
						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i And Tester_Testing(i) = False Then
							If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And i <= 1 Then
								Exit For
							ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And i >= 2 Then
								Exit For
							ElseIf Pick_P_Msg(0) - 2 < 0 Then
								Exit For
							EndIf
						EndIf
					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					EndIf
				Next
				If i > 3 Then
					Wait 0.2
					'一直判断
					GoTo TesterOperate1_lable1
				EndIf
				GoTo TesterOperate1_lable2
			Else
TesterOperate1_lable2:
                GoSub TesterOperate1SuckSub
'复测				
				If PickHave(1) = True And Pick_P_Msg(1) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
					Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
					Print "A，正常，复测，" + Str$(i + 1)
					MsgSend$ = "A，正常，复测，" + Str$(i + 1)
					'继续放，复测
					GoSub TesterOperate1ReleaseSub_1
				Else
					'放
					'若被测试机被选择屏蔽，需要先取走产品。
					If NeedChancel(i) = False Then
					'取放
						GoSub TesterOperate1ReleaseSub
'						If PickHave(1) Then
'							If Sw(VacuumValueB) = 0 Then
'								Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'								MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'								Pause
'								Off SuckB
'								PickHave(1) = False
'							EndIf
'						EndIf
'						If PickHave(1) Then
'							isA_NeedReJuge = True
'						EndIf
					Else
						Tester_Select(i) = False
						NeedChancel(i) = False
						
					EndIf
				EndIf
				
				
				

			EndIf
		Else
'单放
			GoSub TesterOperate1ReleaseSub
'			If PickHave(1) Then
'				If Sw(VacuumValueB) = 0 Then
'					Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'					MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'					Pause
'					Off SuckB
'					PickHave(1) = False
'				EndIf
'			EndIf
		EndIf
	Else
		If Discharge <> 0 And PickHave(1) = False Then
			For i = 0 To 3
				If Tester_Fill(i) = True And Tester_Testing(i) = False Then
					Exit For
				EndIf
			Next
			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
			If fillNum <> 0 Then
				If i > 3 Then
					'所有测试机，都在测试中都在测试中
					Print "测试机，都在测试中。前往预判位置。"
					MsgSend$ = "测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 0
					For i = 0 To 3
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
					Next
					Select i_index
						Case 0
							TargetPosition_Num = 2
							'A_1，依据TesterOperate1更改
							FinalPosition1 = A1PASS1
'							Position2NeedNeedAnotherMove = True
							
						Case 1
							TargetPosition_Num = 3
							FinalPosition1 = A2PASS1
							
						Case 2
							TargetPosition_Num = 4
							FinalPosition1 = A3PASS1
						Case 3
							TargetPosition_Num = 5
							FinalPosition1 = A4PASS3
					Send
					FinalPosition = FinalPosition1
					Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
					isInWaitPosition(i_index) = True
TesterOperate1_lable4:
					For i = 0 To 3
						If Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo TesterOperate1_lable4
					EndIf
					GoTo TesterOperate1_lable5
				Else
TesterOperate1_lable5:
	                GoSub TesterOperate1SuckSub
					
					If PickHave(1) = True And Pick_P_Msg(1) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
						Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
						Print "A，排料，复测，" + Str$(i + 1)
						MsgSend$ = "A，排料，复测，" + Str$(i + 1)
						'继续放，复测
						GoSub TesterOperate1ReleaseSub_1
					Else
						If NeedChancel(i) = True Then
							Tester_Select(i) = False
							NeedChancel(i) = False
						EndIf
					EndIf

				EndIf
			Else
			'所有治具都为空
			EndIf

		EndIf
	EndIf
	Exit Function
'取产品子函数	
TesterOperate1SuckSub:
	'取
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
'		If i = 0 Then
'			Position2NeedNeedAnotherMove = True
'		EndIf

		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
'		If isInWaitPosition(i) = False Then
'			FinalPosition = FinalPosition1
'			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			isInWaitPosition(i) = True
'		EndIf

	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2
			NeedAnotherMove(1) = True
			rearnum = 5
			
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	
	

	
	
	
	
	
	
	
	
	
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next

	If Ttarget <> Tcurrent Then
		Print "下料轴，未准备好"
		MsgSend$ = "下料轴，未准备好"
	EndIf
	Do While Ttarget <> Tcurrent
		Wait 0.02
	Loop
	
	Ttarget = i + 1
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE," + Str$(i + 1)



	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",B"
	
	PickHave(1) = PickAction(1)
	If PickHave(1) = False Then
		Wait 1
		PickHave(1) = PickAction(1)
	EndIf

	Tester_Fill(i) = False;
	
	If PickHave(1) = True Then
		If Tester_Pass(i) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4				
			Pick_P_Msg(1) = 0
			NgContinue(i) = 0
'			If Ttarget <> Tcurrent Then
'				Print "下料轴，未准备好"
'				MsgSend$ = "下料轴，未准备好"
'			EndIf
'			Do While Ttarget <> Tcurrent
'				Wait 0.02
'			Loop
'			
'			Ttarget = i + 1
'			If CmdSend$ <> "" Then
'				Print "有命令 " + CmdSend$ + " 待发送！"
'			EndIf
'			Do While CmdSend$ <> ""
'				Wait 0.1
'			Loop
'			CmdSend$ = "TMOVE," + Str$(i + 1)
'			
		Else
			

			
	
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Select i
					Case 0
		'				TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = A1PASS1
		'				Position2NeedNeedAnotherMove = True
						
						rearnum = 4
					Case 1
		'				TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
						rearnum = 5
					Case 2
		'				TargetPosition_Num = 4
						FinalPosition1 = A3PASS1
						rearnum = 14
					Case 3
		'				TargetPosition_Num = 5
						FinalPosition1 = A4PASS3
						rearnum = 15
				Send
		'		Go FinalPosition1
				TargetPosition_Num = -2
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				For j = 0 To 3
					isInWaitPosition(j) = False
				Next
				Print "测试机" + Str$(i + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(i + 1) + "，连续NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
			'复测
			If Tester_ReTestFalg(i) = 1 And ReTest_ Then
			'需要到另一台测试机测试
				Pick_P_Msg(1) = i + 2
			Else
				Pick_P_Msg(1) = 1
			EndIf
			
		EndIf
	Else
		Select i
			Case 0
'				TargetPosition_Num = 2
				'A_1，依据TesterOperate1更改
				FinalPosition1 = A1PASS1
'				Position2NeedNeedAnotherMove = True
				
				rearnum = 4
			Case 1
'				TargetPosition_Num = 3
				FinalPosition1 = A2PASS1
				
				rearnum = 5
			Case 2
'				TargetPosition_Num = 4
				FinalPosition1 = A3PASS1
				rearnum = 14
			Case 3
'				TargetPosition_Num = 5
				FinalPosition1 = A4PASS3
				rearnum = 15
		Send
'		Go FinalPosition1
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
		Print "测试机" + Str$(i + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，吸取失败"
		Pause
		Off SuckB
	EndIf
Return

TesterOperate1ReleaseSub:
'有空穴
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
'		If i = 0 Then
'			Position2NeedNeedAnotherMove = True
'		EndIf
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
'		If isInWaitPosition(i) = False Then
'			FinalPosition = FinalPosition1
'			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			isInWaitPosition(i) = True
'		EndIf
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1 +Z(2.5)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2 +Z(2.5)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3 +Z(2.5)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4 +Z(2.5)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
'	If PickHave(1) Then
'		isA_NeedReJuge = True
'	EndIf
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next

	Call ReleaseAction(0, i + 1)
	PickHave(0) = False
	Tester_Fill(i) = True;
	'退出来，发送启动命令
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
			voccumValue1 = 10
			voccumValue2 = 11
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
			voccumValue1 = 12
			voccumValue2 = 13
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
			voccumValue1 = 20
			voccumValue2 = 21
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
			voccumValue1 = 22
			voccumValue2 = 23
	Send
	TargetPosition_Num = -2
	
	
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		Pause
		Tester_Testing(i) = True
		PickAorC$(i) = "A"
	Else
		Tester_Testing(i) = True
		PickAorC$(i) = "A"
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	
	
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4	
	Select Pick_P_Msg(0)
		Case -1
			Tester_ReTestFalg(i) = 0
		Case 2
			Tester_ReTestFalg(i) = 2
		Case 3
			Tester_ReTestFalg(i) = 2
		Case 4
			Tester_ReTestFalg(i) = 2
		Case 5
			Tester_ReTestFalg(i) = 2
		
	Send
Return

TesterOperate1ReleaseSub_1:
'有空穴
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
'		If i = 0 Then
'			Position2NeedNeedAnotherMove = True
'		EndIf
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
'		If isInWaitPosition(i) = False Then
'			FinalPosition = FinalPosition1
'			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			isInWaitPosition(i) = True
'		EndIf
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(2.5)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(2.5)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(2.5)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(2.5)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(1, i + 1)
	PickHave(1) = False
	Tester_Fill(i) = True;
	'退出来，发送启动命令
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
			voccumValue1 = 10
			voccumValue2 = 11
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
			voccumValue1 = 12
			voccumValue2 = 13
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
			voccumValue1 = 20
			voccumValue2 = 21
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
			voccumValue1 = 22
			voccumValue2 = 23
	Send
	TargetPosition_Num = -2
	
	
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		Pause
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
	Else
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf



	
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next

'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4	
'	Select Pick_P_Msg(0)
'		Case -1
'			Tester_ReTestFalg(i) = 0
'		Case 2
'			Tester_ReTestFalg(i) = 2
'		Case 3
'			Tester_ReTestFalg(i) = 2
'		Case 4
'			Tester_ReTestFalg(i) = 2
'		Case 5
'			Tester_ReTestFalg(i) = 2
'		
'	Send
Return

Fend
'B抓手处理测试机程序
Function TesterOperate2
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	Boolean isA_NeedReJuge
	If PickHave(1) = True Then
		'判断是否全为选测试机
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "未选择测试机,参与测试！"
				MsgSend$ = "未选择测试机，参与测试！"
			Else
				Exit Do
			EndIf
		Loop
		'判断是否存在空穴
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg，依据TesterOperate1更改
				If Tester_Select(i) = True And Tester_Fill(i) = False And (Pick_P_Msg(1) - 2) <> i Then
					If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And i <= 1 Then
						Exit For
					ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And i >= 2 Then
						Exit For
					ElseIf Pick_P_Msg(1) - 2 < 0 Then
						Exit For
					EndIf
				EndIf
			Else
				If Tester_Select(i) = True And Tester_Fill(i) = False Then
					Exit For
				EndIf
			EndIf
		Next
		If i > 3 Then
		'都满穴 或 排料
'			selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
'			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
'			testingNum = 8 * Tester_Testing(3) + 4 * Tester_Testing(2) + 2 * Tester_Testing(1) + Tester_Testing(0)
			For i = 0 To 3
				If ReTest_ Then
					If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(1) - 2) <> i And Tester_Testing(i) = False Then
						If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And i <= 1 Then
							Exit For
						ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And i >= 2 Then
							Exit For
						ElseIf Pick_P_Msg(1) - 2 < 0 Then
							Exit For
						EndIf
					EndIf
				Else
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				EndIf
			Next
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "所有选中的测试机，都在测试中。前往预判位置。"
				MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 0
				For i = 0 To 3
'					If ReTest_ Then
'						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i Then
'							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
'								realbox = TesterTimeElapse(i)
'								i_index = i
'							EndIf
'							
'						EndIf
'					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
'					EndIf
				Next
				Select i_index
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = A1PASS1
'						Position2NeedNeedAnotherMove = True
						
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS1
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = A4PASS3
				Send
				FinalPosition = FinalPosition1
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				isInWaitPosition(i_index) = True
TesterOperate1_lable1:
				For i = 0 To 3
					If ReTest_ Then
						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(1) - 2) <> i And Tester_Testing(i) = False Then
							If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And i <= 1 Then
								Exit For
							ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And i >= 2 Then
								Exit For
							ElseIf Pick_P_Msg(1) - 2 < 0 Then
								Exit For
							EndIf
						EndIf
					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					EndIf
				Next
				If i > 3 Then
					Wait 0.2
					'一直判断
					GoTo TesterOperate1_lable1
				EndIf
				GoTo TesterOperate1_lable2
			Else
TesterOperate1_lable2:
                GoSub TesterOperate1SuckSub
'				If PickHave(1) Then
'					If Sw(VacuumValueB) = 0 Then
'						Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'						MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'						Pause
'						Off SuckB
'						PickHave(1) = False
'					EndIf
'				EndIf
'复测				
				If PickHave(0) = True And Pick_P_Msg(0) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
					Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
					Print "B，正常，复测，" + Str$(i + 1)
					MsgSend$ = "B，正常，复测，" + Str$(i + 1)
					'继续放，复测
					GoSub TesterOperate1ReleaseSub_1
'					If PickHave(1) Then
'						If Sw(VacuumValueB) = 0 Then
'							Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'							MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'							Pause
'							Off SuckB
'							PickHave(1) = False
'						EndIf
'					EndIf
				Else
					'放
					'若被测试机被选择屏蔽，需要先取走产品。
					If NeedChancel(i) = False Then
					'取放
						If PickHave(1) Then
							GoSub TesterOperate1ReleaseSub
						EndIf
						
					Else
						Tester_Select(i) = False
						NeedChancel(i) = False
						
					EndIf
				EndIf
				
				
				

			EndIf
		Else
'单放
			GoSub TesterOperate1ReleaseSub
		EndIf
	Else
		If Discharge <> 0 And PickHave(0) = False Then
			For i = 0 To 3
				If Tester_Fill(i) = True And Tester_Testing(i) = False Then
					Exit For
				EndIf
			Next
			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
			If fillNum <> 0 Then
				If i > 3 Then
					'所有测试机，都在测试中都在测试中
					Print "测试机，都在测试中。前往预判位置。"
					MsgSend$ = "测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 0
					For i = 0 To 3
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
					Next
					Select i_index
						Case 0
							TargetPosition_Num = 2
							'A_1，依据TesterOperate1更改
							FinalPosition1 = A1PASS1
'							Position2NeedNeedAnotherMove = True
							
						Case 1
							TargetPosition_Num = 3
							FinalPosition1 = A2PASS1
							
						Case 2
							TargetPosition_Num = 4
							FinalPosition1 = A3PASS1
						Case 3
							TargetPosition_Num = 5
							FinalPosition1 = A4PASS3
					Send
					FinalPosition = FinalPosition1
					Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
					isInWaitPosition(i_index) = True
TesterOperate1_lable4:
					For i = 0 To 3
						If Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo TesterOperate1_lable4
					EndIf
					GoTo TesterOperate1_lable5
				Else
TesterOperate1_lable5:
	                GoSub TesterOperate1SuckSub
'					If PickHave(1) Then
'						If Sw(VacuumValueB) = 0 Then
'							Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'							MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'							Pause
'							Off SuckB
'							PickHave(1) = False
'						EndIf
'					EndIf
					If PickHave(0) = True And Pick_P_Msg(0) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
						Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
						Print "B，排料，复测，" + Str$(i + 1)
						MsgSend$ = "B，排料，复测，" + Str$(i + 1)
						'继续放，复测
						GoSub TesterOperate1ReleaseSub_1
'						If PickHave(1) Then
'							If Sw(VacuumValueB) = 0 Then
'								Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'								MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'								Pause
'								Off SuckB
'								PickHave(1) = False
'							EndIf
'						EndIf
					Else
						If NeedChancel(i) = True Then
							Tester_Select(i) = False
							NeedChancel(i) = False
						EndIf
					EndIf

				EndIf
			Else
			'所有治具都为空
			EndIf

		EndIf
	EndIf
	Exit Function
'取产品子函数	
TesterOperate1SuckSub:
	'取
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
'		If i = 0 Then
'			Position2NeedNeedAnotherMove = True
'		EndIf

		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
'		If isInWaitPosition(i) = False Then
'			FinalPosition = FinalPosition1
'			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			isInWaitPosition(i) = True
'		EndIf

	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2
			NeedAnotherMove(1) = True
			rearnum = 5
			
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
'	If PickHave(1) Then
'		isA_NeedReJuge = True
'	EndIf


	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	
	
	If Ttarget <> Tcurrent Then
		Print "下料轴，未准备好"
		MsgSend$ = "下料轴，未准备好"
	EndIf
	Do While Ttarget <> Tcurrent
		Wait 0.02
	Loop
	Ttarget = i + 1
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE," + Str$(i + 1)
	
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",A"
	
	PickHave(0) = PickAction(0)
	If PickHave(0) = False Then
		Wait 1
		PickHave(0) = PickAction(0)
	EndIf

	Tester_Fill(i) = False;
	
	If PickHave(0) = True Then
		If Tester_Pass(i) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4				
			Pick_P_Msg(0) = 0
			NgContinue(i) = 0
'			If Ttarget <> Tcurrent Then
'				Print "下料轴，未准备好"
'				MsgSend$ = "下料轴，未准备好"
'			EndIf
'			Do While Ttarget <> Tcurrent
'				Wait 0.02
'			Loop
'			Ttarget = i + 1
'			If CmdSend$ <> "" Then
'				Print "有命令 " + CmdSend$ + " 待发送！"
'			EndIf
'			Do While CmdSend$ <> ""
'				Wait 0.1
'			Loop
'			CmdSend$ = "TMOVE," + Str$(i + 1)
			
		Else
			

			
	
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Select i
					Case 0
		'				TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = A1PASS1
		'				Position2NeedNeedAnotherMove = True
						
						rearnum = 4
					Case 1
		'				TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
						rearnum = 5
					Case 2
		'				TargetPosition_Num = 4
						FinalPosition1 = A3PASS1
						rearnum = 14
					Case 3
		'				TargetPosition_Num = 5
						FinalPosition1 = A4PASS3
						rearnum = 15
				Send
		'		Go FinalPosition1
				TargetPosition_Num = -2
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				For j = 0 To 3
					isInWaitPosition(j) = False
				Next
				Print "测试机" + Str$(i + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(i + 1) + "，连续NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
			'复测
			If Tester_ReTestFalg(i) = 1 And ReTest_ Then
				Pick_P_Msg(0) = i + 2
			Else
				Pick_P_Msg(0) = 1
			EndIf
			
		EndIf
	Else
		Select i
			Case 0
'				TargetPosition_Num = 2
				'A_1，依据TesterOperate1更改
				FinalPosition1 = A1PASS1
'				Position2NeedNeedAnotherMove = True
				
				rearnum = 4
			Case 1
'				TargetPosition_Num = 3
				FinalPosition1 = A2PASS1
				
				rearnum = 5
			Case 2
'				TargetPosition_Num = 4
				FinalPosition1 = A3PASS1
				rearnum = 14
			Case 3
'				TargetPosition_Num = 5
				FinalPosition1 = A4PASS3
				rearnum = 15
		Send
'		Go FinalPosition1
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
		Print "测试机" + Str$(i + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，吸取失败"
		Pause
		Off SuckA
	EndIf
'	If PickHave(1) Then
'		If Sw(VacuumValueB) = 0 Then
'			Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'			MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'			Pause
'			Off SuckB
'			PickHave(1) = False
'		EndIf
'	EndIf
Return

TesterOperate1ReleaseSub:
'有空穴
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
'		If i = 0 Then
'			Position2NeedNeedAnotherMove = True
'		EndIf
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
'		If isInWaitPosition(i) = False Then
'			FinalPosition = FinalPosition1
'			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			isInWaitPosition(i) = True
'		EndIf
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(2.5)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(2.5)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(2.5)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(2.5)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(1, i + 1)
	PickHave(1) = False
	Tester_Fill(i) = True;

	'退出来，发送启动命令
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
			voccumValue1 = 10
			voccumValue2 = 11
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
			voccumValue1 = 12
			voccumValue2 = 13
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
			voccumValue1 = 20
			voccumValue2 = 21
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
			voccumValue1 = 22
			voccumValue2 = 23
	Send
	TargetPosition_Num = -2
	
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		Pause
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
	Else
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4	
	Select Pick_P_Msg(1)
		Case -1
			Tester_ReTestFalg(i) = 0
		Case 2
			Tester_ReTestFalg(i) = 2
		Case 3
			Tester_ReTestFalg(i) = 2
		Case 4
			Tester_ReTestFalg(i) = 2
		Case 5
			Tester_ReTestFalg(i) = 2
		
	Send
Return

TesterOperate1ReleaseSub_1:
'有空穴
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
'		If i = 0 Then
'			Position2NeedNeedAnotherMove = True
'		EndIf
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
'		If isInWaitPosition(i) = False Then
'			FinalPosition = FinalPosition1
'			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			isInWaitPosition(i) = True
'		EndIf
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1 +Z(2.5)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2 +Z(2.5)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3 +Z(2.5)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4 +Z(2.5)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(0, i + 1)
	PickHave(0) = False
	Tester_Fill(i) = True;
	'退出来，发送启动命令

	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A1PASS1
			rearnum = 4
			voccumValue1 = 10
			voccumValue2 = 11
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
			voccumValue1 = 12
			voccumValue2 = 13
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS1
			rearnum = 14
			voccumValue1 = 20
			voccumValue2 = 21
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
			voccumValue1 = 22
			voccumValue2 = 23
	Send
	TargetPosition_Num = -2
	

'	If PickHave(1) Then
'		If Sw(VacuumValueB) = 0 Then
'			Print "测试工位" + Str$(i + 1) + "，B爪手掉料"
'			MsgSend$ = "测试工位" + Str$(i + 1) + "，B爪手掉料"
'			Pause
'			Off SuckB
'			PickHave(1) = False
'		EndIf
'	EndIf
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		Pause
		
		Tester_Testing(i) = True
		PickAorC$(i) = "A"
	Else
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Tester_Testing(i) = True
		PickAorC$(i) = "A"
	EndIf

	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4	
'	Select Pick_P_Msg(0)
'		Case -1
'			Tester_ReTestFalg(i) = 0
'		Case 2
'			Tester_ReTestFalg(i) = 2
'		Case 3
'			Tester_ReTestFalg(i) = 2
'		Case 4
'			Tester_ReTestFalg(i) = 2
'		Case 5
'			Tester_ReTestFalg(i) = 2
'		
'	Send
Return

Fend
'C抓手处理测试机程序
Function TesterOperate3
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(2) = True Then
		'判断是否全为选测试机
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "未选择测试机,参与测试！"
				MsgSend$ = "未选择测试机，参与测试！"
			Else
				Exit Do
			EndIf
		Loop
		'判断是否存在空穴
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg，依据TesterOperate1更改
				If Tester_Select(i) = True And Tester_Fill(i) = False And (Pick_P_Msg(0) - 2) <> i Then
					Exit For
				EndIf
			Else
				If Tester_Select(i) = True And Tester_Fill(i) = False Then
					Exit For
				EndIf
			EndIf
		Next
		If i > 3 Then
		'都满穴 或 排料
'			selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
'			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
'			testingNum = 8 * Tester_Testing(3) + 4 * Tester_Testing(2) + 2 * Tester_Testing(1) + Tester_Testing(0)
			For i = 0 To 3
				If ReTest_ Then
					If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i And Tester_Testing(i) = False Then
						Exit For
					EndIf
				Else
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				EndIf
			Next
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "所有选中的测试机，都在测试中。前往预判位置。"
				MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 0
				For i = 0 To 3
					If ReTest_ Then
						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 25 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
							
						EndIf
					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 25 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
					EndIf
				Next
				Select i_index
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = D_1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = D_2
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = D_3
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = D_4
				Send
				FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
TesterOperate3_lable1:
				For i = 0 To 3
					If ReTest_ Then
						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					EndIf
				Next
				If i > 3 Then
					Wait 0.2
					'一直判断
					GoTo TesterOperate3_lable1
				EndIf
				GoTo TesterOperate3_lable2
			Else
TesterOperate3_lable2:
                GoSub TesterOperate3SuckSub
				
				'放
				'若被测试机被选择屏蔽，需要先取走产品。
				If NeedChancel(i) = False Then
				'取放
					GoSub TesterOperate3ReleaseSub
				Else
					Tester_Select(i) = False
					NeedChancel(i) = False
					Go FinalPosition +X(10)
				EndIf
			EndIf
		Else
'单放
			GoSub TesterOperate3ReleaseSub
		EndIf
	Else
		If Discharge <> 0 Then
			For i = 0 To 3
				If Tester_Fill(i) = True And Tester_Testing(i) = False Then
					Exit For
				EndIf
			Next
			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
			If fillNum <> 0 Then
				If i > 3 Then
					'所有测试机，都在测试中都在测试中
					Print "测试机，都在测试中。前往预判位置。"
					MsgSend$ = "测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 0
					For i = 0 To 3
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 25 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
					Next
					Select i_index
						Case 0
							TargetPosition_Num = 2
							'A_1，依据TesterOperate1更改
							FinalPosition1 = C_1
						Case 1
							TargetPosition_Num = 3
							FinalPosition1 = C_2
						Case 2
							TargetPosition_Num = 4
							FinalPosition1 = C_3
						Case 3
							TargetPosition_Num = 5
							FinalPosition1 = C_4
					Send
					FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
					Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
TesterOperate3_lable4:
					For i = 0 To 3
						If Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo TesterOperate3_lable4
					EndIf
					GoTo TesterOperate3_lable5
				Else
TesterOperate3_lable5:
	                GoSub TesterOperate3SuckSub
					Go FinalPosition +X(10)

					If NeedChancel(i) = True Then
						Tester_Select(i) = False
						NeedChancel(i) = False
					EndIf
				EndIf
			Else
			'所有治具都为空
			EndIf

		EndIf
	EndIf
'取产品子函数	
TesterOperate3SuckSub:
	'取
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = D_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = D_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = D_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = D_4
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		FinalPosition = FinalPosition1 + XY(30, 0, 0, 0)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",D"
	
	PickHave(3) = PickAction(3)
	Tester_Fill(i) = False;
	
	If PickHave(3) = True Then
		If Tester_Pass(i) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4					
			Pick_P_Msg(3) = 0
			NgContinue(i) = 0
		Else
			
			If ReTest_ = True Then
				If Tester_ReTestFalg(i) = True Then
					Pick_P_Msg(3) = 1
				Else
					Pick_P_Msg(3) = 2 + i
				EndIf
			Else
				Pick_P_Msg(3) = 1
			EndIf
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Print "测试机" + Str$(i + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(i + 1) + "，连续NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
		EndIf
	Else
		Go FinalPosition +X(10)
		Print "测试机" + Str$(i + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，吸取失败"
		Pause
	EndIf
Return

TesterOperate3ReleaseSub:
'有空穴
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = C_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = C_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = C_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = C_4
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(2, i + 1)
	Tester_Fill(i) = True;
	If ReTest_ Then
		If Pick_P_Msg(2) = -1 Then
			Tester_ReTestFalg(i) = False
		Else
			Tester_ReTestFalg(i) = True
		EndIf
	Else
		Tester_ReTestFalg(i) = False
	EndIf
	'退出来，发送启动命令
	Go FinalPosition +X(20)
	Tester_Testing(i) = True
	PickAorC$(i) = "C"
Return

Fend
'D抓手处理测试机程序
Function TesterOperate4
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(3) = True Then
		'判断是否全为选测试机
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "未选择测试机,参与测试！"
				MsgSend$ = "未选择测试机，参与测试！"
			Else
				Exit Do
			EndIf
		Loop
		'判断是否存在空穴
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg，依据TesterOperate1更改
				If Tester_Select(i) = True And Tester_Fill(i) = False And (Pick_P_Msg(0) - 2) <> i Then
					Exit For
				EndIf
			Else
				If Tester_Select(i) = True And Tester_Fill(i) = False Then
					Exit For
				EndIf
			EndIf
		Next
		If i > 3 Then
		'都满穴 或 排料
'			selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
'			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
'			testingNum = 8 * Tester_Testing(3) + 4 * Tester_Testing(2) + 2 * Tester_Testing(1) + Tester_Testing(0)
			For i = 0 To 3
				If ReTest_ Then
					If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i And Tester_Testing(i) = False Then
						Exit For
					EndIf
				Else
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				EndIf
			Next
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "所有选中的测试机，都在测试中。前往预判位置。"
				MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 0
				For i = 0 To 3
					If ReTest_ Then
						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 25 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
							
						EndIf
					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 25 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
					EndIf
				Next
				Select i_index
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = C_1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = C_2
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = C_3
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = C_4
				Send
				FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
TesterOperate4_lable1:
				For i = 0 To 3
					If ReTest_ Then
						If Tester_Select(i) = True And Tester_Fill(i) = True And (Pick_P_Msg(0) - 2) <> i And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Else
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					EndIf
				Next
				If i > 3 Then
					Wait 0.2
					'一直判断
					GoTo TesterOperate4_lable1
				EndIf
				GoTo TesterOperate4_lable2
			Else
TesterOperate4_lable2:
                GoSub TesterOperate4SuckSub
				
				'放
				'若被测试机被选择屏蔽，需要先取走产品。
				If NeedChancel(i) = False Then
				'取放
					GoSub TesterOperate4ReleaseSub
				Else
					Tester_Select(i) = False
					NeedChancel(i) = False
					Go FinalPosition +X(10)
				EndIf
			EndIf
		Else
'单放
			GoSub TesterOperate4ReleaseSub
		EndIf
	Else
		If Discharge <> 0 Then
			For i = 0 To 3
				If Tester_Fill(i) = True And Tester_Testing(i) = False Then
					Exit For
				EndIf
			Next
			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
			If fillNum <> 0 Then
				If i > 3 Then
					'所有测试机，都在测试中都在测试中
					Print "测试机，都在测试中。前往预判位置。"
					MsgSend$ = "测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 0
					For i = 0 To 3
						If Tester_Select(i) = True And Tester_Fill(i) = True Then
							If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 25 Then
								realbox = TesterTimeElapse(i)
								i_index = i
							EndIf
						EndIf
					Next
					Select i_index
						Case 0
							TargetPosition_Num = 2
							'A_1，依据TesterOperate1更改
							FinalPosition1 = D_1
						Case 1
							TargetPosition_Num = 3
							FinalPosition1 = D_2
						Case 2
							TargetPosition_Num = 4
							FinalPosition1 = D_3
						Case 3
							TargetPosition_Num = 5
							FinalPosition1 = D_4
					Send
					FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
					Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
TesterOperate4_lable4:
					For i = 0 To 3
						If Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo TesterOperate4_lable4
					EndIf
					GoTo TesterOperate4_lable5
				Else
TesterOperate4_lable5:
	                GoSub TesterOperate4SuckSub
					Go FinalPosition +X(10)

					If NeedChancel(i) = True Then
						Tester_Select(i) = False
						NeedChancel(i) = False
					EndIf
				EndIf
			Else
			'所有治具都为空
			EndIf

		EndIf
	EndIf
'取产品子函数	
TesterOperate4SuckSub:
	'取
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = C_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = C_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = C_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = C_4
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		FinalPosition = FinalPosition1 + XY(30, 0, 0, 0)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",C"
	
	PickHave(2) = PickAction(2)
	Tester_Fill(i) = False;
	
	If PickHave(2) = True Then
		If Tester_Pass(i) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4					
			Pick_P_Msg(2) = 0
			NgContinue(i) = 0
		Else
			
			If ReTest_ = True Then
				If Tester_ReTestFalg(i) = True Then
					Pick_P_Msg(2) = 1
				Else
					Pick_P_Msg(2) = 2 + i
				EndIf
			Else
				Pick_P_Msg(2) = 1
			EndIf
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Print "测试机" + Str$(i + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(i + 1) + "，连续NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
		EndIf
	Else
		Go FinalPosition +X(10)
		Print "测试机" + Str$(i + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，吸取失败"
		Pause
	EndIf
Return

TesterOperate4ReleaseSub:
'有空穴
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = D_1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = D_2
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = D_3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = D_4
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
		FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(3, i + 1)
	Tester_Fill(i) = True;
	If ReTest_ Then
		If Pick_P_Msg(3) = -1 Then
			Tester_ReTestFalg(i) = False
		Else
			Tester_ReTestFalg(i) = True
		EndIf
	Else
		Tester_ReTestFalg(i) = False
	EndIf
	'退出来，发送启动命令
	Go FinalPosition +X(20)
	Tester_Testing(i) = True
	PickAorC$(i) = "D"
Return

Fend
'num
'0:A
'1:B
'2:C
'3:D
Function UnloadOperate(num As Integer)
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4	

'Pallet 0:A Pass Cui
'Pallet 1:B Pass Cui
'Pallet 2:C Pass Cui
'Pallet 3:D Pass Cui

'Pallet 4:A Ng+ Cui
'Pallet 5:B Ng+ Cui
'Pallet 6:C Ng+ Cui
'Pallet 7:D Ng+ Cui

'Pallet 8:A Ng- Cui
'Pallet 9:B Ng- Cui
'Pallet 10:C Ng- Cui
'Pallet 11:D Ng- Cui
	If PickHave(num) = True Then
		If Pick_P_Msg(num) = 0 Then
			GoSub UnloadOperate_Pass
		ElseIf Pick_P_Msg(num) = 1 Then
			GoSub UnloadOperate_Ng
		EndIf
	EndIf
	Exit Function
	
UnloadOperate_Pass:

	If Tcurrent <> Ttarget Then
		
		Print "下料轴，未准备好"
		MsgSend$ = "下料轴，未准备好"
		
	EndIf
	Do While Ttarget <> Tcurrent
		Wait 0.02
	Loop
	TargetPosition_Num = -2
	If num = 1 Then
		FinalPosition = P(30 + NowFlexIndex - 1)
	Else
		FinalPosition = P(34 + NowFlexIndex - 1)
	EndIf
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Go FinalPosition
	Call ReleaseAction(num, -1)
	PickHave(num) = False
	
	Ttarget = 5
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "ULOAD"
	Go ChangeHandL
Return

UnloadOperate_Ng:
	
	TargetPosition_Num = 6

	
	If num = 1 Then
		FinalPosition = Pallet(5, NgTrayPalletNum)
	Else
		FinalPosition = Pallet(10, NgTrayPalletNum)
	EndIf
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(num, -1)
	PickHave(num) = False
	NgTrayPalletNum = NgTrayPalletNum + 1
	If NgTrayPalletNum > 14 Then
		Go P(349 + PassStepNum)
		Print "Ng下料盘，换料"
		MsgSend$ = "Ng下料盘，换料"
		Pause
		NgTrayPalletNum = 1
	EndIf
Return

Fend
Function ScanBarcodeOpetateP3(picksting$ As String)
	
    Boolean re_scan
    re_scan = False
	TargetPosition_Num = 1
	ScanResult = 0
	Accel 50, 50
	Go ScanPositionP3L
	Accel 90, 90
	
	
	
ScanBarcodeOpetateP3label:
	
	Wait 0.2
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "ScanP3," + picksting$
	TmReset 7
	Do While ScanResult = 0 And Tmr(7) < 10
		Wait 0.2
		Print "等待扫码结果 " + Str$(Tmr(7))
	Loop
	
	If ScanResult <> 1 And re_scan = False Then
		re_scan = True
		Go Here +X(5)
		Go Here +Y(5)
		ScanResult = 0
		Wait 0.5
		GoTo ScanBarcodeOpetateP3label
		
	EndIf
	
	
	
	
	Go ChangeHandL


	ScanBarcodeOpetateP3 = ScanResult
Fend
Function ScanBarcodeOpetate(num As Integer, picksting$ As String)

	TargetPosition_Num = 1
	ScanResult = 0
'	If CmdSend$ <> "" Then
'		Print "有命令 " + CmdSend$ + " 待发送！"
'	EndIf
'	Do While CmdSend$ <> ""
'		Wait 0.1
'	Loop
'	CmdSend$ = "TakePhoto"
	If Hand = 1 Then
		FinalPosition = P(4 + num)
	Else
		FinalPosition = P(1 + num)
	EndIf
	
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Wait 0.2
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "Scan," + picksting$
	TmReset 7
	Do While ScanResult = 0 And Tmr(7) < 10
		Wait 0.2
		Print "等待扫码结果 " + Str$(Tmr(7))
	Loop
	If Hand = 1 Then
		Go ChangeHandL /R
	Else
		Go ChangeHandL /L
	EndIf
	If ScanResult <> 1 Then
		ScanBarcodeOpetate = False
	Else
		ScanBarcodeOpetate = True
	EndIf
Fend
'回初始位置
Function HomeReturnAction
	Motor Off
	Motor On
	Power Low
	Weight 1
	LimZ -24
	Speed 50
	Boolean HomeSuccessFlage

'	SFree 1, 2
'	Pulse 378192, -313239, -77072, 93736
'	SLock 1, 2
'	Pulse 378192, -313239, -77072, 93736
'	SFree 1
'	SLock 2
'	Pulse 378192, -313239, -77072, 93736
'	SLock 1
'	Pulse 378192, -313239, -77072, 93736
	Go Here :Z(-24)
	SFree 1, 2, 3, 4
	Do
		
		
		HomeSuccessFlage = True
'		If Hand(Here) = 2 Then
'			
'		Else
'			HomeSuccessFlage = False
'			Print "请将机械手调整为左手姿势"
'		EndIf
		If CX(Here) > -50 And CX(Here) < 0 Then
		
		Else
			HomeSuccessFlage = False
			Print "X方向偏差超限"
			MsgSend$ = "X方向偏差超限"
		EndIf
		If CY(Here) > 150 And CY(Here) < 350 Then
		
		Else
			HomeSuccessFlage = False
			Print "Y方向偏差超限"
			MsgSend$ = "Y方向偏差超限"
		EndIf
		
		If HomeSuccessFlage Then
			Print "初始位置符合要求"
			MsgSend$ = "初始位置符合要求"
			Exit Do
		Else

			Pause
		EndIf

	Loop
	SLock 1, 2, 3, 4
	Go Here :Y(225)
	Go Here :U(102)
	
	Go ChangeHandL
	
	
'	Pause
	ResetCMDComplete = 0
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "ResetCMD"
	Wait ResetCMDComplete = 1
	Fcurrent = -1
	Ftarget = 5
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "FMOVE,5"
	Wait Fcurrent = 5
	Tcurrent = -1
	Ttarget = 2
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE,2"
	Wait Tcurrent = 2


	Print "Home Return Compelet"
	MsgSend$ = "Home Return Compelet"
	Off DangerOut
	
	Power High
	Speed 95
	Accel 100, 100

	CurPosition_Num = 5
	NowFlexIndex = 4
Fend
'路径规划
'firstPosition 目标位置
'secendPosition 当前位置
Function RoutePlanThenExe(firstPosition As Integer, secendPosition As Integer)
'TargetHand	
'1 R
'2 L
	Integer TargetHand, i, j, deltaU
	Int32 SpBox
	LimZ -24
	
	If PassStepNum > 0 And firstPosition <> secendPosition Then
		For i = 0 To PassStepNum - 1
			Pass P(349 + PassStepNum - i)
		Next
		PassStepNum = 0
	EndIf
	
	If firstPosition = secendPosition Then
		Select secendPosition
			Case 1
				Wait Sw(DangerIn) = 0
				deltaU = CU(Here) - CU(FinalPosition)
				If deltaU > 90 Or deltaU < -90 Then
					Pass ScanPositionP3L
				EndIf
			Case 2
				If isInWaitPosition(0) Then
					RoutePassP3 = A1PASS2
					PassStepNum = PassStepNum + 1
					Pass A1PASS2
					RoutePassP4 = B_1 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_1 +Z(5)
					
				EndIf
			Case 3
				If isInWaitPosition(1) Then
					RoutePassP3 = A2PASS2
					PassStepNum = PassStepNum + 1
					Pass A2PASS2
					
					RoutePassP4 = B_2 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_2 +Z(5)
				EndIf
			Case 4
				If isInWaitPosition(2) Then
					RoutePassP3 = A3PASS2
					PassStepNum = PassStepNum + 1
					Pass A3PASS2
					
					RoutePassP4 = B_3 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_3 +Z(5)
				EndIf
			Case 5
				If isInWaitPosition(3) Then
					RoutePassP5 = A4PASS4
					PassStepNum = PassStepNum + 1
					Pass A4PASS4
					
					RoutePassP6 = B_4 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_4 +Z(5)
					
				EndIf
		Send
'		If Position2NeedNeedAnotherMove = True And secendPosition = 2 Then
'
'			Pass A1PASS2
'
'			Pass B_1
'			Position2NeedNeedAnotherMove = False
'		EndIf
		Accel 50, 50
		Go FinalPosition
		Accel 100, 100
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next

	Else
		PassStepNum = 0
		Select secendPosition
			Case -2
'				Go FinalPosition
				
			Case 1
				Ftarget = 1
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,1"
				Wait Fcurrent = 1
				Wait Sw(DangerIn) = 0
				deltaU = CU(Here) - CU(FinalPosition)
				If deltaU > 90 Or deltaU < -90 Then
					Pass ScanPositionP3L
				EndIf
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
			Case 2
				Wait Sw(DangerIn) = 0
				On DangerOut
				Ftarget = 2
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,2"
				Wait Fcurrent = 2
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A1PASS1
				PassStepNum = PassStepNum + 1
				
				
				
				Pass A1PASS1
				If NeedAnotherMove(0) Then
					RoutePassP3 = A1PASS2
					PassStepNum = PassStepNum + 1
					Pass A1PASS2
					RoutePassP4 = B_1 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_1 +Z(5)
					NeedAnotherMove(0) = False
				EndIf
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
'				Position2NeedNeedAnotherMove = False
			Case 3
				Ftarget = 3
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,3"
				Wait Fcurrent = 3
				Off DangerOut
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A2PASS1
				PassStepNum = PassStepNum + 1
				
				Pass A2PASS1
				If NeedAnotherMove(1) Then
					RoutePassP3 = A2PASS2
					PassStepNum = PassStepNum + 1
					Pass A2PASS2
					
					RoutePassP4 = B_2 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_2 +Z(5)
					NeedAnotherMove(1) = False
				EndIf
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
			Case 4
				Ftarget = 4
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,4"
				Wait Fcurrent = 4
				Off DangerOut
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A3PASS1
				PassStepNum = PassStepNum + 1
				Pass A3PASS1
				

				
				
				If NeedAnotherMove(2) Then
					RoutePassP3 = A3PASS2
					PassStepNum = PassStepNum + 1
					Pass A3PASS2
					
					RoutePassP4 = B_3 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_3 +Z(5)
					NeedAnotherMove(2) = False
				EndIf
				
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
			Case 5
				Ftarget = 5
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,5"
				Wait Fcurrent = 5
				Off DangerOut
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A4PASS1
				PassStepNum = PassStepNum + 1
				Pass A4PASS1
				
				RoutePassP3 = A4PASS2
				PassStepNum = PassStepNum + 1
				Pass A4PASS2
				
				RoutePassP4 = A4PASS3
				PassStepNum = PassStepNum + 1
				Pass A4PASS3
				
				If NeedAnotherMove(3) Then
					RoutePassP5 = A4PASS4
					PassStepNum = PassStepNum + 1
					Pass A4PASS4
					
					RoutePassP6 = B_4 +Z(5)
					PassStepNum = PassStepNum + 1
					Pass B_4 +Z(5)
					NeedAnotherMove(3) = False
				EndIf
				
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
			Case 6
				Ftarget = 6
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,6"
				Wait Fcurrent = 6
				Off DangerOut
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = NCuip1
				PassStepNum = PassStepNum + 1
				Pass NCuip1
				
				RoutePassP3 = NCuip2
				PassStepNum = PassStepNum + 1
				Pass NCuip2
				
				RoutePassP4 = NCuip3
				PassStepNum = PassStepNum + 1
				Pass NCuip3
				
				
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
				
			Case 7
				Ftarget = 7
				Fcurrent = -1
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "FMOVE,7"
				Wait Fcurrent = 7
				Off DangerOut

	
		
			
		Send

	EndIf
	CurPosition_Num = secendPosition
	For i = 0 To 3
		NeedAnotherMove(i) = False
	Next
	If CurPosition_Num > 1 And CurPosition_Num < 6 Then
		NowFlexIndex = CurPosition_Num - 1
	EndIf
	
	


Fend
'吸取动作
'num:吸嘴索引
Function PickAction(num As Integer) As Boolean
'0 : A
'1 : B
'2 : C
'3 : D	
	Integer sucknum, blownum, valvenum, vacuumnum
	Select num
		Case 0
			valvenum = 12
			sucknum = 0
			blownum = 1
			vacuumnum = 0
		Case 1
			valvenum = 13
			sucknum = 2
			blownum = 3
			vacuumnum = 1
		Case 2
			valvenum = 14
			sucknum = 4
			blownum = 5
			vacuumnum = 2
		Case 3
			valvenum = 15
			sucknum = 6
			blownum = 7
			vacuumnum = 3
	Send
	If needreleaseadjust Then
		Off AdjustValve
		Wait 0.05
	EndIf
	Off blownum; On valvenum; On sucknum
	Wait Sw(vacuumnum), 0.3
		
'	If needreleaseadjust Then
'		Off AdjustValve
'		Wait 0.1
'	EndIf
	Off valvenum
	Wait 0.15

	If Sw(vacuumnum) = 0 Then
		If needreleaseadjust Then
			On AdjustValve
			Wait 0.1
		EndIf
		PickAction = False
	Else
		PickAction = True
		Select num
			Case 0
				Xqt PickhaveMoniterA
			Case 1
				Xqt PickhaveMoniterB
		Send
		
	EndIf
'	PickAction = True
Fend
Function PickhaveMoniterA
	Boolean StartCount
	StartCount = False
	Do
		Wait 0.2
		If PickHave(0) Then
			If Sw(VacuumValueA) = 0 Then
				If StartCount = False Then
					TmReset 8
					StartCount = True
				EndIf
				If Tmr(8) > 0.25 Then
					Print "A爪手掉料"
					MsgSend$ = "A爪手掉料"
					Pause
					Off SuckA
					PickHave(0) = False
				EndIf
			Else
				StartCount = False
			EndIf
		Else
			Exit Do
		EndIf
	Loop
Fend
Function PickhaveMoniterB
	Boolean StartCount
	StartCount = False
	Do
		Wait 0.2
		If PickHave(1) Then
			If Sw(VacuumValueB) = 0 Then
				If StartCount = False Then
					TmReset 9
					StartCount = True
				EndIf
				If Tmr(9) > 0.25 Then
					Print "B爪手掉料"
					MsgSend$ = "B爪手掉料"
					Pause
					Off SuckB
					PickHave(1) = False
				EndIf
			Else
				StartCount = False
			EndIf
		Else
			Exit Do
		EndIf
	Loop
Fend
Function CleanBlowAction(num As Integer, Flexnum As Integer)
'0 : A
'1 : B
'2 : C
'3 : D
	Integer sucknum, blownum, valvenum, vacuumnum, i
	Select num
		Case 0
			valvenum = 12
			sucknum = 0
			blownum = 1
			vacuumnum = 0
		Case 1
			valvenum = 13
			sucknum = 2
			blownum = 3
			vacuumnum = 1
		Case 2
			valvenum = 14
			sucknum = 4
			blownum = 5
			vacuumnum = 2
		Case 3
			valvenum = 15
			sucknum = 6
			blownum = 7
			vacuumnum = 3
	Send
	
 	On valvenum
	For i = 0 To 2
		On blownum; Off sucknum
	 	Wait 0.8
	 	Off blownum
	 	Wait 0.4
	Next
	Off valvenum
	Wait 0.5
Fend
'释放动作
'num:吸嘴索引
'Flexnum:治具索引
Function ReleaseAction(num As Integer, Flexnum As Integer) '放料
'0 : A
'1 : B
'2 : C
'3 : D
	Integer sucknum, blownum, valvenum, vacuumnum
	Integer FlexVoccum1, FlexVoccum2
	Select num
		Case 0
			valvenum = 12
			sucknum = 0
			blownum = 1
			vacuumnum = 0
		Case 1
			valvenum = 13
			sucknum = 2
			blownum = 3
			vacuumnum = 1
		Case 2
			valvenum = 14
			sucknum = 4
			blownum = 5
			vacuumnum = 2
		Case 3
			valvenum = 15
			sucknum = 6
			blownum = 7
			vacuumnum = 3
	Send
	

	
'	If Flexnum <> -1 Then
'		Go Here +Z(2.5)
'	EndIf

	
    Wait 0.2
 	On valvenum
 	Wait 0.3
	On blownum; Off sucknum

	PickHave(num) = False
	
	
	
 	Wait 0.2
	Select Flexnum
		Case 1
			On AL_Suck; FlexVoccum1 = 10; FlexVoccum2 = 11
		Case 2
			On AR_Suck; FlexVoccum1 = 12; FlexVoccum2 = 13
		Case 3
			On BL_Suck; FlexVoccum1 = 20; FlexVoccum2 = 21
		Case 4
			On BR_Suck; FlexVoccum1 = 22; FlexVoccum2 = 23
	Send

	
 	If Flexnum <> -1 Then
 		Off valvenum
 		Wait 0.2
 	EndIf
	


	
 	If Flexnum <> -1 Then
 	    Go Here -Z(2.5)
 		On valvenum
 		Wait 0.1  '等待气缸下压
 		If Sw(FlexVoccum1) = 0 Or Sw(FlexVoccum2) = 0 Then
 			CheckFlexVoccum(Flexnum - 1) = True
 		Else
 			CheckFlexVoccum(Flexnum - 1) = False
 		EndIf

 	EndIf
 	
 	Off valvenum; Off blownum '抬气缸，关吹气
	Wait 0.3
	If Flexnum <> -1 Then
		If CheckFlexVoccum(Flexnum - 1) = True Then
			Wait 0.45
		EndIf
		
	EndIf
	
Fend
'吸取失败，吹动作
'num:吸嘴索引
Function BlowSuckFail(num As Integer)
	Integer sucknum, blownum, valvenum, vacuumnum
	Select num
		Case 0
			valvenum = 12
			sucknum = 0
			blownum = 1
			vacuumnum = 0
		Case 1
			valvenum = 13
			sucknum = 2
			blownum = 3
			vacuumnum = 1
		Case 2
			valvenum = 14
			sucknum = 4
			blownum = 5
			vacuumnum = 2
		Case 3
			valvenum = 15
			sucknum = 6
			blownum = 7
			vacuumnum = 3
	Send
	On valvenum
	Wait 0.3
	Off sucknum; On blownum
	Wait 0.3
	Off blownum; Off valvenum
	Wait 0.3
Fend
'后台任务
Function bgmain
'	Call InitParameter(0)
	Xqt TcpIpCmdRev
	Xqt TcpIpCmdSend
	Xqt TcpIpMsgSend
Fend
'接收上位机的命令
Function TcpIpCmdRev
	Integer chknet1, errTask, i;
	OpenNet #201 As Server
	Print "端口201打开"
	WaitNet #201
	Print "端口201连接"
	Do
		OnErr GoTo NetErr
		chknet1 = ChkNet(201)
		If chknet1 >= 0 Then
			Input #201, CmdRev$
			Print "CmdRev$收到： " + CmdRev$
			CmdRevStr$(0) = ""
			StringSplit(CmdRev$, ";")
			Select CmdRevStr$(0)
				Case "Select"
					For i = 0 To 3
'						If CmdRevStr$(i + 1) = "1" Then
'							Tester_Select(i) = True
'							NeedChancel(i) = False
'						Else
'							If Tester_Fill(i) = False Then
'								Tester_Select(i) = False
'							Else
'								If Tester_Select(i) Then
'									NeedChancel(i) = True
'								EndIf
'							EndIf
'
'							
'						EndIf
						If CmdRevStr$(1) = "1" Then
							Tester_Select(0) = True; Tester_Select(1) = True
							NeedChancel(0) = False; NeedChancel(1) = False
						Else
							If Tester_Fill(0) = False Then
								Tester_Select(0) = False
							Else
								If Tester_Select(0) Then
									NeedChancel(0) = True
								EndIf
							EndIf
							If Tester_Fill(1) = False Then
								Tester_Select(1) = False
							Else
								If Tester_Select(1) Then
									NeedChancel(1) = True
								EndIf
							EndIf
						EndIf
						If CmdRevStr$(3) = "1" Then
							Tester_Select(2) = True; Tester_Select(3) = True
							NeedChancel(2) = False; NeedChancel(3) = False
						Else
							If Tester_Fill(2) = False Then
								Tester_Select(2) = False
							Else
								If Tester_Select(2) Then
									NeedChancel(2) = True
								EndIf
							EndIf
							If Tester_Fill(3) = False Then
								Tester_Select(3) = False
							Else
								If Tester_Select(3) Then
									NeedChancel(3) = True
								EndIf
							EndIf
						EndIf
					Next
				Case "NGContinueNum"
					NgContinueNum = Val(CmdRevStr$(1))
				Case "BarcodeMode"
					Select CmdRevStr$(1)
						Case "True"
							BarcodeMode = 0
						Case "False"
							BarcodeMode = 1
					Send
				Case "AABReTest"
					Select CmdRevStr$(1)
						Case "True"
							ReTest_ = 1
						Case "False"
							ReTest_ = 0
					Send
				Case "SingleTestModeStageNum"
					LoopTestFlexIndex = Val(CmdRevStr$(1)) - 1
				Case "InitPar"
					Call InitAction
				Case "Clear"
					Call ClearAction
				Case "ScanResult"
					Select CmdRevStr$(2)
						Case "A"
							Select CmdRevStr$(1)
								Case "Pass"
									ScanResult = 1
								Case "Ng"
									ScanResult = 2
								Case "TimeOut"
									ScanResult = 3
								Case "ShikeNg"
									ScanResult = 4
							Send
'						Case "C"
'							Select CmdRevStr$(1)
'								Case "Pass"
'									ScanResultC = 1
'								Case "Ng"
'									ScanResultC = 2
'								Case "TimeOut"
'									ScanResultC = 3
'							Send
					Send
				Case "TestResult"
					Select CmdRevStr$(2)
						Case "1"
							Select CmdRevStr$(1)
								Case "Pass"
									Tester_Pass(0) = 1
								Case "Ng"
									Tester_Ng(0) = 1
								Case "TimeOut"
									Tester_Timeout(0) = 1
							Send
						Case "2"
							Select CmdRevStr$(1)
								Case "Pass"
									Tester_Pass(1) = 1
								Case "Ng"
									Tester_Ng(1) = 1
								Case "TimeOut"
									Tester_Timeout(1) = 1
							Send
						Case "3"
							Select CmdRevStr$(1)
								Case "Pass"
									Tester_Pass(2) = 1
								Case "Ng"
									Tester_Ng(2) = 1
								Case "TimeOut"
									Tester_Timeout(2) = 1
							Send
						Case "4"
							Select CmdRevStr$(1)
								Case "Pass"
									Tester_Pass(3) = 1
								Case "Ng"
									Tester_Ng(3) = 1
								Case "TimeOut"
									Tester_Timeout(3) = 1
							Send
					Send
					Case "FeedFill"
						For i = 0 To 5
							If CmdRevStr$(i + 1) = "1" Then
								PreFeedFill(i) = True
							Else
								PreFeedFill(i) = False
							EndIf
						Next
				Case "Discharge"
					Discharge = 1
					On Discharing, Forced
				Case "TestersCleanAction"
					If Not CleanActionFlag Then
						Discharge = 1
						On Discharing, Forced
						NeedCleanAction = True
					EndIf
				Case "XQTAction"
					If isXqtting = False Then
						Select CmdRevStr$(1)
							Case "1"
								Xqt XQTAction(1), NoEmgAbort
							Case "2"
								Xqt XQTAction(2), NoEmgAbort
							Case "3"
								Xqt XQTAction(3), NoEmgAbort
						Send
					EndIf
				Case "FMOVE"
					
					Fcurrent = Val(CmdRevStr$(1))
				Case "TMOVE"
					
					Tcurrent = Val(CmdRevStr$(1))
				Case "ULOAD"
					Tcurrent = 5
				Case "ResetCMD"
					ResetCMDComplete = 1
			Send
			CmdRev$ = ""
		Else
			CloseNet #201
			Print "端口201关闭"
			Wait 0.1
			OpenNet #201 As Server
			Print "端口201重新打开"
			WaitNet #201
			Print "端口201重新连接"
		EndIf
	Loop
	 
	NetErr:
		Print "The Error code is ", Err
		Print "The Error Message is ", ErrMsg$(Err, LANGID_SIMPLIFIED_CHINESE)
		errTask = Ert
		If errTask > 0 Then
			Print "Task number in which error occurred is ", errTask
			Print "The line where the error occurred is Line ", Erl(errTask)
			If Era(errTask) > 0 Then
				Print "Joint which caused the error is ", Era(errTask)
			EndIf
		EndIf
		EResume Next
Fend
'发送命令到上位机
Function TcpIpCmdSend
	Integer chknet2, errTask
	OpenNet #202 As Server
	Print "端口202打开"
	WaitNet #202
	Print "端口202连接"
	Do
		OnErr GoTo NetErr
		chknet2 = ChkNet(202)
		If chknet2 >= 0 Then
			If CmdSend$ <> "" Then
				Print #202, CmdSend$
				Print "CmdSend$： " + CmdSend$
				CmdSend$ = ""
			EndIf
		Else
			CloseNet #202
			Print "端口202关闭"
			Wait 0.1
			OpenNet #202 As Server
			Print "端口202重新打开"
			WaitNet #202
			Print "端口202重新连接"
		EndIf
	Loop
	 
	NetErr:
		Print "The Error code is ", Err
		Print "The Error Message is ", ErrMsg$(Err, LANGID_SIMPLIFIED_CHINESE)
		errTask = Ert
		If errTask > 0 Then
			Print "Task number in which error occurred is ", errTask
			Print "The line where the error occurred is Line ", Erl(errTask)
			If Era(errTask) > 0 Then
				Print "Joint which caused the error is ", Era(errTask)
			EndIf
		EndIf
		EResume Next
Fend
'发送消息到上位机
Function TcpIpMsgSend
	Integer chknet4, errTask
	OpenNet #204 As Server
	Print "端口204打开"
	WaitNet #204
	Print "端口204连接"
	Do
		OnErr GoTo NetErr
		chknet4 = ChkNet(204)
		If chknet4 >= 0 Then
			If MsgSend$ <> "" Then
				Print #204, MsgSend$
				Print "MsgSend$: " + MsgSend$
				MsgSend$ = ""
			EndIf
		Else
			CloseNet #204
			Print "端口204关闭"
			Wait 0.1
			OpenNet #204 As Server
			Print "端口204重新打开"
			WaitNet #204
			Print "端口204重新连接"
		EndIf
	Loop
	 
	NetErr:
		Print "The Error code is ", Err
		Print "The Error Message is ", ErrMsg$(Err, LANGID_SIMPLIFIED_CHINESE)
		errTask = Ert
		If errTask > 0 Then
			Print "Task number in which error occurred is ", errTask
			Print "The line where the error occurred is Line ", Erl(errTask)
			If Era(errTask) > 0 Then
				Print "Joint which caused the error is ", Era(errTask)
			EndIf
		EndIf
		EResume Next
Fend
'字符串分割
Function StringSplit(StrSplit$ As String, CharSelect$ As String)
	Integer findstr, i
	String RemainStr$
	RemainStr$ = StrSplit$
	i = 0
	findstr = InStr(RemainStr$, CharSelect$)
	Do While findstr <> -1
		CmdRevStr$(i) = Mid$(RemainStr$, 1, findstr - 1)
		RemainStr$ = Mid$(RemainStr$, findstr + 1)
		i = i + 1
		findstr = InStr(RemainStr$, CharSelect$)
	Loop
	CmdRevStr$(i) = RemainStr$
Fend
'测试机1测试过程
Function TesterStart1
	Boolean voccumflag
	
	Do
		If Tester_Select(0) = True Then
			Print "测试机AL，等待开始测试"
			MsgSend$ = "测试机AL，等待开始测试"
			Do While Tester_Testing(0) = False
				If Tester_Select(0) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(0) = True Then
				voccumflag = True

'				Off AL_Suck, Forced



				Tester_Pass(0) = 0
				Tester_Ng(0) = 0
				Tester_Timeout(0) = 0
				Print "测试机AL，开始测试"
				MsgSend$ = "测试机AL，开始测试"
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "Start,1," + PickAorC$(0)
				TmReset 0
'				Wait Sw(ALRear) = 0 And Sw(ALUp) = 0
				Do While Not (Tester_Pass(0) <> 0 Or Tester_Ng(0) <> 0 Or Tester_Timeout(0) <> 0)
					TesterTimeElapse(0) = Tmr(0)
					If voccumflag And Sw(ALUp) = 0 Then
						Wait 0.5
						Off AL_Suck, Forced
						voccumflag = False
					EndIf
					If Tester_Select(0) = False Then
						Exit Do
					EndIf
					
					Wait 0.02
				Loop
				
				
				
				On AL_Suck, Forced
				Wait Sw(ALRear) = 1 And Sw(ALUp) = 1, 1
				Off AL_Suck, Forced
				TesterTimeElapse(0) = 0
				Tester_Testing(0) = False
			EndIf
		Else
			Tester_Fill(0) = False
			Tester_Testing(0) = False
			TesterTimeElapse(0) = 0
			Wait 0.1
			Off AL_Suck, Forced
		EndIf
	Loop
Fend
'测试机2测试过程
Function TesterStart2
	Boolean voccumflag
	Do
		If Tester_Select(1) = True Then
			Print "测试机AR，等待开始测试"
			MsgSend$ = "测试机AR，等待开始测试"
			Do While Tester_Testing(1) = False
				If Tester_Select(1) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(1) = True Then
				voccumflag = True
'				Off AR_Suck, Forced
				
				
				
				Tester_Pass(1) = 0
				Tester_Ng(1) = 0
				Tester_Timeout(1) = 0
				Print "测试机AR，开始测试"
				MsgSend$ = "测试机AR，开始测试"
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "Start,2," + PickAorC$(1)
				TmReset 1
'				Wait Sw(ARRear) = 0 And Sw(ARUp) = 0
				Do While Not (Tester_Pass(1) <> 0 Or Tester_Ng(1) <> 0 Or Tester_Timeout(1) <> 0)
					TesterTimeElapse(1) = Tmr(1)
					If voccumflag And Sw(ARUp) = 0 Then
						Wait 0.5
						Off AR_Suck, Forced
						voccumflag = False
					EndIf
					If Tester_Select(1) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop

				On AR_Suck, Forced
				Wait Sw(ARRear) = 1 And Sw(ARUp) = 1, 1
				Off AR_Suck, Forced
				TesterTimeElapse(1) = 0
				Tester_Testing(1) = False
			EndIf
		Else
			Tester_Fill(1) = False
			Tester_Testing(1) = False
			TesterTimeElapse(1) = 0
			Wait 0.1
			Off AR_Suck, Forced
		EndIf
	Loop
Fend
'测试机3测试过程
Function TesterStart3
	Boolean voccumflag
	Do
		If Tester_Select(2) = True Then
			Print "测试机BL，等待开始测试"
			MsgSend$ = "测试机BL，等待开始测试"
			Do While Tester_Testing(2) = False
				If Tester_Select(2) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(2) = True Then
				voccumflag = True

'				Off BL_Suck, Forced


				Tester_Pass(2) = 0
				Tester_Ng(2) = 0
				Tester_Timeout(2) = 0
				Print "测试机BL，开始测试"
				MsgSend$ = "测试机BL，开始测试"
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "Start,3," + PickAorC$(2)
				TmReset 2
'				Wait Sw(BLRear) = 0 And Sw(BLUp) = 0
				Do While Not (Tester_Pass(2) <> 0 Or Tester_Ng(2) <> 0 Or Tester_Timeout(2) <> 0)
					TesterTimeElapse(2) = Tmr(2)
					If voccumflag And Sw(BLUp) = 0 Then
						Wait 0.5
						Off BL_Suck, Forced
						voccumflag = False
					EndIf
					If Tester_Select(2) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop

				On BL_Suck, Forced
				Wait Sw(BLRear) = 1 And Sw(BLUp) = 1, 1
				Off BL_Suck, Forced
				TesterTimeElapse(2) = 0
				Tester_Testing(2) = False
			EndIf
		Else
			Tester_Fill(2) = False
			Tester_Testing(2) = False
			TesterTimeElapse(2) = 0
			Wait 0.1
			Off BL_Suck, Forced
		EndIf
	Loop
Fend
'测试机4测试过程
Function TesterStart4
	Boolean voccumflag
	Do
		If Tester_Select(3) = True Then
			Print "测试机BR，等待开始测试"
			MsgSend$ = "测试机BR，等待开始测试"
			Do While Tester_Testing(3) = False
				If Tester_Select(3) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(3) = True Then
				voccumflag = True

'				Off BR_Suck, Forced

				Tester_Pass(3) = 0
				Tester_Ng(3) = 0
				Tester_Timeout(3) = 0
				Print "测试机BR，开始测试"
				MsgSend$ = "测试机BR，开始测试"
				If CmdSend$ <> "" Then
					Print "有命令 " + CmdSend$ + " 待发送！"
				EndIf
				Do While CmdSend$ <> ""
					Wait 0.1
				Loop
				CmdSend$ = "Start,4," + PickAorC$(3)
				TmReset 3
'				Wait Sw(BRRear) = 0 And Sw(BRUp) = 0
				Do While Not (Tester_Pass(3) <> 0 Or Tester_Ng(3) <> 0 Or Tester_Timeout(3) <> 0)
					TesterTimeElapse(3) = Tmr(3)
					If voccumflag And Sw(BRUp) = 0 Then
						Wait 0.5
						Off BR_Suck, Forced
						voccumflag = False
					EndIf
					If Tester_Select(3) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop
				
				
				On BR_Suck, Forced
				Wait Sw(BRRear) = 1 And Sw(BRUp) = 1, 1
				Off BR_Suck, Forced
				TesterTimeElapse(3) = 0
				Tester_Testing(3) = False
			EndIf
		Else
			Tester_Fill(3) = False
			Tester_Testing(3) = False
			TesterTimeElapse(3) = 0
			Wait 0.1
			Off BR_Suck, Forced
		EndIf
	Loop
Fend
Function TrapInterruptAbort
	Integer i
	Out 0, 0, Forced
	Out 1, 0, Forced
	For i = 0 To 3
		PickHave(i) = False
	Next
'	Discharge = 0
	Off FeedEmpty, Forced

	Off Discharing, Forced
	Off DangerOut, Forced
Fend











