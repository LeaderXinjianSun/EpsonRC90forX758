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


Global Integer ResetCMDComplete


Global Integer NowFlexIndex

Global Integer Ftarget
Global Integer Ttarget
Global Integer Fcurrent
Global Integer Tcurrent

Global Boolean needreleaseadjust


'GRR
'0,Aצ��{�Ѳ���Ѩ1��}{�Ѳ���Ѩ2��}{�Ѳ���Ѩ3��}{�Ѳ���Ѩ4��}
'1,Bצ
'2,���Ի�Ѩ1
'3,���Ի�Ѩ2
'4,���Ի�Ѩ3
'5,���Ի�Ѩ4
Global Preserve Integer PcsGrrMsgArray(6, 4)
'��Ҫ���Դ���
Global Preserve Integer PcsGrrNeedCount
'��Ҫ���Բ�Ʒ�� 5��5 10��10
Global Preserve Integer PcsGrrNeedNum


Global Preserve Integer PcsGrrNum




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
	Print "�밴��������ʼ��λ"
	MsgSend$ = "�밴��������ʼ��λ"
	Pause
	Call TrapInterruptAbort
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf
    
	
	Call HomeReturnAction

	If Sw(FeedReady) = 0 Then
		Print "�ȴ����Ͻ���"
		MsgSend$ = "�ȴ����Ͻ���"
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
			
			FinalPosition = ChangeHandL
						
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
				Call PickFeedOperate1
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
'GRR
Function main3
	Integer i, j
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

	Wait 0.2
	Off Discharing
	Print "�밴��������ʼ��λ"
	MsgSend$ = "�밴��������ʼ��λ"
	Pause
	Call TrapInterruptAbort
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf
    
	
	Call HomeReturnAction

	If Sw(FeedReady) = 0 Then
		Print "�ȴ����Ͻ���"
		MsgSend$ = "�ȴ����Ͻ���"
		On FeedEmpty
		Off AdjustValve
		FeedReadySigleDown = 0
		FeedPanelNum = 0
	EndIf
	Wait Sw(FeedReady) = 1
	FeedReadySigleDown = 1
	
	
	
	
	
	
main_label2:
	Wait 0.2

	Print "GRRģʽ���ȴ���ʼ"
	MsgSend$ = "GRRģʽ���ȴ���ʼ"
	Pause
	Do
		selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
		If PcsGrrNum > PcsGrrNeedNum Then
			If fillNum = 0 Then 'GRR�������
				TargetPosition_Num = 1
				FinalPosition = ChangeHandL
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				Print "GRRģʽ�����"
				MsgSend$ = "GRRģʽ�����"
				PcsGrrNum = 0
				Exit Do
			Else
				'����ȡ�ϣ�ִ��GRR����
			EndIf

		Else
			If PickHave(0) = False And PickHave(1) = False Then '�ӽ�����ȡ��
				Call PickFeedOperate1
				Call UnloadOperate(0)
				If PickHave(0) Then
					For j = 0 To 4
						PcsGrrMsgArray(0, j) = 0
					Next
					PcsGrrNum = PcsGrrNum + 1
				EndIf
			Else
				'����ȡ�ϣ�ִ��GRR����
			EndIf

		EndIf


	Loop
	GoTo main_label2
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
			'A_1������TesterOperate1����
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
			FinalPosition1 = B_1 +Z(10)
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(10)
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(10)
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(10)
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
	Integer i, j
	For i = 0 To 3
		Tester_Pass(i) = 0
		Tester_Ng(i) = 0
		Tester_Timeout(i) = 0
		Tester_Fill(i) = False
		Tester_Testing(i) = False
	Next
	FeedPanelNum = 0
	For i = 0 To 5
		For j = 0 To 4
			PcsGrrMsgArray(i, j) = 0
		Next
	Next

	
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
		If NgTrayPalletNum < 1 Then
			NgTrayPalletNum = 1
		EndIf
		
		
		
		If FeedReady_ <> Sw(FeedReady) Then
			FeedReady_ = Sw(FeedReady)
			If Sw(FeedReady) = 1 Then
				

				If Sw(PreFill1) = 1 Then
					FeedFill(0) = True
				Else
					FeedFill(0) = False
				EndIf
				If Sw(PreFill2) = 1 Then
					FeedFill(1) = True
				Else
					FeedFill(1) = False
				EndIf
				If Sw(PreFill3) = 1 Then
					FeedFill(2) = True
				Else
					FeedFill(2) = False
				EndIf
				If Sw(PreFill4) = 1 Then
					FeedFill(3) = True
				Else
					FeedFill(3) = False
				EndIf
				If Sw(PreFill5) = 1 Then
					FeedFill(4) = True
				Else
					FeedFill(4) = False
				EndIf
				If Sw(PreFill6) = 1 Then
					FeedFill(5) = True
				Else
					FeedFill(5) = False
				EndIf
				
				Off FeedEmpty, Forced
				On AdjustValve, Forced
				Wait 0.3
				FeedReadySigleDown = 1
				FeedPanelNum = 0
			Else
'				FeedReadySigleDown = 1
				Off FeedEmpty, Forced
			EndIf
		EndIf
		

		
	
	Loop
Fend

'צ��Aȡ����
Function PickFeedOperate1
	Boolean pickfeedflag, fullflag, InWaitPosition
	Integer scanflag
	InWaitPosition = False
PickFeedOperatelabel1:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Discharge = 0 Then
	
		TargetPosition_Num = 1
		FinalPosition = ChangeHandL
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		
		Print "�����̣�δ׼����"
		MsgSend$ = "�����̣�δ׼����"
		Off AdjustValve
		Off DangerOut
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0 Or Sw(DangerIn) = 1
			Wait 0.2
			If Discharge <> 0 And Sw(DangerIn) = 0 Then
                Exit Do
			EndIf
		Loop
		If Discharge = 0 Then
			Print "�����̣�׼����"
			MsgSend$ = "�����̣�׼����"
		EndIf
'		On AdjustValve
'		Wait 0.3
		
	EndIf
	
	If Discharge = 0 Then
		On DangerOut
		On BlowA
		If Sw(RollReset) = 0 And Sw(RollSet) = 0 Then
			Print "�ȴ� ��ת�̵�λ"
			MsgSend$ = "�ȴ� ��ת�̵�λ"
			Wait Sw(RollReset) = 1 Or Sw(RollSet) = 1
			Wait 1.5
		EndIf
		
		If FeedFill(FeedPanelNum) = True Then
			
			TargetPosition_Num = 1
			
			FinalPosition = P(11 + FeedPanelNum)
			
			
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			needreleaseadjust = True
			pickfeedflag = PickAction(0)
			If pickfeedflag = False Then
				Wait 0.5
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
						Print "ɨ��ɹ�"
						Pick_P_Msg(0) = -1

					Default
						Print "ɨ�벻��"
						MsgSend$ = "ɨ�벻��"
'						Pause
						Pick_P_Msg(0) = 1
						
				Send

				

			Else
				Print "�����̣���ȡʧ��"
				MsgSend$ = "�����̣���ȡʧ��"
				Go Here +Z(10)
				Off AdjustValve
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

'�ж��������Ƿ�ȡ��
Function IsFeedPanelEmpty(needwait As Boolean) As Boolean
'	Integer i, j
    LimZ -24
	If FeedPanelNum > 5 Then
		'���̿���
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
			FinalPosition1 = A3PASS1
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

	If Ttarget <> Tcurrent Then
		Print "�����ᣬδ׼����"
		MsgSend$ = "�����ᣬδ׼����"
	EndIf
	Do While Ttarget <> Tcurrent
		Wait 0.02
	Loop
	
	Ttarget = i + 1
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE," + Str$(i + 1)



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
'			If Ttarget <> Tcurrent Then
'				Print "�����ᣬδ׼����"
'				MsgSend$ = "�����ᣬδ׼����"
'			EndIf
'			Do While Ttarget <> Tcurrent
'				Wait 0.02
'			Loop
'			
'			Ttarget = i + 1
'			If CmdSend$ <> "" Then
'				Print "������ " + CmdSend$ + " �����ͣ�"
'			EndIf
'			Do While CmdSend$ <> ""
'				Wait 0.1
'			Loop
'			CmdSend$ = "TMOVE," + Str$(i + 1)
'			
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
			FinalPosition1 = A3PASS1
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
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
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
			FinalPosition1 = A3PASS1
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
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
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
			FinalPosition1 = A3PASS1
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
	
	
	If Ttarget <> Tcurrent Then
		Print "�����ᣬδ׼����"
		MsgSend$ = "�����ᣬδ׼����"
	EndIf
	Do While Ttarget <> Tcurrent
		Wait 0.02
	Loop
	Ttarget = i + 1
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE," + Str$(i + 1)
	
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
'			If Ttarget <> Tcurrent Then
'				Print "�����ᣬδ׼����"
'				MsgSend$ = "�����ᣬδ׼����"
'			EndIf
'			Do While Ttarget <> Tcurrent
'				Wait 0.02
'			Loop
'			Ttarget = i + 1
'			If CmdSend$ <> "" Then
'				Print "������ " + CmdSend$ + " �����ͣ�"
'			EndIf
'			Do While CmdSend$ <> ""
'				Wait 0.1
'			Loop
'			CmdSend$ = "TMOVE," + Str$(i + 1)
			
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
			FinalPosition1 = A3PASS1
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
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
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
			FinalPosition1 = A3PASS1
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
'			Print "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			MsgSend$ = "���Թ�λ" + Str$(i + 1) + "��Bצ�ֵ���"
'			Pause
'			Off SuckB
'			PickHave(1) = False
'		EndIf
'	EndIf
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
		MsgSend$ = "���Թ�λ" + Str$(i + 1) + "����Ʒû�ź�"
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
'Aצ��GRR����
Function GRROperate1
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	
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
	
	If PickHave(0) = True Then
		For i = 0 To 3
			If Tester_Select(i) = True And Tester_Fill(i) = False And PcsGrrMsgArray(0, i) < PcsGrrNeedCount Then
				Exit For
			EndIf
		Next
		If i <= 3 Then
			'�����
			'***************************
			'***************************
			'***************************
			'***************************
			'***************************
		EndIf
	Else
	'צ��Aû��Ʒ	
		selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
		If (selectNum = fillNum Or PcsGrrNum >= PcsGrrNeedNum) And fillNum <> 0 Then
			'����ӽ�����ȡ��
			For i = 0 To 3
				If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				'���в��Ի������ڲ����ж��ڲ�����
				Print "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
				MsgSend$ = "����ѡ�еĲ��Ի������ڲ����С�ǰ��Ԥ��λ�á�"
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
GRROperate1_lable1:
				For i = 0 To 3

					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf

				Next
				If i > 3 Then
					Wait 0.2
					'һֱ�ж�
					GoTo GRROperate1_lable1
				EndIf
				GoTo GRROperate1_lable2
			Else
GRROperate1_lable2:
                GoSub GRROperate1SuckSub
            EndIf
		EndIf
	EndIf
Exit Function

GRROperate1SuckSub:
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
			FinalPosition1 = A3PASS1
			rearnum = 14
		Case 3
'			TargetPosition_Num = 5
			FinalPosition1 = A4PASS3
			rearnum = 15
	Send
	If Sw(rearnum) = 0 Then
		Print "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"
		MsgSend$ = "�Ÿд�����" + Str$(i + 1) + "δ��λ���˶����ȴ�λ��"


		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next

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

'	If Ttarget <> Tcurrent Then
'		Print "�����ᣬδ׼����"
'		MsgSend$ = "�����ᣬδ׼����"
'	EndIf
'	Do While Ttarget <> Tcurrent
'		Wait 0.02
'	Loop
'	
'	Ttarget = i + 1
'	If CmdSend$ <> "" Then
'		Print "������ " + CmdSend$ + " �����ͣ�"
'	EndIf
'	Do While CmdSend$ <> ""
'		Wait 0.1
'	Loop
'	CmdSend$ = "TMOVE," + Str$(i + 1)



	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",B"
	
	PickHave(0) = PickAction(0)
	If PickHave(0) = False Then
		Wait 1
		PickHave(0) = PickAction(0)
	EndIf

	Tester_Fill(i) = False;
	
	If PickHave(0) = True Then
		If Tester_Pass(i) <> 0 Then
'GRR
'0,Aצ��{�Ѳ���Ѩ1��}{�Ѳ���Ѩ2��}{�Ѳ���Ѩ3��}{�Ѳ���Ѩ4��}
'1,Bצ
'2,���Ի�Ѩ1
'3,���Ի�Ѩ2
'4,���Ի�Ѩ3
'5,���Ի�Ѩ4				
			Pick_P_Msg(1) = 0
			NgContinue(i) = 0
			PcsGrrMsgArray(i + 2, i) = PcsGrrMsgArray(i + 2, i) + 1

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
		Print "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		MsgSend$ = "���Ի�" + Str$(i + 1) + "����ȡʧ��"
		Pause
		Off SuckB
	EndIf
Return


Fend
'Bצ��GRR����
Function GRROperate2
	
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
		
		Print "�����ᣬδ׼����"
		MsgSend$ = "�����ᣬδ׼����"
		
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
		Print "������ " + CmdSend$ + " �����ͣ�"
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
	Accel 50, 50
	Go ScanPositionP3L
	Accel 90, 90
	
	
	
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
	
	
	
	
	Go ChangeHandL


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
'			Print "�뽫��е�ֵ���Ϊ��������"
'		EndIf
		If CX(Here) > -50 And CX(Here) < 0 Then
		
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
	Go Here :Y(225)
	Go Here :U(102)
	
	Go ChangeHandL
	
	
'	Pause
	ResetCMDComplete = 0
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "ResetCMD"
	Wait ResetCMDComplete = 1
	Fcurrent = -1
	Ftarget = 5
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "FMOVE,5"
	Wait Fcurrent = 5
	Tcurrent = -1
	Ttarget = 2
	If CmdSend$ <> "" Then
		Print "������ " + CmdSend$ + " �����ͣ�"
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
'·���滮
'firstPosition Ŀ��λ��
'secendPosition ��ǰλ��
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
					Print "������ " + CmdSend$ + " �����ͣ�"
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
'	If needreleaseadjust Then
'		Off AdjustValve
'		Wait 0.05
'	EndIf
	Off blownum; On valvenum; On sucknum
	Wait Sw(vacuumnum), 0.3
		
	If needreleaseadjust Then
		Off AdjustValve
		Wait 0.3
	EndIf
	Off valvenum
	Wait 0.25

	If Sw(vacuumnum) = 0 Then
		If needreleaseadjust Then
			On AdjustValve
'			Wait 0.1
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
	CleanPosition1 = Here +Y(10)
	CleanPosition2 = Here +Y(-10)
	CleanPosition3 = Here
 	On valvenum; On blownum; Off sucknum
 	Accel 10, 10
	For i = 0 To 4
		Pass CleanPosition1
		Go CleanPosition3
		Pass CleanPosition2
		Go CleanPosition3
	Next
	Accel 50, 50
	Go CleanPosition3 ! D1; Off valvenum; Off blownum !
	
	Wait 0.5
Fend
'�ͷŶ���
'num:��������
'Flexnum:�ξ�����
Function ReleaseAction(num As Integer, Flexnum As Integer) '����
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
	
	
 	Wait 0.3


	
 	If Flexnum <> -1 And (Sw(FlexVoccum1) = 0 Or Sw(FlexVoccum2) = 0) Then
 		Off valvenum
 		Wait 0.2
 		NowPosition = Here
 	    Go NowPosition -Z(2.5) ! D1; On valvenum !
 		Wait 0.3  '�ȴ�������ѹ
 		If Sw(FlexVoccum1) = 0 Or Sw(FlexVoccum2) = 0 Then
 			CheckFlexVoccum(Flexnum - 1) = True
 		Else
 			CheckFlexVoccum(Flexnum - 1) = False
 		EndIf
	 	Off valvenum
		Wait 0.3
		If CheckFlexVoccum(Flexnum - 1) = True Then
			Wait 0.45
		EndIf
		Off blownum
	Else
		Off valvenum; Off blownum
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

'				Off AL_Suck, Forced



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
'				Off AR_Suck, Forced
				
				
				
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

'				Off BL_Suck, Forced


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

'				Off BR_Suck, Forced

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

	Off Discharing, Forced
	Off DangerOut, Forced
Fend












