Global String CmdRev$, CmdSend$, MsgSend$
Global String CmdRevStr$(20)
Global Integer CurPosition_Num, TargetPosition_Num

Global Boolean NeedChancel(4)

Global Preserve Boolean Tester_Select(4), Tester_Fill(4)
Global Boolean Tester_Testing(4)
Global Preserve Integer Tester_Pass(4), Tester_Ng(4), Tester_Timeout(4)
'�ξ��еĲ�ƷΪ�����Ʒ��־
'0:New
'1:����1��,A
'2:����2��,AA
'3:����3��
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

'·���滮��
Global Integer PassStepNum
'������
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

Function main
	

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
	Call InitAction
	Wait 0.2
	IsLoopTestMode = False
	Print "�밴��λ��ť����ʼ��λ"
	MsgSend$ = "�밴��λ��ť����ʼ��λ"
	Wait Sw(ResetButton) = 1
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf
	
	
	Call HomeReturnAction
	Print "�ȴ����ϡ����Ͻ���"
	MsgSend$ = "�ȴ����ϡ����Ͻ���"
'	Wait Sw(FeedReady) = 0 And Sw(PassTrayRdy) = 0
	Wait Sw(FeedReady) = 1 And Sw(PassTrayRdy) = 1 And Sw(NgTrayRdy) = 1
	If Sw(PassTrayRdy) = 1 Then
		PassTraySigleDown = 1
	EndIf
	If Sw(NgTrayRdy) = 1 Then
		NgTraySigleDown = 1
	EndIf
	
main_label1:
	Wait 0.2
	Print "�밴��ʼ��ť����ʼ����"
	MsgSend$ = "�밴��ʼ��ť����ʼ����"
	Wait Sw(StartButton) = 1
	Do
		selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
		If (fillNum = selectNum And fillNum <> 0) Or Discharge <> 0 Then
		'���ȫ������ȡ��
		'������ϣ���ȡ��
			If Discharge <> 0 And fillNum = 0 Then
				Discharge = 0
				TargetPosition_Num = 1
				If Hand = 1 Then
					FinalPosition = ChangeHandL /R :Z(-61)
				Else
					FinalPosition = ChangeHandL /L :Z(-61)
				EndIf
				
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
						Print "�������"
				MsgSend$ = "�������"
				
				Exit Do
			EndIf
			Call TesterOperate01
			Call UnloadOperate(0)
		Else
			Call PickFeedOperate0
			Call TesterOperate02
		EndIf


	Loop
	GoTo main_label1
Fend
'��Ѩ��������ģʽ
Function main1
	
    Integer i, j
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
	Call InitAction
	Wait 0.2
	Print "��Ѩ��������ģʽ"
	MsgSend$ = "��Ѩ��������ģʽ"
	IsLoopTestMode = True
	Wait 0.2
'	Print "�밴��λ��ť����ʼ��λ"
'	MsgSend$ = "�밴��λ��ť����ʼ��λ"
'	Wait Sw(ResetButton) = 1
	Call HomeReturnAction
	Wait 0.2
'	Print "�밴��ʼ��ť����ʼ����"
'	MsgSend$ = "�밴��ʼ��ť����ʼ����"
'	Wait Sw(StartButton) = 1
	PickHave(0) = False
		
	If LoopTestFlexIndex > 0 And LoopTestFlexIndex < 4 Then
		i = LoopTestFlexIndex
	Else
		i = 0
	EndIf
	
	Tester_Fill(i) = False
	Tester_Testing(i) = False
	Print "��Ѩ����ģʽ����ʼ"
	MsgSend$ = "��Ѩ����ģʽ����ʼ"
	Pause
	Do
		'ȡ
		Call TesterOperate001(i)
		'��
		Call TesterOperate002(i)
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
	IsLoopTestMode = False
	Off Discharing
	Print "�밴��������ʼ��λ"
	MsgSend$ = "�밴��������ʼ��λ"
	Pause
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf
    Call TrapInterruptAbort
	
	Call HomeReturnAction
	Print "�ȴ����Ͻ���"
	MsgSend$ = "�ȴ����Ͻ���"
	FeedReadySigleDown = 0
	Wait Sw(FeedReady) = 1 And Sw(PassTrayRdy) = 1 And FeedReadySigleDown = 1
	
'	Print "�ȴ����Ͻ���"
'	MsgSend$ = "�ȴ����Ͻ���"
'	PassTraySigleDown = 0
'	Wait Sw(PassTrayRdy) = 1 And PassTraySigleDown = 1

	If Sw(PassTrayRdy) = 1 Then
		PassTraySigleDown = 1
	EndIf

	If Sw(NgTrayRdy) = 1 Then
		NgTraySigleDown = 1
	EndIf
	
main_label1:
	Wait 0.2
	If CleanActionFlag Then
		Print "����������ʼ"
		MsgSend$ = "����������ʼ"
		Call CleanActionProcess
		Print "������������"
		MsgSend$ = "������������"
		CleanActionFlag = False
		CleanActionFinishFlag = True
		Discharge = 0
		Off Discharing, Forced
	EndIf
	
	If Not CleanActionFinishFlag Then
		Print "�밴��������ʼ����"
		MsgSend$ = "�밴��������ʼ����"
		Pause
	Else
		CleanActionFinishFlag = False
	EndIf

	Do
		

		selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)

		If Discharge <> 0 And fillNum = 0 And PickHave(0) = False And PickHave(1) = False Then
			
			
			TargetPosition_Num = 1
			If Hand = 1 Then
				FinalPosition = ChangeHandL /R :Z(-61)
			Else
				FinalPosition = ChangeHandL /L :Z(-61)
			EndIf
			
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			Print "�������"
			MsgSend$ = "�������"
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
				Select BarcodeMode
					Case 0
						Call PickFeedOperate0
					Case 1
						Call PickFeedOperate1
				Send
				
			EndIf
			Call UnloadOperate(0)
			'����Aצͷ
			Call TesterOperate1
			Call UnloadOperate(1)
	        '����Bצͷ
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
			Print "���Ի�" + Str$(i + 1) + "��������"
			MsgSend$ = "���Ի�" + Str$(i + 1) + "��������"
		EndIf
	Next
	TargetPosition_Num = 1
	If Hand = 1 Then
		FinalPosition = ChangeHandL /R :Z(-61)
	Else
		FinalPosition = ChangeHandL /L :Z(-61)
	EndIf
	
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Exit Function
CleanBlowSub:
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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

	'PASS Cui ����
	Pallet 1, PCui1_1, PCui1_2, PCui1_3, 2, 2
	Pallet 2, PCui2_1, PCui2_2, PCui2_3, 2, 2
	Pallet 3, PCui3_1, PCui3_1, PCui3_2, 1, 2
	Pallet 4, PCui4_1, PCui4_1, PCui4_2, 1, 2
	
	Pallet 6, PCui1_1_A, PCui1_2_A, PCui1_3_A, 2, 2
	Pallet 7, PCui2_1_A, PCui2_2_A, PCui2_3_A, 2, 2
	Pallet 8, PCui3_1_A, PCui3_1_A, PCui3_2_A, 1, 2
	Pallet 9, PCui4_1_A, PCui4_1_A, PCui4_2_A, 1, 2
	
	'NG Cui ����
'	Pallet 5, NCui1, NCui2, NCui3, 2, 8
	Pallet 5, NCui1, NCui2, NCui3, 2, 8
	Pallet 10, NCui1_A, NCui2_A, NCui3_A, 2, 8
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
'1:��������
'2:��������
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
			Off PassTrayFull, Forced
			Wait 0.5
			On PassTrayFull, Forced
			PassTraySigleDown = 0
			PassTrayPalletNum = 1
			Wait 0.5
			Off PassTrayFull, Forced
		Case 3
			Off SHome, Forced
			Wait 0.5
			On SHome, Forced
			INP_HomeSigleDown = 0

			Wait 0.5
			Off SHome, Forced
			
	Send
	isXqtting = False
Fend
Function AllMonitor
	
	Integer FeedReady_, PassTrayRdy_, INP_Home_, i, NgTrayRdy_
	FeedReady_ = Sw(FeedReady)
	PassTrayRdy_ = Sw(PassTrayRdy)
	INP_Home_ = Sw(INP_Home)
	NgTrayRdy_ = Sw(NgTrayRdy)
	Do
		Wait 0.1
		If FeedReady_ <> Sw(FeedReady) Then
			FeedReady_ = Sw(FeedReady)
			If Sw(FeedReady) = 1 Then
				
				For i = 0 To 5
					If Sw(535 + i) = 1 Then
						FeedFill(i) = True
					Else
						FeedFill(i) = False
					EndIf
'					FeedFill(i) = PreFeedFill(i)
				Next
				
				FeedReadySigleDown = 1
				Off FeedEmpty, Forced
				FeedPanelNum = 0
			Else
'				FeedReadySigleDown = 1
				Off FeedEmpty, Forced
			EndIf
		EndIf
		
		If PassTrayRdy_ <> Sw(PassTrayRdy) Then
			PassTrayRdy_ = Sw(PassTrayRdy)
			If Sw(PassTrayRdy) = 1 Then
				PassTrayPalletNum = 1
				PassTraySigleDown = 1
				Off PassTrayFull, Forced
			Else
				PassTrayPalletNum = 1
				PassTraySigleDown = 1
				Off PassTrayFull, Forced
			EndIf
		EndIf
		
		If INP_Home_ <> Sw(INP_Home) Then
			INP_Home_ = Sw(INP_Home)
			If Sw(INP_Home_) = 1 Then
				INP_HomeSigleDown = 1
				Off SHome, Forced
			Else
				INP_HomeSigleDown = 1
				Off SHome, Forced
			EndIf
		EndIf
		
		If NgTrayRdy_ <> Sw(NgTrayRdy) Then
			NgTrayRdy_ = Sw(NgTrayRdy)
			If Sw(NgTrayRdy) = 1 Then
				NgTrayPalletNum = 1
				NgTraySigleDown = 1
				Off NgTrayFull, Forced
			Else
				NgTrayPalletNum = 1
				NgTraySigleDown = 1
				Off NgTrayFull, Forced
			EndIf
		EndIf
		
		If NgTrayPalletNum > 16 Then
			NgTrayPalletNum = 1
		EndIf
		
		If PassTrayPalletNum > 13 Then
			PassTrayPalletNum = 1
		EndIf
		
'		If Sw(FeedReady) = 0 Then
'			FeedReadySigleDown = 1
'			Off FeedEmpty, Forced
'		EndIf
		
'		If Sw(PassTrayRdy) = 0 Then
'			PassTrayPalletNum = 1
'			PassTraySigleDown = 1
'			Off PassTrayFull, Forced
'		EndIf
		
'		If Sw(NgTrayRdy) = 0 And NgTraySigleDown = 0 Then
'			NgTrayPalletNum = 1
'			NgTraySigleDown = 1
'		EndIf
		
'		If Sw(INP_Home) = 0 Then
'			INP_HomeSigleDown = 1
'			Off SHome, Forced
'		EndIf		
	Loop
Fend
Function test1
'	MemOutW 0, 65535
'	P500 = XY(MemInW(0), 0, 0, 0)
'	Print CX(P500)
'	PLabel 500, "XtestP1"
'	SavePoints "robot1.pts"
	OutW SpositionY, 65534
Fend
Function test2

Fend
'��צ��ȡ����
Function PickFeedOperate0

	Boolean scanflag, pickfeedflag, fullflag
PickFeedOperatelabel1:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Discharge = 0 Then
		'���ϵ�
		TargetPosition_Num = 1
		If Hand = 1 Then
			FinalPosition = ChangeHandL /R :Z(-61)
		Else
			FinalPosition = ChangeHandL /L :Z(-61)
		EndIf
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "�����̣�δ׼����"
		MsgSend$ = "�����̣�δ׼����"
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0
			Wait 0.2
			If Discharge <> 0 Then
                Exit Do
			EndIf
		Loop
		If Discharge = 0 Then
			Print "�����̣�׼����"
			MsgSend$ = "�����̣�׼����"
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
					Print "�����̣���ȡʧ��"
					MsgSend$ = "�����̣���ȡʧ��"
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
				'ûɨ�ϣ���Ϊʯ�̲���
				Print "ʴ�̲���"
				MsgSend$ = "ʴ�̲���"
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
					Print "�����̣���ȡʧ��"
					MsgSend$ = "�����̣���ȡʧ��"
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
'צ��Aȡ����
Function PickFeedOperate1
	Boolean pickfeedflag, fullflag
	Integer scanflag
PickFeedOperatelabel1:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Discharge = 0 Then
		'���ϵ�
		TargetPosition_Num = 1
		If Hand = 1 Then
			FinalPosition = ChangeHandL /R :Z(-61)
		Else
			FinalPosition = ChangeHandL /L :Z(-61)
		EndIf
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "�����̣�δ׼����"
		MsgSend$ = "�����̣�δ׼����"
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0
			Wait 0.2
			If Discharge <> 0 Then
                Exit Do
			EndIf
		Loop
		If Discharge = 0 Then
			Print "�����̣�׼����"
			MsgSend$ = "�����̣�׼����"
		EndIf
	EndIf
	
	If Discharge = 0 Then
		If FeedFill(FeedPanelNum) = True Then
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
'					MemOn 99
'					Sense MemSw(99)
'					If Hand = 1 Then
'						Jump ChangeHandL /R Sense
'					Else
'						Jump ChangeHandL /L Sense
'					EndIf
				
				FeedPanelNum = FeedPanelNum + 1
				
				scanflag = ScanBarcodeOpetateP3("A")
				fullflag = IsFeedPanelEmpty(False)
				Select scanflag
					Case 1
						Print "ɨ��ɹ�"
						Pick_P_Msg(0) = -1
					Case 4
						Print "ʴ�̲���"
						MsgSend$ = "ʴ�̲���"
'						Pause
						TargetPosition_Num = 11
						FinalPosition = P(Int(Rnd(40) / 10) + 110)
						Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
						ReleaseAction(0, -1)
						PickHave(0) = False
					Default
						Print "ɨ�벻��"
						MsgSend$ = "ɨ�벻��"
'						Pause
						Pick_P_Msg(0) = 1
						
				Send
'				If scanflag Then
'					Print "ɨ��ɹ�"
'				Else
'					Print "ʴ�̲���"
'					MsgSend$ = "ʴ�̲���"
'					Pause
'					TargetPosition_Num = 11
'					FinalPosition = P(Int(Rnd(40) / 10) + 110)
'					Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'					ReleaseAction(0, -1)
'					PickHave(0) = False
'				EndIf
				

			Else
				Print "�����̣���ȡʧ��"
				MsgSend$ = "�����̣���ȡʧ��"
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
			FeedPanelNum = FeedPanelNum + 1;
			Call IsFeedPanelEmpty(True)
		EndIf

		
	EndIf

Fend
'צ��Bȡ����
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
				'���̿���
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
'�ж��������Ƿ�ȡ��
Function IsFeedPanelEmpty(needwait As Boolean) As Boolean
'	Integer i, j
    LimZ -61
	If FeedPanelNum > 5 Then
		'���̿���
		If CurPosition_Num = 1 Then
			MemOn 99
			Sense MemSw(99) = 1
			If Hand = 1 Then
				Jump ChangeHandL /R Sense
			Else
				Jump ChangeHandL /L Sense
			EndIf
		EndIf

		
		Off RollValve
		If needwait Then
			Wait 3
		EndIf
		On FeedEmpty
		FeedReadySigleDown = 0
		IsFeedPanelEmpty = True
		FeedPanelNum = 0

	Else
		If FeedPanelNum = 3 Then
			On RollValve
			If needwait Then
				Wait 3
			EndIf
		EndIf
		IsFeedPanelEmpty = False
	EndIf
Fend
'ѭ����̨���ԣ�ȡ
Function TesterOperate001(i As Integer)
	
	Boolean scanflag, pickfeedflag
	Integer rearnum
	If PickHave(i) = False Then
		If Tester_Fill(i) = False Then
		'��������ȡ��	
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
					Print "�����̣���ȡʧ��"
					MsgSend$ = "�����̣���ȡʧ��"
					Go Here +Z(20)
					Pause
				EndIf
			Else
				Print "ɨ��ʧ��"
				MsgSend$ = "ɨ��ʧ��"
				Pause
			EndIf
		Else
		'���ξ�ȡ��				
			If Tester_Select(i) = False Then
				Print "���Ի�,δѡ��"
				MsgSend$ = "���Ի�,δѡ��"
				Do
					If Tester_Select(i) = True Then
						Exit Do
					EndIf
					Wait 1
				Loop
			EndIf
			If Tester_Testing(i) = True Then
				Print "���Ի�,���ڲ��Թ����С�ǰ���ȴ�λ�á�"
				MsgSend$ = "���Ի�,���ڲ��Թ����С�ǰ���ȴ�λ�á�"
				Select i
					Case 0
						TargetPosition_Num = 2
						'A_1������TesterOperate1����
						FinalPosition1 = A1PASS1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS3
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
	'ȡ

	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
			FinalPosition1 = A3PASS3
			rearnum = 14
			Off BL_Suck
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
			Off BR_Suck
	Send
	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	Go FinalPosition1
	
	If PickHave(0) = False Then

		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
		Off i * 2
	Else
		Print "���Ի�" + Str$(i + 1) + "���������"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "���������"
		Pause
		MsgSend$ = "��Ѩ���ԣ�һ�����"
	EndIf
Return
Fend
'ѭ����̨���ԣ���
Function TesterOperate002(i As Integer)
	Integer rearnum
	If PickHave(i) = True Then
	'���ξ߷���				
		If Tester_Select(i) = False Then
			Print "���Ի�,δѡ��"
			MsgSend$ = "���Ի�,δѡ��"
			Do
				If Tester_Select(i) = True Then
					Exit Do
				EndIf
				Wait 1
			Loop
		EndIf
		If Tester_Fill(i) = True Then
			Print "���Ի�,���ϡ�ǰ���ȴ�λ�á�"
			MsgSend$ = "���Ի�,���ϡ�ǰ���ȴ�λ�á�"
			Select i
				Case 0
					TargetPosition_Num = 2
					'A_1������TesterOperate1����
					FinalPosition1 = A1PASS1
				Case 1
					TargetPosition_Num = 3
					FinalPosition1 = A2PASS1
				Case 2
					TargetPosition_Num = 4
					FinalPosition1 = A3PASS3
				Case 3
					TargetPosition_Num = 5
					FinalPosition1 = A4PASS3
			Send
			FinalPosition = FinalPosition1
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			Wait 0.2
			Print "���Ի�,���ϡ����Ƚ���ȡ�ߡ�"
			MsgSend$ = "���Ի�,���ϡ����Ƚ���ȡ�ߡ�"
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
'�п�Ѩ
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
	'�˳�����������������
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
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
'��צ�ִ�����Ի�����ȡ
Function TesterOperate01
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(0) = False Then
		'�ж��Ƿ�ȫΪѡ���Ի�
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "δѡ����Ի�,������ԣ�"
				MsgSend$ = "δѡ����Ի���������ԣ�"
			Else
				Exit Do
			EndIf
		Loop

		For i = 0 To 3
			
			'����Ѩ����Ҳ�������
			If Tester_Fill(i) = True And Tester_Testing(i) = False Then
				Exit For
			EndIf
		Next
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
		'δ��
		If fillNum <> 0 Then
			If i > 3 Then
				'���в��Ի������ڲ����ж��ڲ�����
				Print "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
				MsgSend$ = "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
						'A_1������TesterOperate1����
						FinalPosition1 = A1PASS1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS3
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
					'һֱ�ж�
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
		'�����ξ߶�Ϊ��
		EndIf

	EndIf
	Exit Function
'ȡ��Ʒ�Ӻ���	
TesterOperate1SuckSub:
	'ȡ

	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
'		Print "������ " + CmdSend$ + " �����ͣ�"
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
	
			'�жϳ�ʱ
			If Tester_Timeout(i) <> 0 Then
				Print "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				Pause
			EndIf
			'�ж�����NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Print "���Ի�" + Str$(i + 1) + "������NG"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "������NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
		EndIf
	Else
		Select i
			Case 0
				TargetPosition_Num = 2
				'A_1������TesterOperate1����
				FinalPosition1 = A1PASS1
				rearnum = 4
			Case 1
				TargetPosition_Num = 3
				FinalPosition1 = A2PASS1
				rearnum = 5
			Case 2
				TargetPosition_Num = 4
				FinalPosition1 = A3PASS3
				rearnum = 14
			Case 3
				TargetPosition_Num = 5
				FinalPosition1 = A4PASS3
				rearnum = 15
		Send
		Go FinalPosition1
		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
		Off i * 2
	EndIf
Return

Fend
'��צ�ִ�����Ի����򣬷�
Function TesterOperate02
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(0) = True Then
		'�ж��Ƿ�ȫΪѡ���Ի�
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "δѡ����Ի�,������ԣ�"
				MsgSend$ = "δѡ����Ի���������ԣ�"
			Else
				Exit Do
			EndIf
		Loop
		'�ж��Ƿ���ڿ�Ѩ
		For i = 0 To 3

			If Tester_Select(i) = True And Tester_Fill(i) = False Then
				Exit For
			EndIf

		Next
		If i > 3 Then
		'����
			Print "���Ի�����,�޷��ٷŲ�Ʒ!"
			MsgSend$ = "���Ի�����,�޷��ٷŲ�Ʒ!"
			Pause
		Else
'����
			GoSub TesterOperate1ReleaseSub
		EndIf

	EndIf
	Exit Function

TesterOperate1ReleaseSub:
'�п�Ѩ
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"

		FinalPosition = FinalPosition1
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
	'�˳�����������������
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
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
'Aץ�ִ�����Ի�����
Function TesterOperate1
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	Boolean isA_NeedReJuge
	If PickHave(0) = True Then
		'�ж��Ƿ�ȫΪѡ���Ի�
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "δѡ����Ի�,������ԣ�"
				MsgSend$ = "δѡ����Ի���������ԣ�"
			Else
				Exit Do
			EndIf
		Loop
		'�ж��Ƿ���ڿ�Ѩ
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg������TesterOperate1����
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
		'����Ѩ �� ����
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
				'���в��Ի������ڲ����ж��ڲ�����
				Print "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
				MsgSend$ = "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
						'A_1������TesterOperate1����
						FinalPosition1 = A1PASS1
'						Position2NeedNeedAnotherMove = True
						
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS3
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
					'һֱ�ж�
					GoTo TesterOperate1_lable1
				EndIf
				GoTo TesterOperate1_lable2
			Else
TesterOperate1_lable2:
                GoSub TesterOperate1SuckSub
'����				
				If PickHave(1) = True And Pick_P_Msg(1) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
					Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
					Print "A�����������⣬" + Str$(i + 1)
					MsgSend$ = "A�����������⣬" + Str$(i + 1)
					'�����ţ�����
					GoSub TesterOperate1ReleaseSub_1
				Else
					'��
					'�������Ի���ѡ�����Σ���Ҫ��ȡ�߲�Ʒ��
					If NeedChancel(i) = False Then
					'ȡ��
						GoSub TesterOperate1ReleaseSub
'						If PickHave(1) Then
'							If Sw(VacuumValueB) = 0 Then
'								Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'								MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
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
'����
			GoSub TesterOperate1ReleaseSub
'			If PickHave(1) Then
'				If Sw(VacuumValueB) = 0 Then
'					Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'					MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
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
					'���в��Ի������ڲ����ж��ڲ�����
					Print "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
					MsgSend$ = "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
							'A_1������TesterOperate1����
							FinalPosition1 = A1PASS1
'							Position2NeedNeedAnotherMove = True
							
						Case 1
							TargetPosition_Num = 3
							FinalPosition1 = A2PASS1
							
						Case 2
							TargetPosition_Num = 4
							FinalPosition1 = A3PASS3
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
						'һֱ�ж�
						GoTo TesterOperate1_lable4
					EndIf
					GoTo TesterOperate1_lable5
				Else
TesterOperate1_lable5:
	                GoSub TesterOperate1SuckSub
					
					If PickHave(1) = True And Pick_P_Msg(1) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
						Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
						Print "A�����ϣ����⣬" + Str$(i + 1)
						MsgSend$ = "A�����ϣ����⣬" + Str$(i + 1)
						'�����ţ�����
						GoSub TesterOperate1ReleaseSub_1
					Else
						If NeedChancel(i) = True Then
							Tester_Select(i) = False
							NeedChancel(i) = False
						EndIf
					EndIf

				EndIf
			Else
			'�����ξ߶�Ϊ��
			EndIf

		EndIf
	EndIf
	Exit Function
'ȡ��Ʒ�Ӻ���	
TesterOperate1SuckSub:
	'ȡ
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
			'A_1������TesterOperate1����
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

	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
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
		Else
			

			
	
			'�жϳ�ʱ
			If Tester_Timeout(i) <> 0 Then
				Print "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				Pause
			EndIf
			'�ж�����NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Select i
					Case 0
		'				TargetPosition_Num = 2
						'A_1������TesterOperate1����
						FinalPosition1 = A1PASS1
		'				Position2NeedNeedAnotherMove = True
						
						rearnum = 4
					Case 1
		'				TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
						rearnum = 5
					Case 2
		'				TargetPosition_Num = 4
						FinalPosition1 = A3PASS3
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
				Print "���Ի�" + Str$(i + 1) + "������NG"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "������NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
			'����
			If Tester_ReTestFalg(i) = 1 And ReTest_ Then
			'��Ҫ����һ̨���Ի�����
				Pick_P_Msg(1) = i + 2
			Else
				Pick_P_Msg(1) = 1
			EndIf
			
		EndIf
	Else
		Select i
			Case 0
'				TargetPosition_Num = 2
				'A_1������TesterOperate1����
				FinalPosition1 = A1PASS1
'				Position2NeedNeedAnotherMove = True
				
				rearnum = 4
			Case 1
'				TargetPosition_Num = 3
				FinalPosition1 = A2PASS1
				
				rearnum = 5
			Case 2
'				TargetPosition_Num = 4
				FinalPosition1 = A3PASS3
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
		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
		Off SuckB
	EndIf
Return

TesterOperate1ReleaseSub:
'�п�Ѩ
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
			'A_1������TesterOperate1����
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

	Call ReleaseAction(0, i + 1)
	PickHave(0) = False
	Tester_Fill(i) = True;
	'�˳�����������������
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
			FinalPosition1 = A3PASS3
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
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	
'	If PickHave(1) Then
'		If Sw(VacuumValueB) = 0 Then
'			Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			Pause
'			Off SuckB
'			PickHave(1) = False
'		EndIf
'	EndIf
	
	
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		Pause
	EndIf
	
	Tester_Testing(i) = True
	PickAorC$(i) = "A"
'	voccumValue1
	
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
'�п�Ѩ
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
			'A_1������TesterOperate1����
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
	Call ReleaseAction(1, i + 1)
	PickHave(1) = False
	Tester_Fill(i) = True;
	'�˳�����������������
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
			FinalPosition1 = A3PASS3
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
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		Pause
	EndIf
	Tester_Testing(i) = True
	PickAorC$(i) = "B"
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
'Bץ�ִ�����Ի�����
Function TesterOperate2
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	Boolean isA_NeedReJuge
	If PickHave(1) = True Then
		'�ж��Ƿ�ȫΪѡ���Ի�
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "δѡ����Ի�,������ԣ�"
				MsgSend$ = "δѡ����Ի���������ԣ�"
			Else
				Exit Do
			EndIf
		Loop
		'�ж��Ƿ���ڿ�Ѩ
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg������TesterOperate1����
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
		'����Ѩ �� ����
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
				'���в��Ի������ڲ����ж��ڲ�����
				Print "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
				MsgSend$ = "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
						'A_1������TesterOperate1����
						FinalPosition1 = A1PASS1
'						Position2NeedNeedAnotherMove = True
						
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A3PASS3
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
					'һֱ�ж�
					GoTo TesterOperate1_lable1
				EndIf
				GoTo TesterOperate1_lable2
			Else
TesterOperate1_lable2:
                GoSub TesterOperate1SuckSub
'				If PickHave(1) Then
'					If Sw(VacuumValueB) = 0 Then
'						Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'						MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'						Pause
'						Off SuckB
'						PickHave(1) = False
'					EndIf
'				EndIf
'����				
				If PickHave(0) = True And Pick_P_Msg(0) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
					Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
					Print "B�����������⣬" + Str$(i + 1)
					MsgSend$ = "B�����������⣬" + Str$(i + 1)
					'�����ţ�����
					GoSub TesterOperate1ReleaseSub_1
'					If PickHave(1) Then
'						If Sw(VacuumValueB) = 0 Then
'							Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'							MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'							Pause
'							Off SuckB
'							PickHave(1) = False
'						EndIf
'					EndIf
				Else
					'��
					'�������Ի���ѡ�����Σ���Ҫ��ȡ�߲�Ʒ��
					If NeedChancel(i) = False Then
					'ȡ��
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
'����
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
					'���в��Ի������ڲ����ж��ڲ�����
					Print "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
					MsgSend$ = "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
							'A_1������TesterOperate1����
							FinalPosition1 = A1PASS1
'							Position2NeedNeedAnotherMove = True
							
						Case 1
							TargetPosition_Num = 3
							FinalPosition1 = A2PASS1
							
						Case 2
							TargetPosition_Num = 4
							FinalPosition1 = A3PASS3
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
						'һֱ�ж�
						GoTo TesterOperate1_lable4
					EndIf
					GoTo TesterOperate1_lable5
				Else
TesterOperate1_lable5:
	                GoSub TesterOperate1SuckSub
'					If PickHave(1) Then
'						If Sw(VacuumValueB) = 0 Then
'							Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'							MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'							Pause
'							Off SuckB
'							PickHave(1) = False
'						EndIf
'					EndIf
					If PickHave(0) = True And Pick_P_Msg(0) = 1 And ReTest_ And Tester_ReTestFalg(i) < 1 Then
						Tester_ReTestFalg(i) = Tester_ReTestFalg(i) + 1
						Print "B�����ϣ����⣬" + Str$(i + 1)
						MsgSend$ = "B�����ϣ����⣬" + Str$(i + 1)
						'�����ţ�����
						GoSub TesterOperate1ReleaseSub_1
'						If PickHave(1) Then
'							If Sw(VacuumValueB) = 0 Then
'								Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'								MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
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
			'�����ξ߶�Ϊ��
			EndIf

		EndIf
	EndIf
	Exit Function
'ȡ��Ʒ�Ӻ���	
TesterOperate1SuckSub:
	'ȡ
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
			'A_1������TesterOperate1����
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
	
	
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
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
		Else
			

			
	
			'�жϳ�ʱ
			If Tester_Timeout(i) <> 0 Then
				Print "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				Pause
			EndIf
			'�ж�����NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Select i
					Case 0
		'				TargetPosition_Num = 2
						'A_1������TesterOperate1����
						FinalPosition1 = A1PASS1
		'				Position2NeedNeedAnotherMove = True
						
						rearnum = 4
					Case 1
		'				TargetPosition_Num = 3
						FinalPosition1 = A2PASS1
						
						rearnum = 5
					Case 2
		'				TargetPosition_Num = 4
						FinalPosition1 = A3PASS3
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
				Print "���Ի�" + Str$(i + 1) + "������NG"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "������NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
			'����
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
				'A_1������TesterOperate1����
				FinalPosition1 = A1PASS1
'				Position2NeedNeedAnotherMove = True
				
				rearnum = 4
			Case 1
'				TargetPosition_Num = 3
				FinalPosition1 = A2PASS1
				
				rearnum = 5
			Case 2
'				TargetPosition_Num = 4
				FinalPosition1 = A3PASS3
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
		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
		Off SuckA
	EndIf
'	If PickHave(1) Then
'		If Sw(VacuumValueB) = 0 Then
'			Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			Pause
'			Off SuckB
'			PickHave(1) = False
'		EndIf
'	EndIf
Return

TesterOperate1ReleaseSub:
'�п�Ѩ
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
			'A_1������TesterOperate1����
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
	Call ReleaseAction(1, i + 1)
	PickHave(1) = False
	Tester_Fill(i) = True;
	'�˳�����������������
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
			FinalPosition1 = A3PASS3
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
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		Pause
	EndIf
	Tester_Testing(i) = True
	PickAorC$(i) = "B"
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
'�п�Ѩ
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
			FinalPosition1 = A1PASS1
			
			rearnum = 4
		Case 1
'			TargetPosition_Num = 3
			FinalPosition1 = A2PASS1
			rearnum = 5
		Case 2
'			TargetPosition_Num = 4
			FinalPosition1 = A3PASS3
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send

	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
			'A_1������TesterOperate1����
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
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(0, i + 1)
	PickHave(0) = False
	Tester_Fill(i) = True;
	'�˳�����������������
	Select i
		Case 0
'			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
			FinalPosition1 = A3PASS3
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
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
'	If PickHave(1) Then
'		If Sw(VacuumValueB) = 0 Then
'			Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			Pause
'			Off SuckB
'			PickHave(1) = False
'		EndIf
'	EndIf
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		Pause
	EndIf
	Tester_Testing(i) = True
	PickAorC$(i) = "A"
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
'Cץ�ִ�����Ի�����
Function TesterOperate3
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(2) = True Then
		'�ж��Ƿ�ȫΪѡ���Ի�
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "δѡ����Ի�,������ԣ�"
				MsgSend$ = "δѡ����Ի���������ԣ�"
			Else
				Exit Do
			EndIf
		Loop
		'�ж��Ƿ���ڿ�Ѩ
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg������TesterOperate1����
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
		'����Ѩ �� ����
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
				'���в��Ի������ڲ����ж��ڲ�����
				Print "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
				MsgSend$ = "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
						'A_1������TesterOperate1����
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
					'һֱ�ж�
					GoTo TesterOperate3_lable1
				EndIf
				GoTo TesterOperate3_lable2
			Else
TesterOperate3_lable2:
                GoSub TesterOperate3SuckSub
				
				'��
				'�������Ի���ѡ�����Σ���Ҫ��ȡ�߲�Ʒ��
				If NeedChancel(i) = False Then
				'ȡ��
					GoSub TesterOperate3ReleaseSub
				Else
					Tester_Select(i) = False
					NeedChancel(i) = False
					Go FinalPosition +X(10)
				EndIf
			EndIf
		Else
'����
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
					'���в��Ի������ڲ����ж��ڲ�����
					Print "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
					MsgSend$ = "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
							'A_1������TesterOperate1����
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
						'һֱ�ж�
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
			'�����ξ߶�Ϊ��
			EndIf

		EndIf
	EndIf
'ȡ��Ʒ�Ӻ���	
TesterOperate3SuckSub:
	'ȡ
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		FinalPosition = FinalPosition1 + XY(30, 0, 0, 0)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
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
			'�жϳ�ʱ
			If Tester_Timeout(i) <> 0 Then
				Print "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				Pause
			EndIf
			'�ж�����NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Print "���Ի�" + Str$(i + 1) + "������NG"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "������NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
		EndIf
	Else
		Go FinalPosition +X(10)
		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
	EndIf
Return

TesterOperate3ReleaseSub:
'�п�Ѩ
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
	'�˳�����������������
	Go FinalPosition +X(20)
	Tester_Testing(i) = True
	PickAorC$(i) = "C"
Return

Fend
'Dץ�ִ�����Ի�����
Function TesterOperate4
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(3) = True Then
		'�ж��Ƿ�ȫΪѡ���Ի�
		Do
			For i = 0 To 3
				If Tester_Select(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				Wait 1
				Print "δѡ����Ի�,������ԣ�"
				MsgSend$ = "δѡ����Ի���������ԣ�"
			Else
				Exit Do
			EndIf
		Loop
		'�ж��Ƿ���ڿ�Ѩ
		For i = 0 To 3
			If ReTest_ Then
			'Pick_P_Msg������TesterOperate1����
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
		'����Ѩ �� ����
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
				'���в��Ի������ڲ����ж��ڲ�����
				Print "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
				MsgSend$ = "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
						'A_1������TesterOperate1����
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
					'һֱ�ж�
					GoTo TesterOperate4_lable1
				EndIf
				GoTo TesterOperate4_lable2
			Else
TesterOperate4_lable2:
                GoSub TesterOperate4SuckSub
				
				'��
				'�������Ի���ѡ�����Σ���Ҫ��ȡ�߲�Ʒ��
				If NeedChancel(i) = False Then
				'ȡ��
					GoSub TesterOperate4ReleaseSub
				Else
					Tester_Select(i) = False
					NeedChancel(i) = False
					Go FinalPosition +X(10)
				EndIf
			EndIf
		Else
'����
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
					'���в��Ի������ڲ����ж��ڲ�����
					Print "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
					MsgSend$ = "���Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
							'A_1������TesterOperate1����
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
						'һֱ�ж�
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
			'�����ξ߶�Ϊ��
			EndIf

		EndIf
	EndIf
'ȡ��Ʒ�Ӻ���	
TesterOperate4SuckSub:
	'ȡ
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		FinalPosition = FinalPosition1 + XY(30, 0, 0, 0)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(rearnum) = 1
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
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
			'�жϳ�ʱ
			If Tester_Timeout(i) <> 0 Then
				Print "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "�����Գ�ʱ"
				Pause
			EndIf
			'�ж�����NG
			If Tester_Ng(i) <> 0 Then
				NgContinue(i) = NgContinue(i) + 1
			EndIf

			If NgContinue(i) >= NgContinueNum Then
				Print "���Ի�" + Str$(i + 1) + "������NG"
				MsgSend$ = "���Ի�" + Str$(i + 1) + "������NG"
				Pause
				NgContinue(i) = 0
			EndIf
			
		EndIf
	Else
		Go FinalPosition +X(10)
		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
	EndIf
Return

TesterOperate4ReleaseSub:
'�п�Ѩ
	Select i
		Case 0
			TargetPosition_Num = 2
			'A_1������TesterOperate1����
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
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
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
	'�˳�����������������
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
	If Sw(PassTrayRdy) = 0 Or PassTraySigleDown = 0 Then
		If PassTrayPalletNum <= 6 Then
			TargetPosition_Num = 6
			FinalPosition = PCui1P4
		ElseIf PassTrayPalletNum <= 8 Then
			TargetPosition_Num = 7
			FinalPosition = PCui2P4
		ElseIf PassTrayPalletNum <= 11 Then
			TargetPosition_Num = 8
			FinalPosition = PCui3P3
		Else
			TargetPosition_Num = 9
			FinalPosition = PCui4P3
		EndIf
		Print "Pass�����̣�δ׼����"
		MsgSend$ = "Pass�����̣�δ׼����"
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(PassTrayRdy) = 1 And PassTraySigleDown = 1
	If PassTrayPalletNum <= 4 Then
		TargetPosition_Num = 6
		If num = 1 Then
			FinalPosition = Pallet(1, PassTrayPalletNum)
		Else
			FinalPosition = Pallet(6, PassTrayPalletNum)
		EndIf
		
	ElseIf PassTrayPalletNum <= 8 Then
		TargetPosition_Num = 7
		
		If num = 1 Then
			FinalPosition = Pallet(2, PassTrayPalletNum - 4)
		Else
			FinalPosition = Pallet(7, PassTrayPalletNum - 4)
		EndIf
	ElseIf PassTrayPalletNum <= 10 Then
		TargetPosition_Num = 8
		If num = 1 Then
			FinalPosition = Pallet(3, PassTrayPalletNum - 8)
		Else
			FinalPosition = Pallet(8, PassTrayPalletNum - 8)
		EndIf

	Else
		TargetPosition_Num = 9
		If num = 1 Then
			FinalPosition = Pallet(4, PassTrayPalletNum - 10)
		Else
			FinalPosition = Pallet(9, PassTrayPalletNum - 10)
		EndIf
		
	EndIf

	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(num, -1)
	PickHave(num) = False
	PassTrayPalletNum = PassTrayPalletNum + 1
	If PassTrayPalletNum > 12 Then
		Go P(349 + PassStepNum)
		Print "Pass�����̣�����"
		MsgSend$ = "Pass�����̣�����"
		On PassTrayFull
		PassTrayPalletNum = 1
	EndIf
	
Return

UnloadOperate_Ng:
	If Sw(NgTrayRdy) = 0 Or NgTraySigleDown = 0 Then
		TargetPosition_Num = 10
		FinalPosition = NCuiP3
		Print "Ng�����̣���"
		MsgSend$ = "Ng�����̣���"
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	EndIf
	Wait Sw(NgTrayRdy) = 1 And NgTraySigleDown = 1
	TargetPosition_Num = 10

	
	If num = 1 Then
		FinalPosition = Pallet(5, NgTrayPalletNum)
	Else
		FinalPosition = Pallet(10, NgTrayPalletNum)
	EndIf
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(num, -1)
	PickHave(num) = False
	NgTrayPalletNum = NgTrayPalletNum + 1
	If NgTrayPalletNum > 15 Then
		Go P(349 + PassStepNum)
		Print "Ng�����̣�����"
		MsgSend$ = "Ng�����̣�����"
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
'	If CmdSend$ <> "" Then
'		Print "������ " + CmdSend$ + " �����ͣ�"
'	EndIf
'	Do While CmdSend$ <> ""
'		Wait 0.1
'	Loop
'	CmdSend$ = "TakePhoto"
	If Hand = 1 Then
		FinalPosition = ScanPositionP3R
	Else
		FinalPosition = ScanPositionP3L
	EndIf
	
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	
ScanBarcodeOpetateP3label:
	
	Wait 0.2
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "ScanP3," + picksting$
	TmReset 7
	Do While ScanResult = 0 And Tmr(7) < 10
		Wait 0.2
		Print "�ȴ�ɨ���� " + Str$(Tmr(7))
	Loop
	
	If ScanResult <> 1 And re_scan = False Then
		re_scan = True
		Go Here +X(5)
		Go Here +Y(5)
		ScanResult = 0
		Wait 0.5
		GoTo ScanBarcodeOpetateP3label
		
	EndIf
	
	
	
	If Hand = 1 Then
		Go ChangeHandL /R
	Else
		Go ChangeHandL /L
	EndIf

	ScanBarcodeOpetateP3 = ScanResult
Fend
Function ScanBarcodeOpetate(num As Integer, picksting$ As String)

	TargetPosition_Num = 1
	ScanResult = 0
'	If CmdSend$ <> "" Then
'		Print "������ " + CmdSend$ + " �����ͣ�"
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
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "Scan," + picksting$
	TmReset 7
	Do While ScanResult = 0 And Tmr(7) < 10
		Wait 0.2
		Print "�ȴ�ɨ���� " + Str$(Tmr(7))
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
'�س�ʼλ��
Function HomeReturnAction
	Motor Off
	Motor On
	Power Low
	Weight 1
	LimZ -61
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
	Go Here :Z(-61)
	SFree 1, 2, 3, 4
	Do
		
		
		HomeSuccessFlage = True
'		If Hand(Here) = 2 Then
'			
'		Else
'			HomeSuccessFlage = False
'			Print "�뽫��е�ֵ���Ϊ��������"
'		EndIf
		If CX(Here) > -100 And CX(Here) < 100 Then
		
		Else
			HomeSuccessFlage = False
			Print "X����ƫ���"
			MsgSend$ = "X����ƫ���"
		EndIf
		If CY(Here) > 150 And CY(Here) < 350 Then
		
		Else
			HomeSuccessFlage = False
			Print "Y����ƫ���"
			MsgSend$ = "Y����ƫ���"
		EndIf
		
		If HomeSuccessFlage Then
			Print "��ʼλ�÷���Ҫ��"
			MsgSend$ = "��ʼλ�÷���Ҫ��"
			Exit Do
		Else

			Pause
		EndIf

	Loop
	SLock 1, 2, 3, 4
	Go Here :Y(373)
	Go Here :U(189.745)
	CurPosition_Num = 1
	If Hand = 1 Then
		Go ChangeHandL /R
	Else
		Go ChangeHandL
	EndIf
	
'	Pause
	S_Position = CX(P501)
	OutW SpositionY, S_Position
	If Sw(INP_Home) = 0 Then
		On SHome
		INP_HomeSigleDown = 0
		Wait Sw(INP_Home) = 1 And INP_HomeSigleDown = 1
	EndIf
	Wait InW(SPositionX) = S_Position
'	On FeedEmpty
'	On PassTrayFull
	
	
'	Wait Sw(INP_Home) = 1 And InW(SPositionX) = S_Position
'	Wait InW(SPositionX) = S_Position

	Print "Home Return Compelet"
	MsgSend$ = "Home Return Compelet"
	
	Power High
	Speed 90
	Accel 90, 90
'	Speed 100, 100, 90
'	SpeedS 100
'	Accel 100, 90, 100, 100, 100, 90
'	AccelS 100, 90
	CurPosition_Num = 1
Fend
'·���滮
'firstPosition Ŀ��λ��
'secendPosition ��ǰλ��
Function RoutePlanThenExe(firstPosition As Integer, secendPosition As Integer)
'TargetHand	
'1 R
'2 L
	Integer TargetHand, i, j
	Int32 SpBox
	LimZ -61
	If PassStepNum > 0 And firstPosition <> secendPosition Then
		For i = 0 To PassStepNum - 1
			Pass P(349 + PassStepNum - i)
		Next
		PassStepNum = 0
	EndIf
	
	If firstPosition = secendPosition Then
		Select secendPosition
			Case 2
				If isInWaitPosition(0) Then
					RoutePassP3 = A1PASS2
					PassStepNum = PassStepNum + 1
					Pass A1PASS2
					RoutePassP4 = B_1 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_1 +Z(10)
					
				EndIf
			Case 3
				If isInWaitPosition(1) Then
					RoutePassP3 = A2PASS2
					PassStepNum = PassStepNum + 1
					Pass A2PASS2
					
					RoutePassP4 = B_2 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_2 +Z(10)
				EndIf
			Case 4
				If isInWaitPosition(2) Then
					RoutePassP5 = A3PASS4
					PassStepNum = PassStepNum + 1
					Pass A3PASS4
					
					RoutePassP6 = B_3 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_3 +Z(10)
				EndIf
			Case 5
				If isInWaitPosition(3) Then
					RoutePassP5 = A4PASS4
					PassStepNum = PassStepNum + 1
					Pass A4PASS4
					
					RoutePassP6 = B_4 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_4 +Z(10)
					
				EndIf
		Send
'		If Position2NeedNeedAnotherMove = True And secendPosition = 2 Then
'
'			Pass A1PASS2
'
'			Pass B_1
'			Position2NeedNeedAnotherMove = False
'		EndIf
		Go FinalPosition
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next

	Else
		PassStepNum = 0
		Select secendPosition
			Case -2
'				Go FinalPosition
			Case 1
				TargetHand = Hand
				GoSub ChangeHandAction
				OutW SpositionY, CX(P501)
				Wait InW(SPositionX) = CX(P501) And Sw(INP) = 1
				Go FinalPosition
			Case 2
				TargetHand = 1
				GoSub ChangeHandAction
				OutW SpositionY, CX(P506)
				Wait InW(SPositionX) = CX(P506) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A1PASS1
				PassStepNum = PassStepNum + 1
				'ȥA1��������δ׼���ã���ȴ�
				If IsLoopTestMode = False Then
					Wait(Sw(FeedReady) = 1 And FeedReadySigleDown = 1) Or Discharge <> 0
				EndIf
				
				If Sw(X110) = 1 Or Sw(X111) = 0 Then
					Print "�����̣����״������쳣"
					MsgSend$ = "�����̣����״������쳣"
					Pause
				EndIf
				Wait Sw(X110) = 0 And Sw(X111) = 1
				
				Pass A1PASS1
				If NeedAnotherMove(0) Then
					RoutePassP3 = A1PASS2
					PassStepNum = PassStepNum + 1
					Pass A1PASS2
					RoutePassP4 = B_1 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_1 +Z(10)
					NeedAnotherMove(0) = False
				EndIf
				Go FinalPosition
'				Position2NeedNeedAnotherMove = False
			Case 3
				TargetHand = 1
				GoSub ChangeHandAction
				OutW SpositionY, CX(P507)
				Wait InW(SPositionX) = CX(P507) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A2PASS1
				PassStepNum = PassStepNum + 1
				
				Pass A2PASS1
				If NeedAnotherMove(1) Then
					RoutePassP3 = A2PASS2
					PassStepNum = PassStepNum + 1
					Pass A2PASS2
					
					RoutePassP4 = B_2 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_2 +Z(10)
					NeedAnotherMove(1) = False
				EndIf
				Go FinalPosition
			Case 4
				TargetHand = 2
				GoSub ChangeHandAction
				OutW SpositionY, CX(P502)
				Wait InW(SPositionX) = CX(P502) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = A3PASS1
				PassStepNum = PassStepNum + 1
				Pass A3PASS1
				
				RoutePassP3 = A3PASS2
				PassStepNum = PassStepNum + 1
				Pass A3PASS2
				
				RoutePassP4 = A3PASS3
				PassStepNum = PassStepNum + 1
				Pass A3PASS3
				
				If NeedAnotherMove(2) Then
					RoutePassP5 = A3PASS4
					PassStepNum = PassStepNum + 1
					Pass A3PASS4
					
					RoutePassP6 = B_3 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_3 +Z(10)
					NeedAnotherMove(2) = False
				EndIf
				
				Go FinalPosition
			Case 5
				TargetHand = 2
				GoSub ChangeHandAction
				OutW SpositionY, CX(P504)
				Wait InW(SPositionX) = CX(P504) And Sw(INP) = 1
				
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
					
					RoutePassP6 = B_4 +Z(10)
					PassStepNum = PassStepNum + 1
					Pass B_4 +Z(10)
					NeedAnotherMove(3) = False
				EndIf
				
				Go FinalPosition
			Case 6
				TargetHand = 1
				GoSub ChangeHandAction
				OutW SpositionY, CX(P505)
				Wait InW(SPositionX) = CX(P505) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = PCui1P1
				PassStepNum = PassStepNum + 1
				Pass PCui1P1
				
				RoutePassP3 = PCui1P2
				PassStepNum = PassStepNum + 1
				Pass PCui1P2
				
				RoutePassP4 = PCui1P3
				PassStepNum = PassStepNum + 1
				Pass PCui1P3
				
				RoutePassP5 = PCui1P4
				PassStepNum = PassStepNum + 1
				Pass PCui1P4
				
				Go FinalPosition
				
			Case 7
				TargetHand = 1
				GoSub ChangeHandAction
				OutW SpositionY, CX(P504)
				Wait InW(SPositionX) = CX(P504) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = PCui2P1
				PassStepNum = PassStepNum + 1
				Pass PCui2P1
				
				RoutePassP3 = PCui2P2
				PassStepNum = PassStepNum + 1
				Pass PCui2P2
				
				RoutePassP4 = PCui2P3
				PassStepNum = PassStepNum + 1
				Pass PCui2P3
				
				RoutePassP5 = PCui2P4
				PassStepNum = PassStepNum + 1
				Pass PCui2P4
				
				Go FinalPosition
	
		
			Case 8
				TargetHand = 2
				GoSub ChangeHandAction
				OutW SpositionY, CX(P505)
				Wait InW(SPositionX) = CX(P505) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = PCui3P1
				PassStepNum = PassStepNum + 1
				Pass PCui3P1
				
				RoutePassP3 = PCui3P2
				PassStepNum = PassStepNum + 1
				Pass PCui3P2
				
				RoutePassP4 = PCui3P3
				PassStepNum = PassStepNum + 1
				Pass PCui3P3
				
				Go FinalPosition
				
			Case 9
				TargetHand = 2
				GoSub ChangeHandAction
				OutW SpositionY, CX(P504)
				Wait InW(SPositionX) = CX(P504) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = PCui4P1
				PassStepNum = PassStepNum + 1
				Pass PCui4P1
				
				RoutePassP3 = PCui4P2
				PassStepNum = PassStepNum + 1
				Pass PCui4P2
				
				RoutePassP4 = PCui4P3
				PassStepNum = PassStepNum + 1
				Pass PCui4P3
				
				Go FinalPosition
				
			Case 10
				TargetHand = 1
				GoSub ChangeHandAction
				OutW SpositionY, CX(P503)
				Wait InW(SPositionX) = CX(P503) And Sw(INP) = 1
				
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
				
				Go FinalPosition
				
			Case 11
				TargetHand = 1
				GoSub ChangeHandAction
				OutW SpositionY, CX(P505)
				Wait InW(SPositionX) = CX(P505) And Sw(INP) = 1
				
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = ShikePassP1
				PassStepNum = PassStepNum + 1
				Pass ShikePassP1
				
				RoutePassP3 = ShikePassP2
				PassStepNum = PassStepNum + 1
				Pass ShikePassP2
				
				
				Go FinalPosition
		Send

	EndIf
	CurPosition_Num = secendPosition
	For i = 0 To 3
		NeedAnotherMove(i) = False
	Next
'	Position2NeedNeedAnotherMove = False
	Exit Function
	
ChangeHandAction:
	If Hand(Here) = 1 Then
		Jump ChangeHandL /R
	Else
		Jump ChangeHandL /L
	EndIf
	If TargetHand <> Hand(Here) Then
		If InW(SPositionX) <> CX(P504) Then
			SpBox = InW(SPositionX)
			OutW SpositionY, CX(P504)
			Wait InW(SPositionX) <> SpBox
'			Wait 0.5
		EndIf
		If Hand(Here) = 1 Then
			Jump ChangeHandL /L
		Else
			Jump ChangeHandL /R
		EndIf
		
		Wait InW(SPositionX) = CX(P504) And Sw(INP) = 1

	EndIf

Return

Fend
'��ȡ����
'num:��������
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
	Off blownum; On valvenum; On sucknum
	Wait 0.8
	Wait Sw(vacuumnum), 0.2
	Off valvenum
	Wait 1
	If Sw(vacuumnum) = 0 Then
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
					Print "Aצ�ֵ���"
					MsgSend$ = "Aצ�ֵ���"
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
					Print "Bצ�ֵ���"
					MsgSend$ = "Bצ�ֵ���"
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
'�ͷŶ���
'num:��������
'Flexnum:�ξ�����
Function ReleaseAction(num As Integer, Flexnum As Integer)
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
	

	
	If Flexnum <> -1 Then
		Go Here +Z(2.5)
	EndIf

	
    Wait 0.5
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
 		Wait 1
 	EndIf
	
	
 	Off valvenum; Off blownum
	Wait 0.2
	
 	If Flexnum <> -1 Then
 	    Go Here -Z(2.5)
 		On valvenum
 		Wait 0.5
 		If Sw(FlexVoccum1) = 0 Or Sw(FlexVoccum2) = 0 Then
 			CheckFlexVoccum(Flexnum - 1) = True
 		Else
 			CheckFlexVoccum(Flexnum - 1) = False
 		EndIf
 		Off valvenum
 		Wait 0.3
 	EndIf

Fend
'��ȡʧ�ܣ�������
'num:��������
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
'��̨����
Function bgmain
'	Call InitParameter(0)
	Xqt TcpIpCmdRev
	Xqt TcpIpCmdSend
	Xqt TcpIpMsgSend
Fend
'������λ��������
Function TcpIpCmdRev
	Integer chknet1, errTask, i;
	OpenNet #201 As Server
	Print "�˿�201��"
	WaitNet #201
	Print "�˿�201����"
	Do
		OnErr GoTo NetErr
		chknet1 = ChkNet(201)
		If chknet1 >= 0 Then
			Input #201, CmdRev$
			Print "CmdRev$�յ��� " + CmdRev$
			CmdRevStr$(0) = ""
			StringSplit(CmdRev$, ";")
			Select CmdRevStr$(0)
				Case "Select"
					For i = 0 To 3
						If CmdRevStr$(i + 1) = "1" Then
							Tester_Select(i) = True
							NeedChancel(i) = False
						Else
							If Tester_Fill(i) = False Then
								Tester_Select(i) = False
							Else
								If Tester_Select(i) Then
									NeedChancel(i) = True
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

			Send
			CmdRev$ = ""
		Else
			CloseNet #201
			Print "�˿�201�ر�"
			Wait 0.1
			OpenNet #201 As Server
			Print "�˿�201���´�"
			WaitNet #201
			Print "�˿�201��������"
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
'���������λ��
Function TcpIpCmdSend
	Integer chknet2, errTask
	OpenNet #202 As Server
	Print "�˿�202��"
	WaitNet #202
	Print "�˿�202����"
	Do
		OnErr GoTo NetErr
		chknet2 = ChkNet(202)
		If chknet2 >= 0 Then
			If CmdSend$ <> "" Then
				Print #202, CmdSend$
				Print "CmdSend$�� " + CmdSend$
				CmdSend$ = ""
			EndIf
		Else
			CloseNet #202
			Print "�˿�202�ر�"
			Wait 0.1
			OpenNet #202 As Server
			Print "�˿�202���´�"
			WaitNet #202
			Print "�˿�202��������"
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
'������Ϣ����λ��
Function TcpIpMsgSend
	Integer chknet4, errTask
	OpenNet #204 As Server
	Print "�˿�204��"
	WaitNet #204
	Print "�˿�204����"
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
			Print "�˿�204�ر�"
			Wait 0.1
			OpenNet #204 As Server
			Print "�˿�204���´�"
			WaitNet #204
			Print "�˿�204��������"
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
'�ַ����ָ�
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
'���Ի�1���Թ���
Function TesterStart1
	Boolean voccumflag
	
	Do
		If Tester_Select(0) = True Then
			Print "���Ի�AL���ȴ���ʼ����"
			MsgSend$ = "���Ի�AL���ȴ���ʼ����"
			Do While Tester_Testing(0) = False
				If Tester_Select(0) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(0) = True Then
				voccumflag = True
				Tester_Pass(0) = 0
				Tester_Ng(0) = 0
				Tester_Timeout(0) = 0
				Print "���Ի�AL����ʼ����"
				MsgSend$ = "���Ի�AL����ʼ����"
				If CmdSend$ <> "" Then
					Print "������ " + CmdSend$ + " �����ͣ�"
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
'���Ի�2���Թ���
Function TesterStart2
	Boolean voccumflag
	Do
		If Tester_Select(1) = True Then
			Print "���Ի�AR���ȴ���ʼ����"
			MsgSend$ = "���Ի�AR���ȴ���ʼ����"
			Do While Tester_Testing(1) = False
				If Tester_Select(1) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(1) = True Then
				voccumflag = True
				Tester_Pass(1) = 0
				Tester_Ng(1) = 0
				Tester_Timeout(1) = 0
				Print "���Ի�AR����ʼ����"
				MsgSend$ = "���Ի�AR����ʼ����"
				If CmdSend$ <> "" Then
					Print "������ " + CmdSend$ + " �����ͣ�"
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
'���Ի�3���Թ���
Function TesterStart3
	Boolean voccumflag
	Do
		If Tester_Select(2) = True Then
			Print "���Ի�BL���ȴ���ʼ����"
			MsgSend$ = "���Ի�BL���ȴ���ʼ����"
			Do While Tester_Testing(2) = False
				If Tester_Select(2) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(2) = True Then
				voccumflag = True
				Tester_Pass(2) = 0
				Tester_Ng(2) = 0
				Tester_Timeout(2) = 0
				Print "���Ի�BL����ʼ����"
				MsgSend$ = "���Ի�BL����ʼ����"
				If CmdSend$ <> "" Then
					Print "������ " + CmdSend$ + " �����ͣ�"
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
'���Ի�4���Թ���
Function TesterStart4
	Boolean voccumflag
	Do
		If Tester_Select(3) = True Then
			Print "���Ի�BR���ȴ���ʼ����"
			MsgSend$ = "���Ի�BR���ȴ���ʼ����"
			Do While Tester_Testing(3) = False
				If Tester_Select(3) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(3) = True Then
				voccumflag = True
				Tester_Pass(3) = 0
				Tester_Ng(3) = 0
				Tester_Timeout(3) = 0
				Print "���Ի�BR����ʼ����"
				MsgSend$ = "���Ի�BR����ʼ����"
				If CmdSend$ <> "" Then
					Print "������ " + CmdSend$ + " �����ͣ�"
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
	Off PassTrayFull, Forced
	Off NgTrayFull, Forced
	Off Discharing, Forced
Fend







