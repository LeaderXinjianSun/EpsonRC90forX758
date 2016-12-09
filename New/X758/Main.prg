Global String CmdRev$, CmdSend$, MsgSend$
Global String CmdRevStr$(20)
Global Integer CurPosition_Num, TargetPosition_Num

Global Boolean NeedChancel(4)

Global Preserve Boolean Tester_Select(4), Tester_Fill(4)
Global Boolean Tester_Testing(4)
Global Preserve Integer Tester_Pass(4), Tester_Ng(4), Tester_Timeout(4)
'治具中的产品为复测产品标志
Global Preserve Boolean Tester_ReTestFalg(4)
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
Global Preserve Boolean FeedFill(6)

Global Boolean PickHave(4)

Global Integer FeedReadySigleDown

Global Preserve Boolean ReTest_


'主函数
Function main
	Trap Emergency Xqt TrapInterruptAbort
	Trap Abort Xqt TrapInterruptAbort
	Trap Error Xqt TrapInterruptAbort
Fend
Function AllMonitor
	Do
		Wait 0.1
		If Sw(FeedReady) = 0 Then
			FeedReadySigleDown = 1
			Off FeedEmpty, Forced
		EndIf
	Loop
Fend
Function test1
	Integer i
	For i = 0 To 2
		
	Next
	Print i
Fend
'爪手A取操作
Function PickFeedOperate1
	Integer i
	Boolean scanflag, pickfeedflag
PickFeedOperatelabel1:
	If Sw(FeedReady) = 0 Or FeedReadySigleDown = 0 Then
		TargetPosition_Num = 1
		FinalPosition = FeedEmptyYield
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0
			Wait 0.2
		Loop
	EndIf
	For i = 0 To 5
		If FeedFill(i) Then
			Exit For
		EndIf
	Next
	If i > 5 Then
		'料盘空了
		Call IsFeedPanelEmpty
		GoTo PickFeedOperatelabel1
	Else
		scanflag = ScanBarcodeOpetate(i, "A")
		If scanflag Then
			TargetPosition_Num = 1
			FinalPosition = P(11 + i)
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			pickfeedflag = PickAction(0)
			FeedFill(i) = False
			PickHave(0) = pickfeedflag
			If pickfeedflag Then
				Call IsFeedPanelEmpty
			Else
				BlowSuckFail(0)
				Call IsFeedPanelEmpty
			EndIf
			
		Else
			FeedFill(i) = False
			Call IsFeedPanelEmpty
		EndIf
	EndIf
Fend
'爪手B取操作
Function PickFeedOperate2
	Integer i
	Boolean scanflag, pickfeedflag
PickFeedOperatelabel2:
	If Sw(FeedReady) = 0 Or FeedReadySigleDown = 0 Then
		TargetPosition_Num = 1
		FinalPosition = FeedEmptyYield
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Do While Sw(FeedReady) = 0 Or FeedReadySigleDown = 0
			Wait 0.2
		Loop
	EndIf
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
			Call IsFeedPanelEmpty
			GoTo PickFeedOperatelabel2
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
				
				Call IsFeedPanelEmpty
			Else
				BlowSuckFail(2)
				Call IsFeedPanelEmpty
				GoTo PickFeedOperatelabel2
			EndIf
			
		Else
			FeedFill(i) = False
			GoTo PickFeedOperatelabel2
		EndIf
	EndIf
Fend
'判断上料盘是否取空
Function IsFeedPanelEmpty
	Integer i
	For i = 0 To 5
		If FeedFill(i) Then
			Exit For
		EndIf
	Next
	If i > 5 Then
		'料盘空了
		Go FeedEmptyYield
		On FeedEmpty
		FeedReadySigleDown = 0
		IsFeedPanelEmpty = True
	Else
		IsFeedPanelEmpty = False
	EndIf
Fend
'A抓手处理测试机程序
Function TesterOperate1
	Integer i, i_index
	Integer rearnum
	Integer selectNum, fillNum, testingNum
	Real realbox
	If PickHave(0) Then
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
		'都满穴
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
						FinalPosition1 = A_1
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = A_2
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = A_3
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = A_4
				Send
				FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
TesterOperate1_lable1:
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
					GoTo TesterOperate1_lable1
				EndIf
				GoTo TesterOperate1_lable2
			Else
TesterOperate1_lable2:
				'取
				Select i
					Case 0
						TargetPosition_Num = 2
						'A_1，依据TesterOperate1更改
						FinalPosition1 = B_1
						rearnum = 4
					Case 1
						TargetPosition_Num = 3
						FinalPosition1 = B_2
						rearnum = 5
					Case 2
						TargetPosition_Num = 4
						FinalPosition1 = B_3
						rearnum = 14
					Case 3
						TargetPosition_Num = 5
						FinalPosition1 = B_4
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
				CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",B"
				
				PickHave(1) = PickAction(1)
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
						
						If ReTest_ = True Then
							If Tester_ReTestFalg(i) = True Then
								Pick_P_Msg(1) = 1
							Else
								Pick_P_Msg(1) = 2 + i
							EndIf
						Else
							Pick_P_Msg(1) = 1
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
				
				'放
				'若被测试机被选择屏蔽，需要先取走产品。
				If NeedChancel(i) = False Then
					GoTo TesterOperate1_lable3
				Else
					Tester_Select(i) = False
					NeedChancel(i) = False
					Go FinalPosition +X(10)
				EndIf
			EndIf
		Else
TesterOperate1_lable3:
		'有空穴
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
			If Sw(rearnum) = 0 Then
				Print "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
				MsgSend$ = "磁感传感器" + Str$(i + 1) + "未到位，运动到等待位置"
				FinalPosition = FinalPosition1 + XY(10, 0, 0, 0)
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			EndIf
			Wait Sw(rearnum) = 1
			FinalPosition = FinalPosition1
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			Call ReleaseAction(0, i + 1)
			Tester_Fill(i) = True;
			If ReTest_ Then
				If Pick_P_Msg(0) = -1 Then
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
			PickAorC$(i) = "A"
		EndIf
	Else
		'排料处理部分
		
	EndIf
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
	FinalPosition = P(1 + num)
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
	Speed 50
	SFree 1, 2
	Pulse 64419, 286952, 0, -17947
	SLock 1
	Pulse 516846, 286952, 0, -17947
	SFree 1
	SLock 2
	Pulse 64419, 286952, 0, -17947
	SLock 1
	Pulse 64419, 286952, 0, -17947
	Power High
	Speed 85
	Accel 90, 90
'	Speed 100, 100, 90
'	SpeedS 100
'	Accel 100, 90, 100, 100, 100, 90
'	AccelS 100, 90
	CurPosition_Num = 7
Fend
'路径规划
'firstPosition 目标位置
'secendPosition 当前位置
Function RoutePlanThenExe(firstPosition As Integer, secendPosition As Integer)
	If firstPosition = secendPosition Then
		Go FinalPosition
	Else
		Select firstPosition
			Case 1
				Select secendPosition
					Case 2
						Jump FinalPosition
					Case 3
						Jump FinalPosition
					Case 4
						Jump FinalPosition
					Case 5
						Jump FinalPosition
					Case 6
						Jump FinalPosition
					Case 7
						Jump FinalPosition
					Case 8
						Jump FinalPosition
				Send
		Send
	EndIf
	CurPosition_Num = secendPosition
Fend
'吸取动作
'num:吸嘴索引
Function PickAction(num As Integer)
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
	Wait 0.2
	Wait Sw(vacuumnum), 0.1
	Off valvenum
	Wait 0.2
	If Sw(vacuumnum) = 0 Then
		PickAction = False
	Else
		PickAction = True
	EndIf
Fend
'释放动作
'num:吸嘴索引
'Flexnum:治具索引
Function ReleaseAction(num As Integer, Flexnum As Integer)
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
	Off blownum; On valvenum
	Wait 0.2
	On blownum; Off sucknum
	Select Flexnum
		Case 1
			On AL_Suck
		Case 2
			On AR_Suck
		Case 3
			On BL_Suck
		Case 4
			On BR_Suck
	Send
	Wait 0.05
	Off blownum
	Wait 0.1
	On blownum
	Wait 0.05
 	Off blownum
 	Wait 0.1
 	Off valvenum
	Wait 0.2
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
	Integer chknet1, errTask;
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
				Case "Coord"
					CmdSend$ = "Coord," + Str$(CX(Here)) + "," + Str$(CY(Here)) + "," + Str$(CZ(Here)) + "," + Str$(CU(Here))
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
	
	Do
		If Tester_Select(0) = True Then
			Print "测试机1，等待开始测试"
			MsgSend$ = "测试机1，等待开始测试"
			Do While Tester_Testing(0) = False
				If Tester_Select(0) = False Then
					Exit Do
				EndIf
				Wait 0.2
			Loop
			If Tester_Testing(0) = True Then
				
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
				Do While Not (Tester_Pass(0) <> 0 Or Tester_Ng(0) <> 0 Or Tester_Timeout(0) <> 0)
					TesterTimeElapse(0) = Tmr(0)
				
					If Tester_Select(0) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop
				On AL_Suck, Forced
				Wait Sw(ALRear) = 1 And Sw(ALUp) = 1
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
Function TrapInterruptAbort
	Integer i
	Out 0, 0, Forced
	Out 1, 0, Forced
'	For i = 0 To 3
'		Pick_Have(i) = False
'	Next
'	Discharge = 0

Fend

