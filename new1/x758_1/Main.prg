'ver 20170710.01
'1、上传软体异常，报警后仍可继续，但下一pcs仍报警

Global String CmdRev$, CmdSend$, MsgSend$, CmdRevFlex$, CmdSendFlex$
Global String CmdRevStr$(20), CmdRevFlexStr$(20)
Global Integer CurPosition_Num, TargetPosition_Num


Global Boolean NeedChancel(4)

Global Preserve Boolean Tester_Select(4), Tester_Fill(4)
Global Boolean Tester_Testing(4)
Global Preserve Integer Tester_Pass(4), Tester_Ng(4), Tester_Timeout(4)
Global Preserve Integer Tester_Remark(4)
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
'Pick_Remark
'0:正常
'1:Noise不良
Global Integer Pick_Remark(2)
Global Real TesterTimeElapse(4)

Global Integer ScanResult
Global Preserve Boolean PreFeedFill(6)
Global Preserve Boolean FeedFill(6)

Global Boolean PickHave(4)
Global Preserve Integer PassTrayPalletNum, NgTrayPalletNum, NoiseTrayPalletNum
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
Global Preserve Boolean isCheckUpload

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

Global Integer pickRetryTimes

Global Preserve Integer IndexArray_i(4)

Global Boolean PcsLostAlarm1
Global Boolean PcsLostAlarm2

Global Integer SelectSampleResultfromDtFinish

Global Preserve Integer Delta_Z
Global Preserve Integer Delta_Z1
Global Preserve Integer Delta_Z_Release
Global Preserve Integer Delta_Z_Release1
Global Boolean PickFeedFirstSuck
Global Boolean PickFlexFirstSuck
'GRR
'0,A爪；{已测试穴1数}{已测试穴2数}{已测试穴3数}{已测试穴4数}
'1,B爪
'2,测试机穴1
'3,测试机穴2
'4,测试机穴3
'5,测试机穴4
Global Preserve Integer PcsGrrMsgArray(6, 4)
'需要测试次数
Global Preserve Integer PcsGrrNeedCount
'需要测试产品数 5×5 10×10
Global Preserve Integer PcsGrrNeedNum


Global Preserve Integer PcsGrrNum
Global Integer GRRTimesAsk

'******************************* 样本程序 ******************************************

'[ NG3  ][ NG2  ]
'[ PASS ][ NG1  ]
Global Preserve Boolean SamPanelHave(8)
Global Preserve Boolean SamPanelHave_Back(8)
Global Preserve Integer SamRetestHave_index(8)
'0,A爪；{PASS}{NG1}{NG2}{NG3}
'1,B爪
'2,测试机穴1
'3,测试机穴2
'4,测试机穴3
'5,测试机穴4
Global Preserve Boolean SamTestRecord(6, 10)
'0,测试机穴1；{PASS}{NG1}{NG2}{NG3}
'1,测试机穴2
'2,测试机穴3
'3,测试机穴4
Global Preserve Boolean SamTestResult(4, 10)
'0,未测
'1,项目1
'2,项目2
'3,项目3
'4,项目4
Global Preserve Integer SamTestNowItems(10)
Global Boolean NeedSamAction
Global Preserve Boolean SamActionFlag
Global Boolean SamActionFinishFlag

Global Preserve Integer SamNeedItemsNum
Global Boolean SamNeedItems(10)
Global Integer SamSearchflag
Global Boolean SamScanResult_Fail
Global Integer SamRetest
Global Boolean SamScanNewPcs

'******************************* 结束 ********************************************
'******************************* 检测上传软体 ********************************************
Global Boolean StatusOfUpload(4)
Global Integer StatusOfUploadFinish
'******************************* 检测上传软体结束 ********************************************

'******************************* 检测停机良率 ********************************************
Global Boolean StatusOfYield(4)
Global Integer StatusOfYieldFinish
Global Preserve Boolean IsPassLowLimitStop
'******************************* 检测停机良率结束 ********************************************

'******************************* 比对INI ********************************************
Global Boolean FromWhichFlex(2)
'0:unknow
'1:ok
'2:ng
Global Integer CheckBarcodeResult
Global Preserve Boolean IsCheckINI
'******************************* 比对INI率结束 ********************************************

Global Boolean ReStart_flag

Global Integer ReleaseFailFlexIndex
'0 A爪手
'1 B爪手
Global Integer ReleaseFailPickNum



Function main
	
	Do
		Wait 1
	Loop

Fend
'正常
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
	Xqt AllMonitor, NoPause
'	Call InitAction
	Wait 0.2
	Off Discharing
	Print "请按继续，开始复位"
	MsgSend$ = "请按继续，开始复位"
	Pause
	Call TrapInterruptAbort
	On AdjustValve
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf

    
	If NgTrayPalletNum < 1 Or NgTrayPalletNum > 8 Then
		NgTrayPalletNum = 1
	EndIf
	If NoiseTrayPalletNum < 1 Or NoiseTrayPalletNum > 6 Then
		NoiseTrayPalletNum = 1
	EndIf
	ReleaseFailFlexIndex = -1
	Call HomeReturnAction

'	ReStart_flag = False
	ReStart_flag = True
	Off FeedEmpty
	Wait 0.5
'	For i = 0 To 5
'    	If FeedFill(i) Then
'    		ReStart_flag = True
'    	EndIf
'    Next
    If Not ReStart_flag Then
		Print "等待上料结束"
		MsgSend$ = "等待上料结束"
		Off RollValve
		On FeedEmpty
		Off AdjustValve
		FeedReadySigleDown = 0
		FeedPanelNum = 0
		Wait Sw(FeedReady) = 1
		FeedReadySigleDown = 1
	Else
		Print "请确认，不得取走上料盘产品"
		MsgSend$ = "请确认，不得取走上料盘产品"
		On AdjustValve
		Pause
    EndIf

	
	
	
main_label1:
	Wait 0.2
	
	fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
	
	If fillNum = 0 Then
		If Not SamActionFlag Then
			
			If CleanActionFlag Then
				Print "清洁操作，开始"
				MsgSend$ = "清洁操作，开始"
				Wait 1
				Call CleanActionProcess
				Wait 1
				Print "清洁操作，结束"
				MsgSend$ = "清洁操作，结束"
				Wait 1
				CleanActionFlag = False
				CleanActionFinishFlag = True
				Discharge = 0
				Off Discharing, Forced
			EndIf
		Else
			Print "样本测试，开始"
			MsgSend$ = "样本测试，开始"
			Wait 1
			Call SamActionProcess
			Wait 1
			Print "样本测试，结束"
			MsgSend$ = "样本测试，结束"
			Wait 1
			SamActionFlag = False
			SamActionFinishFlag = True
			Discharge = 0
			Off Discharing, Forced
		EndIf
	EndIf


	
	If Not CleanActionFinishFlag And Not SamActionFinishFlag Then
		Print "请按继续，开始运行"
		MsgSend$ = "请按继续，开始运行"
		Pause
	ElseIf CleanActionFinishFlag Then
		CleanActionFinishFlag = False
	Else
		SamActionFinishFlag = False
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
			If Not NeedSamAction Then
				If NeedCleanAction Then
					NeedCleanAction = False
					CleanActionFlag = True
				Else
					Discharge = 0
					Off Discharing, Forced
				EndIf
			Else
				NeedSamAction = False
				SamActionFlag = True
			EndIf

			Exit Do
		EndIf
		If PickHave(0) = False And PickHave(1) = False And Discharge = 0 Then
			Call CheckUploadStatus
			Call CheckYieldStatus
			Call PickFeedOperate1
		EndIf
		Call UnloadOperate(0)
		'处理A爪头
		Call TesterOperate1
		Call UnloadOperate(1)
		If ReleaseFailFlexIndex <> -1 Then
			Call TesterOperateReleaseFail
			Call UnloadOperate(ReleaseFailPickNum)
		EndIf
        '处理B爪头
		Call TesterOperate2
		Call UnloadOperate(0)
		If ReleaseFailFlexIndex <> -1 Then
			Call TesterOperateReleaseFail
			Call UnloadOperate(ReleaseFailPickNum)
		EndIf

	Loop
	GoTo main_label1
Fend
Function CheckUploadStatus
		
	Integer i
CheckUploadStatusLabel1:
	If isCheckUpload Then
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "StatusOfUpload"
		StatusOfUploadFinish = 0
		Wait StatusOfUploadFinish <> 0
		For i = 0 To 3
			If Not StatusOfUpload(i) And isCheckUpload And Tester_Select(i) Then
				Print "测试机" + Str$(i + 1) + "，上传软体异常"
				MsgSend$ = "测试机" + Str$(i + 1) + "，上传软体异常"
				Pause
				Wait 1
'				GoTo CheckUploadStatusLabel1
			EndIf
		Next
	EndIf
Fend
Function CheckYieldStatus
		
	Integer i
CheckYieldStatusLabel1:
	If IsPassLowLimitStop Then
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "StatusOfYield"
		StatusOfYieldFinish = 0
		Wait StatusOfYieldFinish <> 0
		For i = 0 To 3
			If Not StatusOfYield(i) And IsPassLowLimitStop And Tester_Select(i) Then
				Print "测试机" + Str$(i + 1) + "，良率异常"
				MsgSend$ = "测试机" + Str$(i + 1) + "，良率异常"
				Pause
				Wait 1
				GoTo CheckYieldStatusLabel1
			EndIf
		Next
	EndIf
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
	Xqt AllMonitor, NoPause
'	Call InitAction
	Wait 0.2
	Off Discharing
	Print "GRR模式，请按继续，开始复位"
	MsgSend$ = "GRR模式，请按继续，开始复位"
	Pause
	Call TrapInterruptAbort
	If FeedPanelNum < 3 Then
		Off RollValve
	Else
		On RollValve
	EndIf
    
	
	Call HomeReturnAction
	
	Wait 0.2
	fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
	If fillNum <> 0 Then
		Print "测试机有料，请清空"
		MsgSend$ = "测试机有料，请清空"
		Pause
	EndIf
	
    Call ClearAction

	ReStart_flag = False
	Off FeedEmpty
	Wait 0.5
	For i = 0 To 5
    	If FeedFill(i) Then
    		ReStart_flag = True
    	EndIf
    Next
    If Not ReStart_flag Then
		Print "等待上料结束"
		MsgSend$ = "等待上料结束"
		Off RollValve
		On FeedEmpty
		Off AdjustValve
		FeedReadySigleDown = 0
		FeedPanelNum = 0
		Wait Sw(FeedReady) = 1
		FeedReadySigleDown = 1
	Else
		Print "请确认，不得取走上料盘产品"
		MsgSend$ = "请确认，不得取走上料盘产品"
		On AdjustValve
		Pause
    EndIf
	
	
	
main_label3:
	Wait 0.2

	Print "GRR模式，等待开始"
	MsgSend$ = "GRR模式，等待开始"
	
	GRRTimesAsk = 0
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "GRRTimesAsk"
	Wait GRRTimesAsk <> 0
	
	
		
	
	Pause
	
	PcsGrrNum = 0
	For i = 0 To 5
		For j = 0 To 3
			PcsGrrMsgArray(i, j) = 0
		Next
	Next
	Do
		selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
		fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
		If PcsGrrNum >= PcsGrrNeedNum Then
			If fillNum = 0 And PickHave(0) = False And PickHave(1) = False Then 'GRR测试完成
				TargetPosition_Num = 1
				FinalPosition = ChangeHandL
				Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
				Print "GRR模式，完成"
				MsgSend$ = "GRR模式，完成"
				PcsGrrNum = 0
				Exit Do
			Else
				'不再取料，执行GRR处理
			EndIf

		Else
			If PickHave(0) = False And PickHave(1) = False And selectNum <> fillNum And selectNum <> 0 Then '从矫正盘取料
				Call PickFeedOperate1
				'扫码失败处理
				Call UnloadOperate(0)
				If PickHave(0) Then
					'新产品赋值
					For j = 0 To 4
						PcsGrrMsgArray(0, j) = 0
					Next
					PcsGrrNum = PcsGrrNum + 1
				EndIf
			Else
				'不再取料，执行GRR处理
			EndIf

		EndIf
		
		Call GRROperate1
		Call GRRUnloadOperate(0)
		Call GRROperate2
		
		Call GRRUnloadOperate(1)
	Loop
	GoTo main_label3
Fend
'******************************* 样本程序 ******************************************

'[ NG3  ][ NG2  ]
'[ PASS ][ NG1  ]
'Global Preserve Boolean SamPanelHave(4)
'0,A爪；{PASS}{NG1}{NG2}{NG3}
'1,B爪
'2,测试机穴1
'3,测试机穴2
'4,测试机穴3
'5,测试机穴4
'Global Preserve Boolean SamTestRecord(6, 4)
'0,测试机穴1；{PASS}{NG1}{NG2}{NG3}
'1,测试机穴2
'2,测试机穴3
'3,测试机穴4
'Global Preserve Boolean SamTestResult(4, 4)
'0,未测
'1,项目1
'2,项目2
'3,项目3
'4,项目4
'Global Preserve Integer SamTestNowItems(4)
'Global Boolean NeedSamAction
'Global Preserve Boolean SamActionFlag
'Global Boolean SamActionFinishFlag

'Global Preserve Integer SamNeedItemsNum
'Global Boolean SamNeedItems(4)
'Tester_Select(4), Tester_Fill(4)

'******************************* 结束 ********************************************
Function SamIsNeedPcs
	Integer i, j
	If SamNeedItemsNum > 10 Then
		SamNeedItemsNum = 10
	EndIf
	For i = 0 To SamNeedItemsNum - 1
		SamNeedItems(i) = False
	Next
	For i = 0 To SamNeedItemsNum - 1
		For j = 0 To 3
'			If SamTestRecord(j + 2, i) = False And Tester_Select(j) = True And Tester_Fill(j) = False Then
			If SamTestRecord(j + 2, i) = False And Tester_Select(j) = True Then
				SamNeedItems(i) = True
				Exit For
			EndIf
		Next
	Next
	'返回有需求的项目 SamNeedItems(4)
Fend
Function SamPickfromPanel
	Integer i, scanflag
	Boolean pickfeedflag
	For i = 0 To 7
		If SamPanelHave(i) = True Then
			Exit For
		EndIf
	Next
'	SamScanNewPcs = False
	
	If i > 7 Then
		'样品盘没料
		For i = 0 To 3
			If Tester_Select(i) = True And Tester_Fill(i) = True Then
				Exit For
			EndIf
		Next
		If i > 3 Then
			'全空穴
			'等待
			TargetPosition_Num = 7
			FinalPosition = SamplePass2
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			Print "样本盘缺料"
			MsgSend$ = "样本盘缺料"
			Pause
		EndIf
	Else
		'取料
		TargetPosition_Num = 7
		FinalPosition = P(128 + i) +Z(Delta_Z)
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		
	
		
		
		
		
		
		
		
		
		
		
		PickFlexFirstSuck = True
		pickRetryTimes = 0
		pickfeedflag = PickAction(0)
		If pickfeedflag = False Then
			pickRetryTimes = pickRetryTimes + 1
'			Wait 0.5
			pickfeedflag = PickAction(0)
		EndIf
		SamPanelHave(i) = False
		SamPanelHave_Back(i) = False
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SamPanelHave,False," + Str$(i)
		
		PickHave(0) = pickfeedflag
		If PickHave(0) Then
			On DangerOut
			TargetPosition_Num = 1
			FinalPosition = ScanPositionP3L
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
			SamScanResult_Fail = False
			scanflag = ScanBarcodeOpetateP3("A")
			Select scanflag
				Case 1
					Print "扫码成功"
					For i = 0 To SamNeedItemsNum - 1
						SamTestRecord(0, i) = False
					Next
					SamScanResult_Fail = False
					'A爪手有料
					'查询A爪手条码
					SamSearchflag = 0
					If CmdSend$ <> "" Then
						Print "有命令 " + CmdSend$ + " 待发送！"
					EndIf
					Do While CmdSend$ <> ""
						Wait 0.1
					Loop
					CmdSend$ = "SamDBSearch,A"
					Wait SamSearchflag = 1
				Default
					Print "扫码不良"
					MsgSend$ = "扫码不良"
					SamScanResult_Fail = True
					
			Send
		Else
			Print "样本盘，吸取失败"
			MsgSend$ = "样本盘，吸取失败"
			Go Here +Z(10)
			On Alarm_SuckFail
			Pause
			Off Alarm_SuckFail
		EndIf
	EndIf

Fend
Function SamActionProcess
	Integer i, j, k
	Boolean SamFail
'	SamNeedItemsNum = 2
	For i = 0 To 4
		For j = 0 To SamNeedItemsNum - 1
			
			SamTestRecord(i + 2, j) = False
			SamTestResult(i, j) = False
		
		Next
	Next
	For i = 0 To 7
		Wait 0.2
		SamPanelHave(i) = False
		SamPanelHave_Back(i) = False
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SamPanelHave,False," + Str$(i)

	Next
SamActionProcess_label1:
	Do
		Call SamIsNeedPcs
		For i = 0 To SamNeedItemsNum - 1
			If SamNeedItems(i) Then
				Exit For
			EndIf
		Next

				
		If PickHave(0) = False And PickHave(1) = False Then
			If i <= SamNeedItemsNum - 1 Then
				'有需求
				Call SamPickfromPanel
			Else
				'无需求
				For i = 0 To 3
					If Tester_Select(i) = True And Tester_Fill(i) = True Then
						Exit For
					EndIf
				Next
				If i > 3 Then
					'全空
					'此轮样本测完
					Exit Do
				EndIf
			EndIf
		Else
			
		EndIf
		
		
		
		Call SamUnload(0)

		
		Call SamOperate1
		Call SamUnload(1)
		Call SamOperate2
		Call SamUnload(0)
		
	Loop
	'判断样本是否测试正确
	Print "延时30秒，等待查询样本测试结果"
	MsgSend$ = "延时30秒，等待查询样本测试结果"
	Wait 30
	SelectSampleResultfromDtFinish = 0
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "SelectSampleResultfromDt"
	Wait SelectSampleResultfromDtFinish = 1
	
	SamFail = False
	SamRetest = 0
	For i = 0 To 4
		For j = 0 To SamNeedItemsNum - 1
			If Tester_Select(i) = True And SamTestResult(i, j) = False Then
				SamFail = True
				For k = 0 To 7
					If SamRetestHave_index(k) = j And SamPanelHave_Back(k) = True Then
						Wait 0.2
						SamPanelHave(k) = True
						SamPanelHave_Back(k) = False
						If CmdSend$ <> "" Then
							Print "有命令 " + CmdSend$ + " 待发送！"
						EndIf
						Do While CmdSend$ <> ""
							Wait 0.1
						Loop
						CmdSend$ = "SamPanelHave,True," + Str$(k)
					EndIf
				Next
			EndIf
		Next
	Next
	If SamFail Then
		Print "样本测试错误"
		MsgSend$ = "样本测试错误"
	
		Pause
'		If SamRetest = 1 Then
'			For i = 0 To 4
'				For j = 0 To SamNeedItemsNum - 1
'					If SamTestResult(i, j) = False Then
'						SamTestRecord(i + 2, j) = False
'					EndIf
'				Next
'			Next
'			GoTo SamActionProcess_label1
'		EndIf
		For i = 0 To 4
			For j = 0 To SamNeedItemsNum - 1
				If SamTestResult(i, j) = False Then
					SamTestRecord(i + 2, j) = False
				EndIf
			Next
		Next
		GoTo SamActionProcess_label1
	Else
		
	EndIf
	TargetPosition_Num = 1
	FinalPosition = ChangeHandL
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	
Fend
'A爪手处理样本
  Function SamOperate1
	
	Integer i, j, rearnum, voccumValue1, voccumValue2, i_index, item_i
	Real realbox
	String FlexNowTest$, SampleResult$
	If PickHave(0) Then
'		'A爪手有料
'		'查询A爪手条码
'		SamSearchflag = 0
'		If CmdSend$ <> "" Then
'			Print "有命令 " + CmdSend$ + " 待发送！"
'		EndIf
'		Do While CmdSend$ <> ""
'			Wait 0.1
'		Loop
'		CmdSend$ = "SamDBSearch,A"
'		Wait SamSearchflag = 1
		'判断是否符合要求
		Call SamIsNeedPcs
		For i = 0 To SamNeedItemsNum - 1
			If SamTestRecord(0, i) And SamNeedItems(i) Then
				Exit For
			EndIf
		Next
		If i > SamNeedItemsNum - 1 Then
			'无需求
			'直接下料
		Else
			item_i = i '不良项
			For i = 0 To 3
				If SamTestRecord(i + 2, item_i) = False And Tester_Fill(i) = False And Tester_Select(i) Then
					Exit For
				EndIf
			Next
			If i <= 3 Then
				'有需求
				'存在空穴，直接放
				GoSub SamOperate1ReleaseSub
			Else
				'该类不良样本，穴都满（都在测试中）
				For i = 0 To 3
					If SamTestRecord(i + 2, item_i) = False And Tester_Fill(i) = True And Tester_Testing(i) = False And Tester_Select(i) Then
						Exit For
					EndIf
				Next
				If i > 3 Then
					'所有测试机，都在测试中都在测试中。执行等待
					Print "所有选中的测试机，都在测试中。前往预判位置。"
					MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 1
					If Tester_Select(i) = True And Tester_Fill(i) = True And SamTestRecord(i + 2, item_i) = False Then
						If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
							realbox = TesterTimeElapse(i)
							i_index = i
						EndIf
					EndIf
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
SamOperate1_lab1:
					For i = 0 To 3
	
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False And SamTestRecord(i + 2, item_i) = False Then
							Exit For
						EndIf
						
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo SamOperate1_lab1
					EndIf
					GoTo SamOperate1_lab2
				Else
SamOperate1_lab2:
					'吸取动作
					GoSub SamOperate1SuckSub
					If SamTestRecord(i + 2, item_i) = False Then
						GoSub SamOperate1ReleaseSub
					EndIf
					
				EndIf
			EndIf
			

		EndIf
	ElseIf PickHave(1) = False Then
		'A爪手空且B爪手空
		Call SamIsNeedPcs
		For i = 0 To SamNeedItemsNum - 1
			If SamNeedItems(i) Then
				Exit For
			EndIf
		Next
		If i > SamNeedItemsNum - 1 Then
			'无需求
			For i = 0 To 3
				If Tester_Select(i) = True And Tester_Fill(i) = True Then
					Exit For
				EndIf
			Next
			If i <= 3 Then
				'存在满穴	
				
				
				For i = 0 To 3
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				Next
				
				If i > 3 Then
					'所有测试机，都在测试中都在测试中
					Print "所有选中的测试机，都在测试中。前往预判位置。"
					MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 1
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
SamOperate1_lable1:
					For i = 0 To 3

						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo SamOperate1_lable1
					EndIf
					GoTo SamOperate1_lable2
				Else
SamOperate1_lable2:
	                GoSub SamOperate1SuckSub
				
				
				EndIf
			
			Else
				'全空穴	
			EndIf
		Else
			'有需求
			For i = 0 To 3
				If Tester_Select(i) = True And Tester_Fill(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				'全空穴
				'退出
			Else
				'存在满穴
				
				
				For i = 0 To 7
					If SamPanelHave(i) Then
						Exit For
					EndIf
				Next
				If i > 7 Then
					'样本盘无料	
					
					For i = 0 To 3
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Next
					
					If i > 3 Then
						'所有测试机，都在测试中都在测试中
						Print "所有选中的测试机，都在测试中。前往预判位置。"
						MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
						realbox = 0
						i_index = 1
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
SamOperate1_lable3:
						For i = 0 To 3
	
							If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
								Exit For
							EndIf
						
						Next
						If i > 3 Then
							Wait 0.2
							'一直判断
							For i = 0 To 7
								If SamPanelHave(i) Then
									Exit For
								EndIf
							Next
							If i > 7 Then
								GoTo SamOperate1_lable3
							Else
								'被样本盘有料打断
								GoTo SamOperate1_lable5
							EndIf
							
						EndIf
						GoTo SamOperate1_lable4

					Else
SamOperate1_lable4:
		                GoSub SamOperate1SuckSub
					
					EndIf
			
				Else
SamOperate1_lable5:
					'样本盘有料
					'退出

				EndIf

			EndIf
		EndIf
	
		
	EndIf
	Exit Function
	
SamOperate1ReleaseSub:
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
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4 +Z(Delta_Z)
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
	
SamOperateReLabel1:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
		FinalPosition = Here
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		GoTo SamOperateReLabel1
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

	SamTestRecord(i + 2, item_i) = True
	SamTestNowItems(i) = item_i + 1
Return
	
SamOperate1SuckSub:
SamOperate1SuckSubLabel1:
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
	FinalPosition = FinalPosition1 +Z(Delta_Z)

	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next



	
	PickFlexFirstSuck = True
	pickRetryTimes = 0
	PickHave(1) = PickAction(1)
	If PickHave(1) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(1) = PickAction(1)
	EndIf



	If PickHave(1) = True Then
	
	
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",B"
	
		Tester_Fill(i) = False;
		
'		Select i
'			Case 0
'	'				TargetPosition_Num = 2
'				'A_1，依据TesterOperate1更改
'				FinalPosition1 = A1PASS1
'	'				Position2NeedNeedAnotherMove = True
'				
'				rearnum = 4
'			Case 1
'	'				TargetPosition_Num = 3
'				FinalPosition1 = A2PASS1
'				
'				rearnum = 5
'			Case 2
'	'				TargetPosition_Num = 4
'				FinalPosition1 = A3PASS1
'				rearnum = 14
'			Case 3
'	'				TargetPosition_Num = 5
'				FinalPosition1 = A4PASS3
'				rearnum = 15
'		Send
'	'		Go FinalPosition1
'		TargetPosition_Num = -2
'		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'		For j = 0 To 3
'			isInWaitPosition(j) = False
'		Next
		
		If Tester_Pass(i) <> 0 Then
				
			Pick_P_Msg(1) = 0
			NgContinue(i) = 0
			
	'		SampleResult$ = "OK"
			'PASS项目测试结果
	'		If SamTestNowItems(i) = 1 Then
	'			SamTestResult(i, 0) = True
	'		Else
	'			SamTestResult(i, 0) = False
	'		EndIf
			
			Select SamTestNowItems(i)
				Case 1
					SamTestResult(i, 0) = True
					SampleResult$ = "OK"
				Case 2
					SamTestResult(i, 1) = False
					SampleResult$ = "OK"
				Case 3
					SamTestResult(i, 2) = False
					SampleResult$ = "OK"
				Case 4
					SamTestResult(i, 3) = False
					SampleResult$ = "OK"
				Case 5
					SamTestResult(i, 4) = False
					SampleResult$ = "OK"
				Case 6
					SamTestResult(i, 5) = False
					SampleResult$ = "OK"
				Case 7
					SamTestResult(i, 6) = False
					SampleResult$ = "OK"
				Case 8
					SamTestResult(i, 7) = False
					SampleResult$ = "OK"
				Case 9
					SamTestResult(i, 8) = False
					SampleResult$ = "OK"
				Case 10
					SamTestResult(i, 9) = False
					SampleResult$ = "OK"
				Default
			Send
	
		Else
			'NG项目测试结果
	'		SampleResult$ = "NG"
	'		If SamTestNowItems(i) = 2 Then
	'			SamTestResult(i, 1) = True
	'		Else
	'			SamTestResult(i, 1) = False
	'		EndIf
	'		
			Select SamTestNowItems(i)
				Case 1
					SamTestResult(i, 0) = False
					SampleResult$ = "NG"
				Case 2
					SamTestResult(i, 1) = True
					SampleResult$ = "NG"
				Case 3
					SamTestResult(i, 2) = True
					SampleResult$ = "NG1"
				Case 4
					SamTestResult(i, 3) = True
					SampleResult$ = "NG2"
				Case 5
					SamTestResult(i, 4) = True
					SampleResult$ = "NG3"
				Case 6
					SamTestResult(i, 5) = True
					SampleResult$ = "NG4"
				Case 7
					SamTestResult(i, 6) = True
					SampleResult$ = "NG5"
				Case 8
					SamTestResult(i, 7) = True
					SampleResult$ = "NG6"
				Case 9
					SamTestResult(i, 8) = True
					SampleResult$ = "NG7"
				Case 10
					SamTestResult(i, 9) = True
					SampleResult$ = "NG8"
				Default
			Send
	
		EndIf
			
		
		Select SamTestNowItems(i)
			Case 1
				FlexNowTest$ = "OK"
			Case 2
				FlexNowTest$ = "NG"
			Case 3
				FlexNowTest$ = "NG1"
			Case 4
				FlexNowTest$ = "NG2"
			Case 5
				FlexNowTest$ = "NG3"
			Case 6
				FlexNowTest$ = "NG4"
			Case 7
				FlexNowTest$ = "NG5"
			Case 8
				FlexNowTest$ = "NG6"
			Case 9
				FlexNowTest$ = "NG7"
			Case 10
				FlexNowTest$ = "NG8"
			Default
				
		Send
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SampleResult," + Str$(i + 1) + "," + FlexNowTest$ + "," + SampleResult$
	
	
	
	
	
	
		If Tester_Pass(i) <> 0 Then
				
			Pick_P_Msg(1) = 0
			NgContinue(i) = 0

		Else
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf

		EndIf
		'B爪手有料
		'查询B爪手条码
		If PickHave(0) = False Then
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
		Else
			Wait 0.2
		EndIf
		
		SamSearchflag = 0
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SamDBSearch,B"
		Wait SamSearchflag = 1
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





		Print "测试机" + Str$(i + 1) + "，样本 吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，样本 吸取失败"
		On Alarm_SuckFail
		Pause
		Off Alarm_SuckFail
		Off SuckB
		GoTo SamOperate1SuckSubLabel1
	EndIf
Return
	
	
Fend
'B爪手处理样本
Function SamOperate2
	
	
	Integer i, j, rearnum, voccumValue1, voccumValue2, i_index, item_i
	Real realbox
	String FlexNowTest$, SampleResult$
	If PickHave(1) Then
'		'B爪手有料
'		'查询B爪手条码
'		SamSearchflag = 0
'		If CmdSend$ <> "" Then
'			Print "有命令 " + CmdSend$ + " 待发送！"
'		EndIf
'		Do While CmdSend$ <> ""
'			Wait 0.1
'		Loop
'		CmdSend$ = "SamDBSearch,B"
'		Wait SamSearchflag = 1
		'判断是否符合要求
		Call SamIsNeedPcs
		For i = 0 To SamNeedItemsNum - 1
			If SamTestRecord(1, i) And SamNeedItems(i) Then
				Exit For
			EndIf
		Next
		If i > SamNeedItemsNum - 1 Then
			'无需求
			'直接下料
		Else
			item_i = i
			For i = 0 To 3
				If SamTestRecord(i + 2, item_i) = False And Tester_Fill(i) = False And Tester_Select(i) Then
					Exit For
				EndIf
			Next
			If i <= 3 Then
				'有需求
				GoSub SamOperate2ReleaseSub
			Else
				'该类不良样本，穴都满（都在测试中）
				For i = 0 To 3
					If SamTestRecord(i + 2, item_i) = False And Tester_Fill(i) = True And Tester_Testing(i) = False And Tester_Select(i) Then
						Exit For
					EndIf
				Next
				If i > 3 Then
					'所有测试机，都在测试中都在测试中。执行等待
					Print "所有选中的测试机，都在测试中。前往预判位置。"
					MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 1
					If Tester_Select(i) = True And Tester_Fill(i) = True And SamTestRecord(i + 2, item_i) = False Then
						If realbox < TesterTimeElapse(i) And TesterTimeElapse(i) < 100 Then
							realbox = TesterTimeElapse(i)
							i_index = i
						EndIf
					EndIf
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
SamOperate2_lab1:
					For i = 0 To 3
	
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False And SamTestRecord(i + 2, item_i) = False Then
							Exit For
						EndIf
						
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo SamOperate2_lab1
					EndIf
					GoTo SamOperate2_lab2
				Else
SamOperate2_lab2:
					'吸取动作
					GoSub SamOperate2SuckSub
					If SamTestRecord(i + 2, item_i) = False Then
						GoSub SamOperate2ReleaseSub
					EndIf
				EndIf
			EndIf

		EndIf
	ElseIf PickHave(0) = False Then
		'B爪手空
		Call SamIsNeedPcs
		For i = 0 To SamNeedItemsNum - 1
			If SamNeedItems(i) Then
				Exit For
			EndIf
		Next
		If i > SamNeedItemsNum - 1 Then
			'无需求
			For i = 0 To 3
				If Tester_Select(i) = True And Tester_Fill(i) = True Then
					Exit For
				EndIf
			Next
			If i <= 3 Then
				'存在满穴	
				
				
				For i = 0 To 3
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						Exit For
					EndIf
				Next
				
				If i > 3 Then
					'所有测试机，都在测试中都在测试中
					Print "所有选中的测试机，都在测试中。前往预判位置。"
					MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
					realbox = 0
					i_index = 1
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
SamOperate2_lable1:
					For i = 0 To 3

						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					
					Next
					If i > 3 Then
						Wait 0.2
						'一直判断
						GoTo SamOperate2_lable1
					EndIf
					GoTo SamOperate2_lable2
				Else
SamOperate2_lable2:
	                GoSub SamOperate2SuckSub
				
				
				EndIf
			
			Else
				'全空穴	
			EndIf
		Else
			'有需求
			For i = 0 To 3
				If Tester_Select(i) = True And Tester_Fill(i) = True Then
					Exit For
				EndIf
			Next
			If i > 3 Then
				'全空穴
				'退出
			Else
				'存在满穴
				
				
				For i = 0 To 7
					If SamPanelHave(i) Then
						Exit For
					EndIf
				Next
				If i > 7 Then
					'样本盘无料	
					
					For i = 0 To 3
						If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
							Exit For
						EndIf
					Next
					
					If i > 3 Then
						'所有测试机，都在测试中都在测试中
						Print "所有选中的测试机，都在测试中。前往预判位置。"
						MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
						realbox = 0
						i_index = 1
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
SamOperate2_lable3:
						For i = 0 To 3
	
							If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
								Exit For
							EndIf
						
						Next
						If i > 3 Then
							Wait 0.2
							'一直判断
							For i = 0 To 7
								If SamPanelHave(i) Then
									Exit For
								EndIf
							Next
							If i > 7 Then
								GoTo SamOperate2_lable3
							Else
								'被样本盘有料打断
								GoTo SamOperate2_lable5
							EndIf
							
						EndIf
						GoTo SamOperate2_lable4

					Else
SamOperate2_lable4:
		                GoSub SamOperate2SuckSub
					
					EndIf
			
				Else
SamOperate2_lable5:
					'样本盘有料
					'退出

				EndIf

			EndIf
		EndIf
	EndIf
	Exit Function
	
SamOperate2ReleaseSub:
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
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(Delta_Z)
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
	
SamOperateReLabel2:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
		FinalPosition = Here
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		GoTo SamOperateReLabel2
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
	Else

		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
	EndIf
	
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next

	SamTestRecord(i + 2, item_i) = True
	SamTestNowItems(i) = item_i + 1
Return
	
SamOperate2SuckSub:
SamOperate2SuckSubLabel1:
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
	FinalPosition = FinalPosition1 +Z(Delta_Z)

	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next



	
	PickFlexFirstSuck = True
	pickRetryTimes = 0
	PickHave(0) = PickAction(0)
	If PickHave(0) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(0) = PickAction(0)
	EndIf



	If PickHave(0) = True Then
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",A"
		
		Tester_Fill(i) = False;
		
'		Select i
'			Case 0
'	'				TargetPosition_Num = 2
'				'A_1，依据TesterOperate1更改
'				FinalPosition1 = A1PASS1
'	'				Position2NeedNeedAnotherMove = True
'				
'				rearnum = 4
'			Case 1
'	'				TargetPosition_Num = 3
'				FinalPosition1 = A2PASS1
'				
'				rearnum = 5
'			Case 2
'	'				TargetPosition_Num = 4
'				FinalPosition1 = A3PASS1
'				rearnum = 14
'			Case 3
'	'				TargetPosition_Num = 5
'				FinalPosition1 = A4PASS3
'				rearnum = 15
'		Send
'	'		Go FinalPosition1
'		TargetPosition_Num = -2
'		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'		For j = 0 To 3
'			isInWaitPosition(j) = False
'		Next
		
		
		
		If Tester_Pass(i) <> 0 Then
				
			Pick_P_Msg(0) = 0
			NgContinue(i) = 0
			
	
			'PASS项目测试结果
	
			
			Select SamTestNowItems(i)
				Case 1
					SamTestResult(i, 0) = True
					SampleResult$ = "OK"
				Case 2
					SamTestResult(i, 1) = False
					SampleResult$ = "OK"
				Case 3
					SamTestResult(i, 2) = False
					SampleResult$ = "OK"
				Case 4
					SamTestResult(i, 3) = False
					SampleResult$ = "OK"
				Case 5
					SamTestResult(i, 4) = False
					SampleResult$ = "OK"
				Case 6
					SamTestResult(i, 5) = False
					SampleResult$ = "OK"
				Case 7
					SamTestResult(i, 6) = False
					SampleResult$ = "OK"
				Case 8
					SamTestResult(i, 7) = False
					SampleResult$ = "OK"
				Case 9
					SamTestResult(i, 8) = False
					SampleResult$ = "OK"
				Case 10
					SamTestResult(i, 9) = False
					SampleResult$ = "OK"
				Default
			Send
	
		Else
			'NG项目测试结果
		
			Select SamTestNowItems(i)
				Case 1
					SamTestResult(i, 0) = False
					SampleResult$ = "NG"
				Case 2
					SamTestResult(i, 1) = True
					SampleResult$ = "NG"
				Case 3
					SamTestResult(i, 2) = True
					SampleResult$ = "NG1"
				Case 4
					SamTestResult(i, 3) = True
					SampleResult$ = "NG2"
				Case 5
					SamTestResult(i, 4) = True
					SampleResult$ = "NG3"
				Case 6
					SamTestResult(i, 5) = True
					SampleResult$ = "NG4"
				Case 7
					SamTestResult(i, 6) = True
					SampleResult$ = "NG5"
				Case 8
					SamTestResult(i, 7) = True
					SampleResult$ = "NG6"
				Case 9
					SamTestResult(i, 8) = True
					SampleResult$ = "NG7"
				Case 10
					SamTestResult(i, 9) = True
					SampleResult$ = "NG8"
				Default
			Send
	
		EndIf
			
		
		Select SamTestNowItems(i)
			Case 1
				FlexNowTest$ = "OK"
			Case 2
				FlexNowTest$ = "NG"
			Case 3
				FlexNowTest$ = "NG1"
			Case 4
				FlexNowTest$ = "NG2"
			Case 5
				FlexNowTest$ = "NG3"
			Case 6
				FlexNowTest$ = "NG4"
			Case 7
				FlexNowTest$ = "NG5"
			Case 8
				FlexNowTest$ = "NG6"
			Case 9
				FlexNowTest$ = "NG7"
			Case 10
				FlexNowTest$ = "NG8"
			Default
				
		Send
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SampleResult," + Str$(i + 1) + "," + FlexNowTest$ + "," + SampleResult$
		
		
		If Tester_Pass(i) <> 0 Then
				
			Pick_P_Msg(0) = 0
			NgContinue(i) = 0

		Else
			'判断超时
			If Tester_Timeout(i) <> 0 Then
				Print "测试机" + Str$(i + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(i + 1) + "，测试超时"
				Pause
			EndIf

		EndIf
		If PickHave(1) = False Then
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
		Else
			Wait 0.2
		EndIf
		'查询A爪手条码
		SamSearchflag = 0
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SamDBSearch,A"
		Wait SamSearchflag = 1
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

		Print "测试机" + Str$(i + 1) + "，样本 吸取失败"
		MsgSend$ = "测试机" + Str$(i + 1) + "，样本 吸取失败"
		On Alarm_SuckFail
		Pause
		Off Alarm_SuckFail
		Off SuckA
		GoTo SamOperate2SuckSubLabel1
	EndIf
Return

	
Fend
Function SamUnload(picknum As Integer)
	
	Integer i, j, i_item
	If PickHave(picknum) = True Then
		If SamScanResult_Fail Then
			'扫码失败
			SamScanResult_Fail = False
			GoSub SamUnload_Ng
			
		Else
			Call SamIsNeedPcs
			For i = 0 To SamNeedItemsNum - 1
				
				If SamTestRecord(picknum, i) And SamNeedItems(i) Then
					Exit For
				EndIf
			Next
			If i > SamNeedItemsNum - 1 Then
				'无需求
				For i = 0 To SamNeedItemsNum - 1
					If SamTestRecord(picknum, i) = True Then
						i_item = i
						Exit For
						
					EndIf
				Next
				If i > SamNeedItemsNum - 1 Then
					GoSub SamUnload_Ng
				Else
					For i = 0 To 7
						If SamPanelHave_Back(i) = False Then
							Exit For
						EndIf
					Next
					If i > 7 Then
						Print "样本盘满"
						MsgSend$ = "样本盘满"
						Pause
						GoSub SamUnload_Ng
					Else
						GoSub SamUnload_back
					EndIf
					
				EndIf
				
			Else
				'有需求
				'不能扔掉
			EndIf
		EndIf
	EndIf
	
	Exit Function
	
SamUnload_back:
		TargetPosition_Num = 7
		If picknum = 0 Then
			FinalPosition = P(128 + i)
		Else
			FinalPosition = P(120 + i)
		EndIf
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Call ReleaseAction(picknum, -1)
		PickHave(picknum) = False
'		SamPanelHave(i) = True
		SamPanelHave_Back(i) = True
		SamRetestHave_index(i) = i_item
'		If CmdSend$ <> "" Then
'			Print "有命令 " + CmdSend$ + " 待发送！"
'		EndIf
'		Do While CmdSend$ <> ""
'			Wait 0.1
'		Loop
'		CmdSend$ = "SamPanelHave,True," + Str$(i)
		
		TargetPosition_Num = -2
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
Return
	
SamUnload_Ng:
	
	TargetPosition_Num = 6


	If picknum = 1 Then
		FinalPosition = Pallet(5, NgTrayPalletNum)
	Else
		FinalPosition = Pallet(10, NgTrayPalletNum)
	EndIf
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	Call ReleaseAction(picknum, -1)
	PickHave(picknum) = False
	NgTrayPalletNum = NgTrayPalletNum + 1
	If NgTrayPalletNum > 8 Then
		Go P(349 + PassStepNum)
		Print "Ng下料盘，换料"
		MsgSend$ = "Ng下料盘，换料"
		NgTrayPalletNum = 1
		Pause
		
	EndIf

Return
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
	FinalPosition = ChangeHandL
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
	Pallet 5, NCui_1, NCui_2, NCui_3, 2, 4
	Pallet 10, NCui_1_A, NCui_2_A, NCui_3_A, 2, 4
	Pallet 11, NoiseCui_1, NoiseCui_2, NoiseCui_3, 2, 3
	Pallet 12, NoiseCui_1_A, NoiseCui_2_A, NoiseCui_3_A, 2, 3
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
'	FeedPanelNum = 0
	For i = 0 To 5
		For j = 0 To 4
			PcsGrrMsgArray(i, j) = 0
		Next
	Next

	
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
Function AdjustDoubleAction
	On AdjustValve, Forced
	Wait 0.5
	Off AdjustValve, Forced
	Wait 0.5
	On AdjustValve, Forced
Fend
Function AllMonitor
	
	Integer FeedReady_, PassTrayRdy_, INP_Home_, i, NgTrayRdy_, CloseCMD_
	FeedReady_ = Sw(FeedReady)
	CloseCMD_ = Sw(CloseCMD)
	Do
		Wait 0.1
		If NgTrayPalletNum < 1 Then
			NgTrayPalletNum = 1
		EndIf
		If NoiseTrayPalletNum < 1 Then
			NoiseTrayPalletNum = 1
		EndIf
		
		If Sw(RollSet) = 1 Then
			On RollSetOut, Forced
		Else
			Off RollSetOut, Forced
		EndIf
			
		If Sw(RollReset) = 1 Then
			On RollResetout, Forced
		Else
			Off RollResetout, Forced
			
		EndIf
		
		If CloseCMD_ <> Sw(CloseCMD) Then
			CloseCMD_ = Sw(CloseCMD)
			If Sw(CloseCMD) Then
				Xqt AdjustDoubleAction
			EndIf
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
				Off PrePickCMD, Forced
				On AdjustValve, Forced
'				Wait 0.8
				FeedReadySigleDown = 1
				FeedPanelNum = 0
			Else
'				FeedReadySigleDown = 1
				Off FeedEmpty, Forced
				Off PrePickCMD, Forced
			EndIf
		EndIf
		

		
	
	Loop
Fend

'爪手A取操作
Function PickFeedOperate1
	Boolean pickfeedflag, fullflag, InWaitPosition
	Integer scanflag, i
	InWaitPosition = False
PickFeedOperatelabel1:
	If (Sw(FeedReady) = 0 Or FeedReadySigleDown = 0) And Not ReStart_flag And Discharge = 0 Then
	
		TargetPosition_Num = 1
		FinalPosition = ChangeHandL
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		
		Print "上料盘，未准备好"
		MsgSend$ = "上料盘，未准备好"
'		Off AdjustValve
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
'		On AdjustValve
'		Wait 0.3
		
	EndIf
	
	If Discharge = 0 Then
		On DangerOut
'		On BlowA
		If Sw(RollReset) = 0 And Sw(RollSet) = 0 Then
			Print "等待 旋转盘到位"
			MsgSend$ = "等待 旋转盘到位"
			Wait Sw(RollReset) = 1 Or Sw(RollSet) = 1
			Wait 1.5
		EndIf
		
		If FeedFill(FeedPanelNum) = True Then
			
			TargetPosition_Num = 1
			
			FinalPosition = P(11 + FeedPanelNum) +Z(Delta_Z)
			
			
			Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
'			needreleaseadjust = True
			pickRetryTimes = 0
			PickFeedFirstSuck = True
			pickfeedflag = PickAction(0)
			If pickfeedflag = False Then
				pickRetryTimes = pickRetryTimes + 1
'				Wait 0.5
				needreleaseadjust = True
				pickfeedflag = PickAction(0)
			EndIf
			needreleaseadjust = False
			
			PickHave(0) = pickfeedflag
			If pickfeedflag Then
				FeedFill(FeedPanelNum) = False
				Go Here +Z(10)
				On AdjustValve
				
				FeedPanelNum = FeedPanelNum + 1
				If FeedPanelNum = 5 Then
					On PrePickCMD
				EndIf
				For i = FeedPanelNum To 5
					If FeedFill(FeedPanelNum) = True Then
						Exit For
					Else
						FeedPanelNum = FeedPanelNum + 1
						If FeedPanelNum = 5 Then
							On PrePickCMD
						EndIf
					EndIf
				Next
				
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
				If PcsLostAlarm1 Then
					Print "A爪手掉料"
					MsgSend$ = "A爪手掉料"
					Pause
					PcsLostAlarm1 = False
				EndIf

				

			Else
				Print "上料盘" + Str$(FeedPanelNum + 1) + "，吸取失败"
				MsgSend$ = "上料盘" + Str$(FeedPanelNum + 1) + "，吸取失败"
'				Go Here +Z(10)
				Off AdjustValve
				BlowSuckFail(0)
				Accel 50, 50
				Go FailFeedWaitP
				Accel 100, 100
				On Alarm_SuckFail
				Pause
				Off Alarm_SuckFail
				On AdjustValve
				Wait 0.2
'				FeedPanelNum = FeedPanelNum + 1
'				fullflag = IsFeedPanelEmpty(True)
				
				GoTo PickFeedOperatelabel1
				
			EndIf
				

		Else
			FeedPanelNum = FeedPanelNum + 1;
			If FeedPanelNum = 5 Then
				On PrePickCMD
			EndIf
			For i = FeedPanelNum To 5
				If FeedFill(FeedPanelNum) = True Then
					Exit For
				Else
					FeedPanelNum = FeedPanelNum + 1
					If FeedPanelNum = 5 Then
						On PrePickCMD
					EndIf
				EndIf
			Next
			Call IsFeedPanelEmpty(True)
			GoTo PickFeedOperatelabel1
		EndIf
	Else
		TargetPosition_Num = 1
		FinalPosition = ChangeHandL
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
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
		If Sw(AutoDischarge) = 1 Then
			Discharge = 1
			On Discharing, Forced
		EndIf
		
		Off RollValve
		Off AdjustValve
		If needwait Then
			Wait Sw(RollReset) = 1
'			Wait 1.5
		EndIf
		On FeedEmpty
		FeedReadySigleDown = 0
		IsFeedPanelEmpty = True
		FeedPanelNum = 0
		ReStart_flag = False
	Else
		If FeedPanelNum >= 3 Then
			On RollValve
			If needwait Then
				Wait Sw(RollSet) = 1
'				Wait 1.5
			EndIf
		EndIf
		IsFeedPanelEmpty = False
	EndIf
Fend

'A抓手处理测试机程序
Function TesterOperate1
	Integer i, i_index, j, FlexVoccum1, FlexVoccum2
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
				If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = False And (Pick_P_Msg(0) - 2) <> IndexArray_i(i) Then
					If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And IndexArray_i(i) <= 1 Then
						Exit For
					ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And IndexArray_i(i) >= 2 Then
						Exit For
					ElseIf Pick_P_Msg(0) - 2 < 0 Then
						Exit For
					EndIf
					
				EndIf
			Else
				If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = False Then
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
					If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And (Pick_P_Msg(0) - 2) <> IndexArray_i(i) And Tester_Testing(IndexArray_i(i)) = False Then
						If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And IndexArray_i(i) <= 1 Then
							Exit For
						ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And IndexArray_i(i) >= 2 Then
							Exit For
						ElseIf Pick_P_Msg(0) - 2 < 0 Then
							Exit For
						EndIf
					EndIf
				Else
					If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
						Exit For
					EndIf
				EndIf
			Next
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "所有选中的测试机，都在测试中。前往预判位置。"
				MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 1
				For i = 0 To 3
					If ReTest_ And Pick_P_Msg(0) <> -1 Then
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And (Pick_P_Msg(0) - 2) <> IndexArray_i(i) Then
							If realbox < TesterTimeElapse(IndexArray_i(i)) And TesterTimeElapse(IndexArray_i(i)) < 100 Then
								If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And IndexArray_i(i) <= 1 Then
									realbox = TesterTimeElapse(IndexArray_i(i))
									i_index = IndexArray_i(i)
								ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And IndexArray_i(i) >= 2 Then
									realbox = TesterTimeElapse(IndexArray_i(i))
									i_index = IndexArray_i(i)
								EndIf

							EndIf
							
						EndIf
					Else
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True Then
							If realbox < TesterTimeElapse(IndexArray_i(i)) And TesterTimeElapse(IndexArray_i(i)) < 100 Then
								realbox = TesterTimeElapse(IndexArray_i(i))
								i_index = IndexArray_i(i)
							EndIf
						EndIf
					EndIf
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
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And (Pick_P_Msg(0) - 2) <> IndexArray_i(i) And Tester_Testing(IndexArray_i(i)) = False Then
							If (Pick_P_Msg(0) - 2 = 0 Or Pick_P_Msg(0) - 2 = 1) And IndexArray_i(i) <= 1 Then
								Exit For
							ElseIf (Pick_P_Msg(0) - 2 = 2 Or Pick_P_Msg(0) - 2 = 3) And IndexArray_i(i) >= 2 Then
								Exit For
							ElseIf Pick_P_Msg(0) - 2 < 0 Then
								Exit For
							EndIf
						EndIf
					Else
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
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
				If PickHave(1) = True And Pick_P_Msg(1) = 1 And ReTest_ And Tester_ReTestFalg(IndexArray_i(i)) < 1 Then
					Tester_ReTestFalg(IndexArray_i(i)) = Tester_ReTestFalg(IndexArray_i(i)) + 1
					Print "A，正常，复测，" + Str$(IndexArray_i(i) + 1)
					MsgSend$ = "A，正常，复测，" + Str$(IndexArray_i(i) + 1)
					'继续放，复测
					GoSub TesterOperate1ReleaseSub_1
				Else
					'放
					'若被测试机被选择屏蔽，需要先取走产品。
					If NeedChancel(IndexArray_i(i)) = False Then
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
						Tester_Select(IndexArray_i(i)) = False
						NeedChancel(IndexArray_i(i)) = False
						
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
				If Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
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
					i_index = 1
					For i = 0 To 3
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True Then
							If realbox < TesterTimeElapse(IndexArray_i(i)) And TesterTimeElapse(IndexArray_i(i)) < 100 Then
								realbox = TesterTimeElapse(IndexArray_i(i))
								i_index = IndexArray_i(i)
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
						If Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
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
					
					If PickHave(1) = True And Pick_P_Msg(1) = 1 And ReTest_ And Tester_ReTestFalg(IndexArray_i(i)) < 1 Then
						Tester_ReTestFalg(i) = Tester_ReTestFalg(IndexArray_i(i)) + 1
						Print "A，排料，复测，" + Str$(IndexArray_i(i) + 1)
						MsgSend$ = "A，排料，复测，" + Str$(IndexArray_i(i) + 1)
						'继续放，复测
						GoSub TesterOperate1ReleaseSub_1
					Else
						If NeedChancel(IndexArray_i(i)) = True Then
							Tester_Select(IndexArray_i(i)) = False
							NeedChancel(IndexArray_i(i)) = False
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
TesterOperate1SuckSubLabel1:
	Select IndexArray_i(i)
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
		Print "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
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
	Select IndexArray_i(i)
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
	FinalPosition = FinalPosition1 +Z(Delta_Z)
	
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
	
	Ttarget = IndexArray_i(i) + 1
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE," + Str$(IndexArray_i(i) + 1)




	PickFlexFirstSuck = True
	pickRetryTimes = 0
	PickHave(1) = PickAction(1)
	If PickHave(1) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(1) = PickAction(1)
'		If PickHave(1) = False Then
'			pickRetryTimes = pickRetryTimes + 1
''			Wait 1
'			PickHave(1) = PickAction(1)
'		EndIf
	EndIf

	
	
	

	
	
	If PickHave(1) = True Then
		
		Tester_Fill(IndexArray_i(i)) = False;
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SaveBarcode," + Str$(IndexArray_i(i) + 1) + ",B"
		
		If Tester_Pass(IndexArray_i(i)) <> 0 Then
		
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "TestResultCount,OK," + Str$(IndexArray_i(i) + 1)
			CheckBarcodeResult = 0
		ElseIf Not ReTest_ Then
			
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "TestResultCount,NG," + Str$(IndexArray_i(i) + 1)
			
		ElseIf Tester_ReTestFalg(IndexArray_i(i)) > 1 Then
			
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "TestResultCount,NG," + Str$(IndexArray_i(i) + 1)
		EndIf
		
		
		If Tester_Pass(IndexArray_i(i)) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4				
			Pick_P_Msg(1) = 0
			NgContinue(IndexArray_i(i)) = 0
			Pick_Remark(1) = 0
			
			
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
			If Tester_Timeout(IndexArray_i(i)) <> 0 Then
				Print "测试机" + Str$(IndexArray_i(i) + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(IndexArray_i(i) + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(IndexArray_i(i)) <> 0 Then
				NgContinue(IndexArray_i(i)) = NgContinue(IndexArray_i(i)) + 1
			EndIf

			If NgContinue(IndexArray_i(i)) >= NgContinueNum Then
				Select IndexArray_i(i)
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
				Print "测试机" + Str$(IndexArray_i(i) + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(IndexArray_i(i) + 1) + "，连续NG"
				Pause
				NgContinue(IndexArray_i(i)) = 0
			EndIf
			
			'复测
			If Tester_ReTestFalg(IndexArray_i(i)) = 1 And Tester_Remark(IndexArray_i(i)) <> 1 And ReTest_ Then
			'需要到另一台测试机测试
				Pick_P_Msg(1) = IndexArray_i(i) + 2
			Else
				Pick_P_Msg(1) = 1
				If Tester_Remark(IndexArray_i(i)) <> 1 Then
					Pick_Remark(1) = 0
				Else
					'Noise不良
					Pick_Remark(1) = 1
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				EndIf
				
				
			EndIf
			
		EndIf
	Else
		Select IndexArray_i(i)
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
suckfailrecheck:
		Print "测试机" + Str$(IndexArray_i(i) + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(IndexArray_i(i) + 1) + "，吸取失败"
		On Alarm_SuckFail
		
		Select IndexArray_i(i)
			Case 0
				Off AL_Suck;
			Case 1
				Off AR_Suck;
			Case 2
				Off BL_Suck;
			Case 3
				Off BR_Suck;
		Send
		Pause
		Off Alarm_SuckFail
		Off SuckB
		Select IndexArray_i(i)
			Case 0
				On AL_Suck; FlexVoccum1 = 10; FlexVoccum2 = 11
			Case 1
				On AR_Suck; FlexVoccum1 = 12; FlexVoccum2 = 13
			Case 2
				On BL_Suck; FlexVoccum1 = 20; FlexVoccum2 = 21
			Case 3
				On BR_Suck; FlexVoccum1 = 22; FlexVoccum2 = 23
		Send
		Wait 1
		If Sw(FlexVoccum1) = 1 Or Sw(FlexVoccum2) = 1 Then
			GoTo suckfailrecheck
		EndIf
	
		Tester_Fill(IndexArray_i(i)) = False;
'		GoTo TesterOperate1SuckSubLabel1
	EndIf
Return

TesterOperate1ReleaseSub:
'有空穴
	ReleaseFailFlexIndex = -1
	Select IndexArray_i(i)
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
		Print "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
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
	Select IndexArray_i(i)
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4 +Z(Delta_Z)
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

	Call ReleaseAction(0, IndexArray_i(i) + 1)
	PickHave(0) = False
	Tester_Fill(IndexArray_i(i)) = True;
	'退出来，发送启动命令
	Select IndexArray_i(i)
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
	
CheckVoccum_label1:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(IndexArray_i(i)) Then
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
'		Tester_Fill(IndexArray_i(i)) = False;
		If Sw(voccumValue1) = 1 And Sw(voccumValue2) = 1 Then
		'产品被扶好	
			Tester_Testing(IndexArray_i(i)) = True
			PickAorC$(IndexArray_i(i)) = "A"
			
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
					Tester_ReTestFalg(IndexArray_i(i)) = 0
				Case 2
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				Case 3
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				Case 4
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				Case 5
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				
			Send
			ReleaseFailFlexIndex = -1
		Else
			ReleaseFailFlexIndex = IndexArray_i(i)
'0 A爪手
'1 B爪手
			ReleaseFailPickNum = 0
			
		EndIf
'		FinalPosition = Here
'		GoTo CheckVoccum_label1
'		Tester_Testing(IndexArray_i(i)) = True
'		PickAorC$(IndexArray_i(i)) = "A"
	Else

		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		If PcsLostAlarm2 Then
			Print "B爪手掉料"
			MsgSend$ = "B爪手掉料"
			Pause
			PcsLostAlarm2 = False
		EndIf
		
		Tester_Testing(IndexArray_i(i)) = True
		PickAorC$(IndexArray_i(i)) = "A"
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
				Tester_ReTestFalg(IndexArray_i(i)) = 0
			Case 2
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			Case 3
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			Case 4
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			Case 5
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			
		Send
		ReleaseFailFlexIndex = -1
	EndIf
	

	

Return

TesterOperate1ReleaseSub_1:
'有空穴
	ReleaseFailFlexIndex = -1
	Select IndexArray_i(i)
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
		Print "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
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
	Select IndexArray_i(i)
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(Delta_Z)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(1, IndexArray_i(i) + 1)
	PickHave(1) = False
	Tester_Fill(IndexArray_i(i)) = True;
	'退出来，发送启动命令
	Select IndexArray_i(i)
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
	
CheckVoccum_label2:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(IndexArray_i(i)) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
'		Tester_Fill(IndexArray_i(i)) = False;
		If Sw(voccumValue1) = 1 And Sw(voccumValue2) = 1 Then
			Tester_Testing(IndexArray_i(i)) = True
			PickAorC$(IndexArray_i(i)) = "B"
			For j = 0 To 3
				isInWaitPosition(j) = False
			Next
			ReleaseFailFlexIndex = -1
		Else
			ReleaseFailFlexIndex = IndexArray_i(i)
'0 A爪手
'1 B爪手
			ReleaseFailPickNum = 1
		EndIf
'		FinalPosition = Here
'		GoTo CheckVoccum_label2
'		Tester_Testing(IndexArray_i(i)) = True
'		PickAorC$(IndexArray_i(i)) = "B"
	Else

		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		If PcsLostAlarm1 Then
			Print "A爪手掉料"
			MsgSend$ = "A爪手掉料"
			Pause
			PcsLostAlarm1 = False
		EndIf
		
		
		Tester_Testing(IndexArray_i(i)) = True
		PickAorC$(IndexArray_i(i)) = "B"
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
		ReleaseFailFlexIndex = -1
	EndIf



	
'	For j = 0 To 3
'		isInWaitPosition(j) = False
'	Next

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
Function TesterOperateReleaseFail
Integer j, rearnum, FlexVoccum1, FlexVoccum2

	If ReleaseFailFlexIndex <> -1 Then
		GoSub TOReleaseFail_SuckSub
		ReleaseFailFlexIndex = -1
	EndIf
	Exit Function
TOReleaseFail_SuckSub:

	Select ReleaseFailFlexIndex
		Case 0
			Off AL_Suck;
		Case 1
			Off AR_Suck;
		Case 2
			Off BL_Suck;
		Case 3
			Off BR_Suck;
	Send
	
	Select ReleaseFailFlexIndex
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
		Print "磁感传感器" + Str$(ReleaseFailFlexIndex + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(ReleaseFailFlexIndex + 1) + "未到位，运动到等待位置"
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
	Select ReleaseFailFlexIndex
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			Select ReleaseFailPickNum
				Case 0
					FinalPosition1 = A_1
				Case 1
					FinalPosition1 = B_1
			Send
			
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			Select ReleaseFailPickNum
				Case 0
					FinalPosition1 = A_2
				Case 1
					FinalPosition1 = B_2
			Send
			NeedAnotherMove(1) = True
			rearnum = 5
			
		Case 2
			TargetPosition_Num = 4
			Select ReleaseFailPickNum
				Case 0
					FinalPosition1 = A_3
				Case 1
					FinalPosition1 = B_3
			Send
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			Select ReleaseFailPickNum
				Case 0
					FinalPosition1 = A_4
				Case 1
					FinalPosition1 = B_4
			Send
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1 +Z(Delta_Z)

	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next

	
	PickFlexFirstSuck = True
	pickRetryTimes = 0
	PickHave(ReleaseFailPickNum) = PickAction(ReleaseFailPickNum)
	If PickHave(ReleaseFailPickNum) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(ReleaseFailPickNum) = PickAction(ReleaseFailPickNum)
'		If PickHave(1) = False Then
'			pickRetryTimes = pickRetryTimes + 1
''			Wait 1
'			PickHave(1) = PickAction(1)
'		EndIf
	EndIf
	If PickHave(ReleaseFailPickNum) = True Then
	'吸取成功，当NG产品处理
		Pick_P_Msg(ReleaseFailPickNum) = 1
		Pick_Remark(ReleaseFailPickNum) = 0
	Else
		Select ReleaseFailFlexIndex
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
suckfailrecheck:
		Print "测试机" + Str$(ReleaseFailFlexIndex + 1) + "，吸取失败1"
		MsgSend$ = "测试机" + Str$(ReleaseFailFlexIndex + 1) + "，吸取失败1"
		On Alarm_SuckFail
		Select ReleaseFailFlexIndex
			Case 0
				Off AL_Suck;
			Case 1
				Off AR_Suck;
			Case 2
				Off BL_Suck;
			Case 3
				Off BR_Suck;
		Send
		Pause
		Off Alarm_SuckFail
		Off SuckB
		Select ReleaseFailFlexIndex
			Case 0
				On AL_Suck; FlexVoccum1 = 10; FlexVoccum2 = 11
			Case 1
				On AR_Suck; FlexVoccum1 = 12; FlexVoccum2 = 13
			Case 2
				On BL_Suck; FlexVoccum1 = 20; FlexVoccum2 = 21
			Case 3
				On BR_Suck; FlexVoccum1 = 22; FlexVoccum2 = 23
		Send
		Wait 1
		If Sw(FlexVoccum1) = 1 Or Sw(FlexVoccum2) = 1 Then
			GoTo suckfailrecheck
		EndIf
'		GoTo TesterOperate1SuckSubLabel1
	EndIf
	Tester_Fill(ReleaseFailFlexIndex) = False;
Return
Fend
'B抓手处理测试机程序
Function TesterOperate2
	Integer i, i_index, j, FlexVoccum1, FlexVoccum2
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
				If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = False And (Pick_P_Msg(1) - 2) <> IndexArray_i(i) Then
					If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And IndexArray_i(i) <= 1 Then
						Exit For
					ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And IndexArray_i(i) >= 2 Then
						Exit For
					ElseIf Pick_P_Msg(1) - 2 < 0 Then
						Exit For
					EndIf
				EndIf
			Else
				If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = False Then
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
					If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And (Pick_P_Msg(1) - 2) <> IndexArray_i(i) And Tester_Testing(IndexArray_i(i)) = False Then
						If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And IndexArray_i(i) <= 1 Then
							Exit For
						ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And IndexArray_i(i) >= 2 Then
							Exit For
						ElseIf Pick_P_Msg(1) - 2 < 0 Then
							Exit For
						EndIf
					EndIf
				Else
					If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
						Exit For
					EndIf
				EndIf
			Next
			If i > 3 Then
				'所有测试机，都在测试中都在测试中
				Print "所有选中的测试机，都在测试中。前往预判位置。"
				MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
				realbox = 0
				i_index = 1
				For i = 0 To 3
					
				
				
					If ReTest_ Then
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And (Pick_P_Msg(1) - 2) <> IndexArray_i(i) Then
							If realbox < TesterTimeElapse(IndexArray_i(i)) And TesterTimeElapse(IndexArray_i(i)) < 100 Then
								If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And IndexArray_i(i) <= 1 Then
									realbox = TesterTimeElapse(IndexArray_i(i))
									i_index = IndexArray_i(i)
								ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And IndexArray_i(i) >= 2 Then
									realbox = TesterTimeElapse(IndexArray_i(i))
									i_index = IndexArray_i(i)
								EndIf
							EndIf
							
						EndIf
					Else
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True Then
							If realbox < TesterTimeElapse(IndexArray_i(i)) And TesterTimeElapse(IndexArray_i(i)) < 100 Then
								realbox = TesterTimeElapse(IndexArray_i(i))
								i_index = IndexArray_i(i)
							EndIf
						EndIf
					EndIf
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
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And (Pick_P_Msg(1) - 2) <> IndexArray_i(i) And Tester_Testing(IndexArray_i(i)) = False Then
							If (Pick_P_Msg(1) - 2 = 0 Or Pick_P_Msg(1) - 2 = 1) And IndexArray_i(i) <= 1 Then
								Exit For
							ElseIf (Pick_P_Msg(1) - 2 = 2 Or Pick_P_Msg(1) - 2 = 3) And IndexArray_i(i) >= 2 Then
								Exit For
							ElseIf Pick_P_Msg(1) - 2 < 0 Then
								Exit For
							EndIf
						EndIf
					Else
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
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
				If PickHave(0) = True And Pick_P_Msg(0) = 1 And ReTest_ And Tester_ReTestFalg(IndexArray_i(i)) < 1 Then
					Tester_ReTestFalg(IndexArray_i(i)) = Tester_ReTestFalg(IndexArray_i(i)) + 1
					Print "B，正常，复测，" + Str$(IndexArray_i(i) + 1)
					MsgSend$ = "B，正常，复测，" + Str$(IndexArray_i(i) + 1)
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
					If NeedChancel(IndexArray_i(i)) = False Then
					'取放
						If PickHave(1) Then
							GoSub TesterOperate1ReleaseSub
						EndIf
						
					Else
						Tester_Select(IndexArray_i(i)) = False
						NeedChancel(IndexArray_i(i)) = False
						
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
				If Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
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
					i_index = 1
					For i = 0 To 3
						If Tester_Select(IndexArray_i(i)) = True And Tester_Fill(IndexArray_i(i)) = True Then
							If realbox < TesterTimeElapse(IndexArray_i(i)) And TesterTimeElapse(IndexArray_i(i)) < 100 Then
								realbox = TesterTimeElapse(IndexArray_i(i))
								i_index = IndexArray_i(i)
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
						If Tester_Fill(IndexArray_i(i)) = True And Tester_Testing(IndexArray_i(i)) = False Then
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
					If PickHave(0) = True And Pick_P_Msg(0) = 1 And ReTest_ And Tester_ReTestFalg(IndexArray_i(i)) < 1 Then
						Tester_ReTestFalg(IndexArray_i(i)) = Tester_ReTestFalg(IndexArray_i(i)) + 1
						Print "B，排料，复测，" + Str$(IndexArray_i(i) + 1)
						MsgSend$ = "B，排料，复测，" + Str$(IndexArray_i(i) + 1)
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
						If NeedChancel(IndexArray_i(i)) = True Then
							Tester_Select(IndexArray_i(i)) = False
							NeedChancel(IndexArray_i(i)) = False
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
TesterOperate2SuckSubLabel1:
	'取
	Select IndexArray_i(i)
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
		Print "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
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
	Select IndexArray_i(i)
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
	FinalPosition = FinalPosition1 +Z(Delta_Z)
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
	Ttarget = IndexArray_i(i) + 1
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "TMOVE," + Str$(IndexArray_i(i) + 1)
	

	PickFlexFirstSuck = True
	pickRetryTimes = 0
	PickHave(0) = PickAction(0)
	If PickHave(0) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(0) = PickAction(0)
'		If PickHave(0) = False Then
'			pickRetryTimes = pickRetryTimes + 1
''			Wait 1
'			PickHave(0) = PickAction(0)
'		EndIf
	EndIf

	
	

	
	If PickHave(0) = True Then
		Tester_Fill(IndexArray_i(i)) = False;
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SaveBarcode," + Str$(IndexArray_i(i) + 1) + ",A"
		
		If Tester_Pass(IndexArray_i(i)) <> 0 Then
		
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "TestResultCount,OK," + Str$(IndexArray_i(i) + 1)
			CheckBarcodeResult = 0
		ElseIf Not ReTest_ Then
			
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "TestResultCount,NG," + Str$(IndexArray_i(i) + 1)
			
		ElseIf Tester_ReTestFalg(IndexArray_i(i)) > 1 Then
			
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "TestResultCount,NG," + Str$(IndexArray_i(i) + 1)
		EndIf
		
		
		
		If Tester_Pass(IndexArray_i(i)) <> 0 Then
'Pick_P_Msg
'-1:New
'0:Pass
'1:Ng
'2:ReTest_from_Tester1
'3:ReTest_from_Tester2
'4:ReTest_from_Tester3
'5:ReTest_from_Tester4				
			Pick_P_Msg(0) = 0
			NgContinue(IndexArray_i(i)) = 0
			Pick_Remark(0) = 0
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
			If Tester_Timeout(IndexArray_i(i)) <> 0 Then
				Print "测试机" + Str$(IndexArray_i(i) + 1) + "，测试超时"
				MsgSend$ = "测试机" + Str$(IndexArray_i(i) + 1) + "，测试超时"
				Pause
			EndIf
			'判断连续NG
			If Tester_Ng(IndexArray_i(i)) <> 0 Then
				NgContinue(IndexArray_i(i)) = NgContinue(IndexArray_i(i)) + 1
			EndIf

			If NgContinue(IndexArray_i(i)) >= NgContinueNum Then
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
				Print "测试机" + Str$(IndexArray_i(i) + 1) + "，连续NG"
				MsgSend$ = "测试机" + Str$(IndexArray_i(i) + 1) + "，连续NG"
				Pause
				NgContinue(IndexArray_i(i)) = 0
			EndIf
			
			'复测
			If Tester_ReTestFalg(IndexArray_i(i)) = 1 And Tester_Remark(IndexArray_i(i)) <> 1 And ReTest_ Then
				Pick_P_Msg(0) = IndexArray_i(i) + 2
			Else
				Pick_P_Msg(0) = 1
				If Tester_Remark(IndexArray_i(i)) <> 1 Then
					Pick_Remark(0) = 0
				Else
					'Noise不良
					Pick_Remark(0) = 1
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				EndIf
			EndIf
			
		EndIf
	Else
		Select IndexArray_i(i)
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
		
suckfailrecheck:
		Print "测试机" + Str$(IndexArray_i(i) + 1) + "，吸取失败"
		MsgSend$ = "测试机" + Str$(IndexArray_i(i) + 1) + "，吸取失败"
		On Alarm_SuckFail
		
		Select IndexArray_i(i)
			Case 0
				Off AL_Suck;
			Case 1
				Off AR_Suck;
			Case 2
				Off BL_Suck;
			Case 3
				Off BR_Suck;
		Send
		Pause
		Off Alarm_SuckFail
		Off SuckA
		Select IndexArray_i(i)
			Case 0
				On AL_Suck; FlexVoccum1 = 10; FlexVoccum2 = 11
			Case 1
				On AR_Suck; FlexVoccum1 = 12; FlexVoccum2 = 13
			Case 2
				On BL_Suck; FlexVoccum1 = 20; FlexVoccum2 = 21
			Case 3
				On BR_Suck; FlexVoccum1 = 22; FlexVoccum2 = 23
		Send
		Wait 1
		If Sw(FlexVoccum1) = 1 Or Sw(FlexVoccum2) = 1 Then
			GoTo suckfailrecheck
		EndIf
		
		Tester_Fill(IndexArray_i(i)) = False;
'		GoTo TesterOperate2SuckSubLabel1
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
	ReleaseFailFlexIndex = -1
	Select IndexArray_i(i)
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
		Print "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
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
	Select IndexArray_i(i)
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(Delta_Z)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(1, IndexArray_i(i) + 1)
	PickHave(1) = False
	Tester_Fill(IndexArray_i(i)) = True;

	'退出来，发送启动命令
	Select IndexArray_i(i)
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
CheckVoccum_label3:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(IndexArray_i(i)) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
		If Sw(voccumValue1) = 1 And Sw(voccumValue2) = 1 Then
			Tester_Testing(IndexArray_i(i)) = True
			PickAorC$(IndexArray_i(i)) = "B"
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
					Tester_ReTestFalg(IndexArray_i(i)) = 0
				Case 2
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				Case 3
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				Case 4
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				Case 5
					Tester_ReTestFalg(IndexArray_i(i)) = 2
				
			Send
			ReleaseFailFlexIndex = -1
		Else
			ReleaseFailFlexIndex = IndexArray_i(i)
'0 A爪手
'1 B爪手
			ReleaseFailPickNum = 1
			
		EndIf
'		Tester_Fill(IndexArray_i(i)) = False;
'		FinalPosition = Here
'		GoTo CheckVoccum_label3

	Else

		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		If PcsLostAlarm1 Then
			Print "A爪手掉料"
			MsgSend$ = "A爪手掉料"
			Pause
			PcsLostAlarm1 = False
		EndIf
		
		Tester_Testing(IndexArray_i(i)) = True
		PickAorC$(IndexArray_i(i)) = "B"
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
				Tester_ReTestFalg(IndexArray_i(i)) = 0
			Case 2
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			Case 3
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			Case 4
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			Case 5
				Tester_ReTestFalg(IndexArray_i(i)) = 2
			
		Send
		ReleaseFailFlexIndex = -1
	EndIf

Return

TesterOperate1ReleaseSub_1:
'有空穴
	ReleaseFailFlexIndex = -1
	Select IndexArray_i(i)
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
		Print "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
		MsgSend$ = "磁感传感器" + Str$(IndexArray_i(i) + 1) + "未到位，运动到等待位置"
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
	Select IndexArray_i(i)
		Case 0
			TargetPosition_Num = 2
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4 +Z(Delta_Z)
			NeedAnotherMove(3) = True
			rearnum = 15
	Send
	FinalPosition = FinalPosition1
	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	Call ReleaseAction(0, IndexArray_i(i) + 1)
	PickHave(0) = False
	Tester_Fill(IndexArray_i(i)) = True;
	'退出来，发送启动命令

	Select IndexArray_i(i)
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
CheckVoccum_label4:

	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(IndexArray_i(i)) Then
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(IndexArray_i(i) + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
		If Sw(voccumValue1) = 1 And Sw(voccumValue2) = 1 Then
			Tester_Testing(IndexArray_i(i)) = True
			PickAorC$(IndexArray_i(i)) = "A"
			For j = 0 To 3
				isInWaitPosition(j) = False
			Next
			ReleaseFailFlexIndex = -1
		Else
			ReleaseFailFlexIndex = IndexArray_i(i)
'0 A爪手
'1 B爪手
			ReleaseFailPickNum = 0
		EndIf
'		Tester_Fill(IndexArray_i(i)) = False;
'		FinalPosition = Here
'		GoTo CheckVoccum_label4

	Else
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		
		If PcsLostAlarm2 Then
			Print "B爪手掉料"
			MsgSend$ = "B爪手掉料"
			Pause
			PcsLostAlarm2 = False
		EndIf
		
		Tester_Testing(IndexArray_i(i)) = True
		PickAorC$(IndexArray_i(i)) = "A"
		For j = 0 To 3
			isInWaitPosition(j) = False
		Next
		ReleaseFailFlexIndex = -1
	EndIf


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
'A爪手GRR处理
Function GRROperate1
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	
	If PickHave(0) Then
	'爪手有料
		For i = 0 To 3
			If PcsGrrMsgArray(0, i) < PcsGrrNeedCount And Tester_Select(i) = True Then
				Exit For
			EndIf
		Next
		If i <= 3 Then
			'未测满
			For i = 0 To 3
				If PcsGrrMsgArray(0, i) < PcsGrrNeedCount And Tester_Select(i) = True And Tester_Fill(i) = False Then
					Exit For
				EndIf
			Next
			If i <= 3 Then
				'存在空穴
				'放料
				GoSub GRROperate1ReleaseSub
			Else
				'目标穴，满
				'直接过
			EndIf
		Else
			'测满→下料
		
		EndIf
	Else
		'爪手无料
		For i = 0 To 3
			If Tester_Select(i) = True And Tester_Fill(i) = False And PickHave(1) And PcsGrrMsgArray(1, i) < PcsGrrNeedCount Then
				Exit For
			EndIf
		Next
		If i > 3 Then
			'另一爪手的料，存在目标空穴
			selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
			If PickHave(0) = False And PickHave(1) = False And selectNum <> fillNum And selectNum <> 0 And PcsGrrNum < PcsGrrNeedNum Then
				'可以从上料盘取料
				'退出
			Else
				For i = 0 To 3
	                If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						If PickHave(1) Then
							If PcsGrrMsgArray(1, i) < PcsGrrNeedCount Or PcsGrrMsgArray(i + 2, i) < PcsGrrNeedCount Then
								'另外一只手上有料，且当前穴是目标穴	or 当前穴次数未到
								Exit For
							EndIf
						Else
							Exit For
						EndIf
						
					EndIf
				Next
				fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
				If fillNum <> 0 Then
					If i > 3 Then
						'所有测试机，都在测试中都在测试中
						Print "所有选中的测试机，都在测试中。前往预判位置。"
						MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
						realbox = 0
						i_index = 1
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
								If PickHave(1) Then
									If PcsGrrMsgArray(1, i) < PcsGrrNeedCount Or PcsGrrMsgArray(i + 2, i) < PcsGrrNeedCount Then
										'另外一只手上有料，且当前穴是目标穴	or 当前穴次数未到
										Exit For
		
									Else
										
									EndIf
								Else
									Exit For
								EndIf
							
							
								
							EndIf
						
						Next
						If i > 3 Then
							Wait 0.2
							'一直判断
							GoTo GRROperate1_lable1
						EndIf
						GoTo GRROperate1_lable2
					Else
		GRROperate1_lable2:
		                GoSub GRROperate1SuckSub
		                If PcsGrrMsgArray(0, i) < PcsGrrNeedCount Then
		                	'次数未到，复测
		                	GoSub GRROperate1ReleaseSub
		                Else
		                	
							If Ttarget <> Tcurrent Then
								Print "下料轴，未准备好"
								MsgSend$ = "下料轴，未准备好"
							EndIf
							Do While Ttarget <> Tcurrent
								Wait 0.02
							Loop
							
							Ttarget = i + 1
							Tcurrent = -1
							If CmdSend$ <> "" Then
								Print "有命令 " + CmdSend$ + " 待发送！"
							EndIf
							Do While CmdSend$ <> ""
								Wait 0.1
							Loop
							CmdSend$ = "TMOVE," + Str$(i + 1)
							Do While Ttarget <> Tcurrent
								Wait 0.02
							Loop
		                EndIf
		                
					
					
					EndIf
				
				Else
					'测试机全空
					'直接退出
				EndIf
			EndIf
		Else
			'直接退出
			'被下一爪手有料、有空穴打断
		EndIf
	
		


	EndIf

Exit Function
	
GRROperate1ReleaseSub:

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
			'A_1，依据TesterOperate1更改
			FinalPosition1 = A_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = A_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = A_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = A_4 +Z(Delta_Z)
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
	
	For j = 0 To 3
		PcsGrrMsgArray(i + 2, j) = PcsGrrMsgArray(0, j)
	Next
	
	PcsGrrMsgArray(i + 2, i) = PcsGrrMsgArray(i + 2, i) + 1
	
	
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
	
GRROperate1ReLabel1:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
		FinalPosition = Here
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		GoTo GRROperate1ReLabel1
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
	


Return

GRROperate1SuckSub:

GRROperate1Rsuck:
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
	FinalPosition = FinalPosition1 +Z(Delta_Z)

	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next


	
	
	PickFlexFirstSuck = True
	pickRetryTimes = 0
	PickHave(0) = PickAction(0)
	If PickHave(0) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(0) = PickAction(0)
	EndIf

	
	


			


	If PickHave(0) = True Then
	
		Tester_Fill(i) = False;
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",A"
	
		For j = 0 To 3
			PcsGrrMsgArray(0, j) = PcsGrrMsgArray(i + 2, j)
		Next
		
		
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
		On Alarm_SuckFail
		Pause
		Off Alarm_SuckFail
		Off SuckA
		GoTo GRROperate1Rsuck
	
	EndIf

Return

Fend
'B爪手GRR处理
Function GRROperate2
	
	Integer i, i_index, j
	Integer rearnum, voccumValue1, voccumValue2
	Integer selectNum, fillNum, testingNum
	Real realbox
	
	If PickHave(1) Then
	'爪手有料
		For i = 0 To 3
			If PcsGrrMsgArray(1, i) < PcsGrrNeedCount And Tester_Select(i) = True Then
				Exit For
			EndIf
		Next
		If i <= 3 Then
			'未测满
			For i = 0 To 3
				If PcsGrrMsgArray(1, i) < PcsGrrNeedCount And Tester_Select(i) = True And Tester_Fill(i) = False Then
					Exit For
				EndIf
			Next
			If i <= 3 Then
				'存在空穴
				'放料
				GoSub GRROperate2ReleaseSub
			Else
				'目标穴，满
				'直接过
			EndIf
		Else
			'测满→下料
		
		EndIf
	Else
	'爪手无料	
		For i = 0 To 3
			If Tester_Select(i) = True And Tester_Fill(i) = False And PickHave(0) And PcsGrrMsgArray(0, i) < PcsGrrNeedCount Then
				Exit For
			EndIf
		Next
		If i > 3 Then
			selectNum = 8 * Tester_Select(3) + 4 * Tester_Select(2) + 2 * Tester_Select(1) + Tester_Select(0)
			fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
			If PickHave(0) = False And PickHave(1) = False And selectNum <> fillNum And selectNum <> 0 And PcsGrrNum < PcsGrrNeedNum Then
				'可以从上料盘取料
				'退出
			Else
				For i = 0 To 3
					If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
						If PickHave(0) Then
							If PcsGrrMsgArray(0, i) < PcsGrrNeedCount Or PcsGrrMsgArray(i + 2, i) < PcsGrrNeedCount Then
								'另外一只手上有料，且当前穴是目标穴	or 当前穴次数未到
								Exit For
							EndIf
						Else
							Exit For
						EndIf
					EndIf
				Next
				fillNum = 8 * Tester_Fill(3) + 4 * Tester_Fill(2) + 2 * Tester_Fill(1) + Tester_Fill(0)
				If fillNum <> 0 Then
					If i > 3 Then
						'所有测试机，都在测试中都在测试中
						Print "所有选中的测试机，都在测试中。前往预判位置。"
						MsgSend$ = "所有选中的测试机，都在测试中。前往预判位置。"
						realbox = 0
						i_index = 1
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
		GRROperate2_lable1:
						For i = 0 To 3
		
							If Tester_Select(i) = True And Tester_Fill(i) = True And Tester_Testing(i) = False Then
								If PickHave(0) Then
									If PcsGrrMsgArray(0, i) < PcsGrrNeedCount Or PcsGrrMsgArray(i + 2, i) < PcsGrrNeedCount Then
										'另外一只手上有料，且当前穴是目标穴	or 当前穴次数未到
										Exit For
									EndIf
								Else
									Exit For
								EndIf
							EndIf
						
						Next
						If i > 3 Then
							Wait 0.2
							'一直判断
							GoTo GRROperate2_lable1
						EndIf
						GoTo GRROperate2_lable2
					Else
		GRROperate2_lable2:
		                GoSub GRROperate2SuckSub
		                If PcsGrrMsgArray(1, i) < PcsGrrNeedCount Then
		                	'次数未到，复测
		                	GoSub GRROperate2ReleaseSub
		                Else
							If Ttarget <> Tcurrent Then
								Print "下料轴，未准备好"
								MsgSend$ = "下料轴，未准备好"
							EndIf
							Do While Ttarget <> Tcurrent
								Wait 0.02
							Loop
							
							Ttarget = i + 1
							Tcurrent = -1
							If CmdSend$ <> "" Then
								Print "有命令 " + CmdSend$ + " 待发送！"
							EndIf
							Do While CmdSend$ <> ""
								Wait 0.1
							Loop
							CmdSend$ = "TMOVE," + Str$(i + 1)
							Do While Ttarget <> Tcurrent
								Wait 0.02
							Loop
		                EndIf
					
					
					EndIf
				
				Else
					'测试机全空
					'直接退出
				EndIf
			EndIf
		Else
           	'直接退出
			'被下一爪手有料、有空穴打断
		EndIf


	EndIf
	Exit Function
	
GRROperate2ReleaseSub:

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
			'A_1，依据TesterOperate1更改
			FinalPosition1 = B_1 +Z(Delta_Z)
			NeedAnotherMove(0) = True
			rearnum = 4
		Case 1
			TargetPosition_Num = 3
			FinalPosition1 = B_2 +Z(Delta_Z)
			NeedAnotherMove(1) = True
			rearnum = 5
		Case 2
			TargetPosition_Num = 4
			FinalPosition1 = B_3 +Z(Delta_Z)
			NeedAnotherMove(2) = True
			rearnum = 14
		Case 3
			TargetPosition_Num = 5
			FinalPosition1 = B_4 +Z(Delta_Z)
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
	
	For j = 0 To 3
		PcsGrrMsgArray(i + 2, j) = PcsGrrMsgArray(1, j)
	Next
	
	PcsGrrMsgArray(i + 2, i) = PcsGrrMsgArray(i + 2, i) + 1
	
	
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
	
GRROperate2ReLabel1:
	If (Sw(voccumValue1) = 0 Or Sw(voccumValue2) = 0) And CheckFlexVoccum(i) Then
		
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Print "测试工位" + Str$(i + 1) + "，产品没放好"
		MsgSend$ = "测试工位" + Str$(i + 1) + "，产品没放好"
		On Alarm_ReleaseFail
		Pause
		Off Alarm_ReleaseFail
		FinalPosition = Here
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		GoTo GRROperate2ReLabel1
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
	Else

		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Tester_Testing(i) = True
		PickAorC$(i) = "B"
	EndIf
	
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next
	


Return

GRROperate2SuckSub:

GRROperate2Rsuck:
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
	FinalPosition = FinalPosition1 +Z(Delta_Z)

	Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
	For j = 0 To 3
		isInWaitPosition(j) = False
	Next



	
	pickRetryTimes = 0
	PickFlexFirstSuck = True
	PickHave(1) = PickAction(1)
	If PickHave(1) = False Then
		pickRetryTimes = pickRetryTimes + 1
'		Wait 1
		PickHave(1) = PickAction(1)
	EndIf

	
	

	

			


	If PickHave(1) = True Then
	
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "SaveBarcode," + Str$(i + 1) + ",B"
		
		Tester_Fill(i) = False;
	
		For j = 0 To 3
			PcsGrrMsgArray(1, j) = PcsGrrMsgArray(i + 2, j)
		Next
		
		
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
		On Alarm_SuckFail
		Pause
		Off Alarm_SuckFail
		Off SuckA
		GoTo GRROperate2Rsuck
	
	EndIf

Return
	
Fend
Function GRRUnloadOperate(num As Integer)
	Integer i
	If PickHave(num) = True Then
		For i = 0 To 3
			If PcsGrrMsgArray(num, i) < PcsGrrNeedCount And Tester_Select(i) = True Then
				Exit For
			EndIf
		Next
		If i > 3 Then
			GoSub GRRUnloadOperate_Unload
		EndIf
		
	
	EndIf
	Exit Function
	
GRRUnloadOperate_Unload:

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
	Accel 50, 50
	Go FinalPosition
	If IsCheckINI Then
		Wait CheckBarcodeResult <> 0
		If CheckBarcodeResult = 1 Then
			Call ReleaseAction(num, -1)
			Ttarget = 5
			If CmdSend$ <> "" Then
				Print "有命令 " + CmdSend$ + " 待发送！"
			EndIf
			Do While CmdSend$ <> ""
				Wait 0.1
			Loop
			CmdSend$ = "ULOAD"
		Else
Pass_label1:
			Print "产品记录异常"
			MsgSend$ = "产品记录异常"
			Pause
			Wait 0.5
			If Sw(num) = 1 Then
				GoTo Pass_label1
			Else
				Off num * 2
			EndIf
		EndIf
	Else
		Call ReleaseAction(num, -1)
		Ttarget = 5
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "ULOAD"
	EndIf
	
	PickHave(num) = False
	

	Go ChangeHandL
	Accel 100, 100
Return

UnloadOperate_Ng:
	
	TargetPosition_Num = 6

	If Pick_Remark(num) = 1 Then
		'Noise不良放料
		If num = 1 Then
			FinalPosition = Pallet(11, NoiseTrayPalletNum)
		Else
			FinalPosition = Pallet(12, NoiseTrayPalletNum)
		EndIf
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Call ReleaseAction(num, -1)
		PickHave(num) = False
		NoiseTrayPalletNum = NoiseTrayPalletNum + 1
		If NoiseTrayPalletNum > 6 Then
			Go P(349 + PassStepNum)
			Print "Noise下料盘，换料"
			MsgSend$ = "Noise下料盘，换料"
			NoiseTrayPalletNum = 1
			Pause
			
		EndIf
		Pick_Remark(num) = 0
	Else
		If num = 1 Then
			FinalPosition = Pallet(5, NgTrayPalletNum)
		Else
			FinalPosition = Pallet(10, NgTrayPalletNum)
		EndIf
		Call RoutePlanThenExe(CurPosition_Num, TargetPosition_Num)
		Call ReleaseAction(num, -1)
		PickHave(num) = False
		NgTrayPalletNum = NgTrayPalletNum + 1
		If NgTrayPalletNum > 8 Then
			Go P(349 + PassStepNum)
			Print "Ng下料盘，换料"
			MsgSend$ = "Ng下料盘，换料"
			NgTrayPalletNum = 1
			Pause
			
		EndIf
	EndIf

Return

Fend
Function ScanBarcodeOpetateP3(picksting$ As String)
	
    Boolean re_scan
    re_scan = False
	TargetPosition_Num = 1
	ScanResult = 0
	
	If CmdSend$ <> "" Then
		Print "有命令 " + CmdSend$ + " 待发送！"
	EndIf
	Do While CmdSend$ <> ""
		Wait 0.1
	Loop
	CmdSend$ = "ScanP3," + picksting$
	
	Accel 50, 50
	Go ScanPositionP3L
	Accel 90, 90
	
	
	
ScanBarcodeOpetateP3label:
	
'	Wait 0.2
	If re_scan Then
		
		If CmdSend$ <> "" Then
			Print "有命令 " + CmdSend$ + " 待发送！"
		EndIf
		Do While CmdSend$ <> ""
			Wait 0.1
		Loop
		CmdSend$ = "ScanP3," + picksting$
	
	EndIf

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
	
	Accel 50, 50
	Go ChangeHandL
	Accel 90, 90

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
	Delta_Z = 8
	Delta_Z1 = 8
	Delta_Z_Release = 4
'	Delta_Z_Release = 4

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
	Fine 250, 250, 250, 250

	CurPosition_Num = -2
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
		If secendPosition <> -2 Then
			Go FinalPosition
		EndIf
		
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
				RoutePassP1 = Here
				PassStepNum = PassStepNum + 1
				
				RoutePassP2 = SamplePass1
				PassStepNum = PassStepNum + 1
				Pass SamplePass1
				
				RoutePassP3 = SamplePass2
				PassStepNum = PassStepNum + 1
				Pass SamplePass2
	
				Accel 50, 50
				Go FinalPosition
				Accel 100, 100
			
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

	Off blownum; On valvenum; On sucknum
	Wait 0.2
	If pickRetryTimes = 0 Then
		NowPosition = Here
	    Go NowPosition -Z(Delta_Z)
	EndIf

'	Wait 0.3 + pickRetryTimes * 0.3
	Wait 0.5 + pickRetryTimes * 0
		
	If needreleaseadjust Then
		Off AdjustValve
		Wait 0.5
	EndIf
	If pickRetryTimes = 0 Then
		NowPosition = Here
	    Go NowPosition +Z(Delta_Z)
	EndIf
	Off valvenum
	Wait 0.3
	Wait Sw(vacuumnum), 0.5

	If Sw(vacuumnum) = 0 Then
		If needreleaseadjust Then
			On AdjustValve
'			Wait 0.1
		EndIf
		PickAction = False
		If PickFeedFirstSuck Then
		    PickFeedFirstSuck = False
			Off AdjustValve
			Wait 1
			On valvenum
			Wait 0.5
			If pickRetryTimes = 0 Then
				NowPosition = Here
			    Go NowPosition -Z(Delta_Z)
			EndIf
			On blownum; Off vacuumnum
			Wait 0.5
			Off valvenum
			Wait 1
			Off blownum
			On AdjustValve
			Wait 1
		EndIf
		If PickFlexFirstSuck Then
			PickFlexFirstSuck = False
			On valvenum
			Wait 0.2
			If pickRetryTimes = 0 Then
				NowPosition = Here
			    Go NowPosition -Z(Delta_Z)
			EndIf
			On blownum; Off vacuumnum
			Wait 0.5
			Off blownum; Off valvenum
			Wait 0.5
		EndIf
'		On blownum; Off sucknum
'		Wait 0.1
'		Off blownum
	Else
		PickAction = True
		Select num
			Case 0
				Xqt PickhaveMoniterA
			Case 1
				Xqt PickhaveMoniterB
		Send
		
	EndIf
	needreleaseadjust = False
	PickFeedFirstSuck = False
	PickFlexFirstSuck = False
'	PickAction = True
Fend
Function PickhaveMoniterA
	Boolean StartCount
	StartCount = False
	PcsLostAlarm1 = False
	Do
		Wait 0.2
		If PickHave(0) Then
			If Sw(VacuumValueA) = 0 Then
				If StartCount = False Then
					TmReset 8
					StartCount = True
				EndIf
				If Tmr(8) > 0.25 Then
'					Print "A爪手掉料"
'					MsgSend$ = "A爪手掉料"
					PcsLostAlarm1 = True
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
	PcsLostAlarm2 = False
	Do
		Wait 0.2
		
		If PickHave(1) Then
			If Sw(VacuumValueB) = 0 Then
				If StartCount = False Then
					TmReset 9
					StartCount = True
				EndIf
				If Tmr(9) > 0.25 Then
'					Print "B爪手掉料"
'					MsgSend$ = "B爪手掉料"
					PcsLostAlarm2 = True
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
	Go Here +Z(10)
	CleanPosition1 = Here +Y(10)
	CleanPosition2 = Here +Y(-10)
	CleanPosition3 = Here
 	On valvenum; On blownum; Off sucknum; On 1; On 3
 	Accel 10, 10
	For i = 0 To 2
		Pass CleanPosition1
		Go CleanPosition3
		Pass CleanPosition2
		Go CleanPosition3
	Next
	Accel 50, 50
	Go CleanPosition3 ! D1; Off valvenum; Off blownum; Off 1; Off 3 !
	Go Here +Z(-10)
	Wait 0.5
	Accel 100, 100
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
	Integer retry_num
	retry_num = 0
'ReleaseActionLable1:
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
	
'    Wait 0.1
	If Flexnum <> -1 Then
		NowPosition = Here
	    Go NowPosition -Z(Delta_Z_Release)
	EndIf
	
'    Wait 0.1
 	On valvenum
 	
	If Flexnum <> -1 Then
'		Wait 0.3
		Wait 0.5
	Else
		Wait 0.3
	EndIf
 	
	On blownum; Off sucknum
	Wait 0.1
	If Flexnum = -1 Then
		Wait 0.2
	EndIf
'	Off blownum
	PickHave(num) = False
	Wait 0.3
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
		Wait 0.3
		Off blownum
	EndIf

 	If Flexnum <> -1 And (Sw(FlexVoccum1) = 0 Or Sw(FlexVoccum2) = 0) Then
		Select Flexnum
			Case 1
				Off AL_Suck
			Case 2
				Off AR_Suck
			Case 3
				Off BL_Suck
			Case 4
				Off BR_Suck
		Send
' 		Off valvenum
' 		Wait 0.2
 		NowPosition = Here
 	    Go NowPosition -Z(Delta_Z1 - Delta_Z_Release) ! D1; On valvenum !
 	    
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
		Wait 0.5
' 		Wait Sw(FlexVoccum1) = 1 And Sw(FlexVoccum2) = 1, 1  '等待气缸下压
'	 	Off valvenum
'		Wait 0.3
 		If Sw(FlexVoccum1) = 0 Or Sw(FlexVoccum2) = 0 Then
 			CheckFlexVoccum(Flexnum - 1) = True
' 			retry_num = retry_num + 1;
' 			If retry_num <= 1 Then
'	 			Off blownum; On sucknum; On valvenum
'	 			Wait 0.5
'	 			Off valvenum
'	 			Wait 0.5
'		 		NowPosition = Here
'		 	    Go NowPosition +Z(Delta_Z1)
'	 	    	GoTo ReleaseActionLable1
'	 	    EndIf
 		Else
 			CheckFlexVoccum(Flexnum - 1) = False
 		EndIf

		If CheckFlexVoccum(Flexnum - 1) = True Then
'			Wait 0.45
			Off blownum; On sucknum
			Select Flexnum
				Case 1
					Off AL_Suck
				Case 2
					Off AR_Suck
				Case 3
					Off BL_Suck
				Case 4
					Off BR_Suck
			Send
			Wait 0.3
	 		NowPosition = Here
	 	    Go NowPosition +Z(Delta_Z1 - Delta_Z_Release)
			Wait 0.3
	 		NowPosition = Here
	 	    Go NowPosition -Z(Delta_Z1 - Delta_Z_Release)
	 	    On blownum; Off sucknum
	 	    Wait 0.2
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
	 	    Off valvenum; Off blownum
	 	    Wait 0.3
	 	Else
	 		Off valvenum; Off blownum
	 		Wait 0.3
		EndIf
		
		
	Else
		Off valvenum; Off blownum
		Wait 0.1
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
	Xqt TcpIpCmdRevFlex
	Xqt TcpIpCmdSendFlex
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
				Case "StatusOfUpload"
					For i = 0 To 3
						If CmdRevStr$(i + 1) = "1" Then
							StatusOfUpload(i) = True;
						Else
							StatusOfUpload(i) = False;
						EndIf
					Next
					StatusOfUploadFinish = 1;
				Case "StatusOfYield"
					For i = 0 To 3
						If CmdRevStr$(i + 1) = "1" Then
							StatusOfYield(i) = True;
						Else
							StatusOfYield(i) = False;
						EndIf
					Next
					StatusOfYieldFinish = 1;
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
				Case "CheckUpload"
					Select CmdRevStr$(1)
						Case "True"
							isCheckUpload = True
						Case "False"
							isCheckUpload = False
					Send
				Case "IsPassLowLimitStop"
					Select CmdRevStr$(1)
						Case "True"
							IsPassLowLimitStop = True
						Case "False"
							IsPassLowLimitStop = False
					Send
				Case "IsCheckINI"
					Select CmdRevStr$(1)
						Case "True"
							IsCheckINI = True
						Case "False"
							IsCheckINI = False
					Send
					
				Case "CheckBarcodeResult"
					Select CmdRevStr$(1)
						Case "1"
							CheckBarcodeResult = 1
						Case "2"
							CheckBarcodeResult = 2
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
				Case "GONOGOAction"
					
					If Not SamActionFlag And Not NeedSamAction Then
						SamNeedItemsNum = Val(CmdRevStr$(1))
						Discharge = 1
						On Discharing, Forced
						NeedSamAction = True
					EndIf
				Case "GONOGOCancel"
					SamActionFlag = False
					NeedSamAction = False
					SamActionFinishFlag = False
				Case "SamRetest"
					SamRetest = 1
				Case "SelectSampleResultfromDtFinish"
					SelectSampleResultfromDtFinish = 1
				Case "SelectSampleResultfromDt"
					Select CmdRevStr$(2)
						Case "OK"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 0) = False
						Case "NG"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 1) = False
						Case "NG1"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 2) = False
						Case "NG2"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 3) = False
						Case "NG3"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 4) = False
						Case "NG4"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 5) = False
						Case "NG5"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 6) = False
						Case "NG6"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 7) = False
						Case "NG7"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 8) = False
						Case "NG8"
							SamTestResult(Val(CmdRevStr$(1)) - 1, 9) = False
						Case "Error"

					Send
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
				Case "SamDBSearch"
					Select CmdRevStr$(1)
						Case "A"
							For i = 0 To 9
								SamTestRecord(0, i) = False
							Next
							Select CmdRevStr$(2)
								Case "OK"
									SamTestRecord(0, 0) = True
								Case "NG"
									SamTestRecord(0, 1) = True
								Case "NG1"
									SamTestRecord(0, 2) = True
								Case "NG2"
									SamTestRecord(0, 3) = True
								Case "NG3"
									SamTestRecord(0, 4) = True
								Case "NG4"
									SamTestRecord(0, 5) = True
								Case "NG5"
									SamTestRecord(0, 6) = True
								Case "NG6"
									SamTestRecord(0, 7) = True
								Case "NG7"
									SamTestRecord(0, 8) = True
								Case "NG8"
									SamTestRecord(0, 9) = True
								Case "Error"

							Send
						Case "B"
							For i = 0 To 9
								SamTestRecord(1, i) = False
							Next
							Select CmdRevStr$(2)
								Case "OK"
									SamTestRecord(1, 0) = True
								Case "NG"
									SamTestRecord(1, 1) = True
								Case "NG1"
									SamTestRecord(1, 2) = True
								Case "NG2"
									SamTestRecord(1, 3) = True
								Case "NG3"
									SamTestRecord(1, 4) = True
								Case "NG4"
									SamTestRecord(1, 5) = True
								Case "NG5"
									SamTestRecord(1, 6) = True
								Case "NG6"
									SamTestRecord(1, 7) = True
								Case "NG7"
									SamTestRecord(1, 8) = True
								Case "NG8"
									SamTestRecord(1, 9) = True
								Case "Error"

							Send
					Send
					SamSearchflag = 1
				Case "SampleHave"
					Select CmdRevStr$(1)
						Case "1"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(0) = True
								SamPanelHave_Back(0) = True
							Else
								SamPanelHave(0) = False
'								SamPanelHave_Back(0) = False
							EndIf
						Case "2"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(1) = True
								SamPanelHave_Back(1) = True
							Else
								SamPanelHave(1) = False
'								SamPanelHave_Back(1) = False
							EndIf
						Case "3"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(2) = True
								SamPanelHave_Back(2) = True
							Else
								SamPanelHave(2) = False
'								SamPanelHave_Back(2) = False
							EndIf
						Case "4"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(3) = True
								SamPanelHave_Back(3) = True
							Else
								SamPanelHave(3) = False
'								SamPanelHave_Back(3) = False
							EndIf
						Case "5"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(4) = True
								SamPanelHave_Back(4) = True
							Else
								SamPanelHave(4) = False
							EndIf
						Case "6"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(5) = True
								SamPanelHave_Back(5) = True
							Else
								SamPanelHave(5) = False
							EndIf
						Case "7"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(6) = True
								SamPanelHave_Back(6) = True
							Else
								SamPanelHave(6) = False
							EndIf
						Case "8"
							If CmdRevStr$(2) = "True" Then
								SamPanelHave(7) = True
								SamPanelHave_Back(7) = True
							Else
								SamPanelHave(7) = False
							EndIf
					Send
				Case "GRRTimesAsk"
					PcsGrrNeedNum = Val(CmdRevStr$(1)) + 1
					PcsGrrNeedCount = Val(CmdRevStr$(2)) + 1
					
					GRRTimesAsk = 1
				Case "IndexArray_i"
					For i = 0 To 3
						IndexArray_i(i) = Val(CmdRevStr$(i + 1))
					Next
					
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
Function TcpIpCmdRevFlex
	Integer chknet1, errTask, i;
	OpenNet #205 As Server
	Print "端口205打开"
	WaitNet #205
	Print "端口205连接"
	Do
		OnErr GoTo NetErr
		chknet1 = ChkNet(205)
		If chknet1 >= 0 Then
			Input #205, CmdRevFlex$
			Print "CmdRevFlex$收到： " + CmdRevFlex$
			CmdRevFlexStr$(0) = ""
			StringSplit1(CmdRevFlex$, ";")
			Select CmdRevFlexStr$(0)
				Case "TestResult"
					Select CmdRevFlexStr$(2)
						Case "1"
							Select CmdRevFlexStr$(1)
								Case "Pass"
									Tester_Pass(0) = 1
								Case "Ng"
									Tester_Ng(0) = 1
								Case "TimeOut"
									Tester_Timeout(0) = 1
							Send
							Select CmdRevFlexStr$(3)
								Case "Noise"
									Tester_Remark(0) = 1
								Default
									Tester_Remark(0) = 0
							Send
						Case "2"
							Select CmdRevFlexStr$(1)
								Case "Pass"
									Tester_Pass(1) = 1
								Case "Ng"
									Tester_Ng(1) = 1
								Case "TimeOut"
									Tester_Timeout(1) = 1
							Send
							Select CmdRevFlexStr$(3)
								Case "Noise"
									Tester_Remark(1) = 1
								Default
									Tester_Remark(1) = 0
							Send
						Case "3"
							Select CmdRevFlexStr$(1)
								Case "Pass"
									Tester_Pass(2) = 1
								Case "Ng"
									Tester_Ng(2) = 1
								Case "TimeOut"
									Tester_Timeout(2) = 1
							Send
							Select CmdRevFlexStr$(3)
								Case "Noise"
									Tester_Remark(2) = 1
								Default
									Tester_Remark(2) = 0
							Send
						Case "4"
							Select CmdRevFlexStr$(1)
								Case "Pass"
									Tester_Pass(3) = 1
								Case "Ng"
									Tester_Ng(3) = 1
								Case "TimeOut"
									Tester_Timeout(3) = 1
							Send
							Select CmdRevFlexStr$(3)
								Case "Noise"
									Tester_Remark(3) = 1
								Default
									Tester_Remark(3) = 0
							Send
					Send
			Send
			CmdRevFlex$ = ""
		Else
			CloseNet #205
			Print "端口205关闭"
			Wait 0.1
			OpenNet #205 As Server
			Print "端口205重新打开"
			WaitNet #205
			Print "端口205重新连接"
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
'发送命令到上位机
Function TcpIpCmdSendFlex
	Integer chknet2, errTask
	OpenNet #206 As Server
	Print "端口206打开"
	WaitNet #206
	Print "端口206连接"
	Do
		OnErr GoTo NetErr
		chknet2 = ChkNet(206)
		If chknet2 >= 0 Then
			If CmdSendFlex$ <> "" Then
				Print #206, CmdSendFlex$
				Print "CmdSendFlex$： " + CmdSendFlex$
				CmdSendFlex$ = ""
			EndIf
		Else
			CloseNet #206
			Print "端口206关闭"
			Wait 0.1
			OpenNet #206 As Server
			Print "端口206重新打开"
			WaitNet #206
			Print "端口206重新连接"
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
Function StringSplit1(StrSplit$ As String, CharSelect$ As String)
	Integer findstr, i
	String RemainStr$
	RemainStr$ = StrSplit$
	i = 0
	findstr = InStr(RemainStr$, CharSelect$)
	Do While findstr <> -1
		CmdRevFlexStr$(i) = Mid$(RemainStr$, 1, findstr - 1)
		RemainStr$ = Mid$(RemainStr$, findstr + 1)
		i = i + 1
		findstr = InStr(RemainStr$, CharSelect$)
	Loop
	CmdRevFlexStr$(i) = RemainStr$
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
				Off ALRecify, Forced
'				Off AL_Suck, Forced



				Tester_Pass(0) = 0
				Tester_Ng(0) = 0
				Tester_Timeout(0) = 0
				Tester_Remark(0) = 0
				Print "测试机AL，开始测试"
				MsgSend$ = "测试机AL，开始测试"
				If CmdSendFlex$ <> "" Then
					Print "有命令 " + CmdSendFlex$ + " 待发送！"
				EndIf
				Do While CmdSendFlex$ <> ""
					Wait 0.1
				Loop
				CmdSendFlex$ = "Start,1," + PickAorC$(0)
				On ALRecify, Forced
				TmReset 0
'				Wait Sw(ALRear) = 0 And Sw(ALUp) = 0
				Do While Not (Tester_Pass(0) <> 0 Or Tester_Ng(0) <> 0 Or Tester_Timeout(0) <> 0)
					TesterTimeElapse(0) = Tmr(0)
					If voccumflag And Sw(ALUp) = 0 Then
						Wait 0.5
						Off AL_Suck, Forced
						Off ALRecify, Forced
						voccumflag = False
					EndIf
					If Tester_Select(0) = False Then
						Exit Do
					EndIf
					
					Wait 0.02
				Loop
				
				
				
				On AL_Suck, Forced
				Wait Sw(ALRear) = 1 And Sw(ALUp) = 1
				Off AL_Suck, Forced
				Off ALRecify, Forced
				TesterTimeElapse(0) = 0
				Tester_Testing(0) = False
			EndIf
		Else
			Tester_Fill(0) = False
			Tester_Testing(0) = False
			TesterTimeElapse(0) = 0
			Wait 0.1
			Off AL_Suck, Forced
			Off ALRecify, Forced
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
				Off ARRecify, Forced
				
				
				
				Tester_Pass(1) = 0
				Tester_Ng(1) = 0
				Tester_Timeout(1) = 0
				Tester_Remark(1) = 0
				Print "测试机AR，开始测试"
				MsgSend$ = "测试机AR，开始测试"
				If CmdSendFlex$ <> "" Then
					Print "有命令 " + CmdSendFlex$ + " 待发送！"
				EndIf
				Do While CmdSendFlex$ <> ""
					Wait 0.1
				Loop
				CmdSendFlex$ = "Start,2," + PickAorC$(1)
				On ARRecify, Forced
				TmReset 1
'				Wait Sw(ARRear) = 0 And Sw(ARUp) = 0
				Do While Not (Tester_Pass(1) <> 0 Or Tester_Ng(1) <> 0 Or Tester_Timeout(1) <> 0)
					TesterTimeElapse(1) = Tmr(1)
					If voccumflag And Sw(ARUp) = 0 Then
						Wait 0.5
						Off AR_Suck, Forced
						Off ARRecify, Forced
						voccumflag = False
					EndIf
					If Tester_Select(1) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop

				On AR_Suck, Forced
				Wait Sw(ARRear) = 1 And Sw(ARUp) = 1
				Off AR_Suck, Forced
				Off ARRecify, Forced
				TesterTimeElapse(1) = 0
				Tester_Testing(1) = False
			EndIf
		Else
			Tester_Fill(1) = False
			Tester_Testing(1) = False
			TesterTimeElapse(1) = 0
			Wait 0.1
			Off AR_Suck, Forced
			Off ARRecify, Forced
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
				Off BLRecify, Forced
'				Off BL_Suck, Forced


				Tester_Pass(2) = 0
				Tester_Ng(2) = 0
				Tester_Timeout(2) = 0
				Tester_Remark(2) = 0
				Print "测试机BL，开始测试"
				MsgSend$ = "测试机BL，开始测试"
				If CmdSendFlex$ <> "" Then
					Print "有命令 " + CmdSendFlex$ + " 待发送！"
				EndIf
				Do While CmdSendFlex$ <> ""
					Wait 0.1
				Loop
				CmdSendFlex$ = "Start,3," + PickAorC$(2)
				On BLRecify, Forced
				TmReset 2
'				Wait Sw(BLRear) = 0 And Sw(BLUp) = 0
				Do While Not (Tester_Pass(2) <> 0 Or Tester_Ng(2) <> 0 Or Tester_Timeout(2) <> 0)
					TesterTimeElapse(2) = Tmr(2)
					If voccumflag And Sw(BLUp) = 0 Then
						Wait 0.5
						Off BL_Suck, Forced
						Off BLRecify, Forced
						voccumflag = False
					EndIf
					If Tester_Select(2) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop

				On BL_Suck, Forced
				Wait Sw(BLRear) = 1 And Sw(BLUp) = 1
				Off BL_Suck, Forced
				Off BLRecify, Forced
				TesterTimeElapse(2) = 0
				Tester_Testing(2) = False
			EndIf
		Else
			Tester_Fill(2) = False
			Tester_Testing(2) = False
			TesterTimeElapse(2) = 0
			Wait 0.1
			Off BL_Suck, Forced
			Off BLRecify, Forced
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
				Off BRRecify, Forced
'				Off BR_Suck, Forced

				Tester_Pass(3) = 0
				Tester_Ng(3) = 0
				Tester_Timeout(3) = 0
				Tester_Remark(3) = 0
				Print "测试机BR，开始测试"
				MsgSend$ = "测试机BR，开始测试"
				If CmdSendFlex$ <> "" Then
					Print "有命令 " + CmdSendFlex$ + " 待发送！"
				EndIf
				Do While CmdSendFlex$ <> ""
					Wait 0.1
				Loop
				CmdSendFlex$ = "Start,4," + PickAorC$(3)
				On BRRecify, Forced
				TmReset 3
'				Wait Sw(BRRear) = 0 And Sw(BRUp) = 0
				Do While Not (Tester_Pass(3) <> 0 Or Tester_Ng(3) <> 0 Or Tester_Timeout(3) <> 0)
					TesterTimeElapse(3) = Tmr(3)
					If voccumflag And Sw(BRUp) = 0 Then
						Wait 0.5
						Off BR_Suck, Forced
						Off BRRecify, Forced
						voccumflag = False
					EndIf
					If Tester_Select(3) = False Then
						Exit Do
					EndIf
					Wait 0.02
				Loop
				
				
				On BR_Suck, Forced
				Wait Sw(BRRear) = 1 And Sw(BRUp) = 1
				Off BR_Suck, Forced
				Off BRRecify, Forced
				TesterTimeElapse(3) = 0
				Tester_Testing(3) = False
			EndIf
		Else
			Tester_Fill(3) = False
			Tester_Testing(3) = False
			TesterTimeElapse(3) = 0
			Wait 0.1
			Off BR_Suck, Forced
			Off BRRecify, Forced
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
	
	
	Off ALRecify, Forced
	Off ARRecify, Forced
	Off BLRecify, Forced
	Off BRRecify, Forced
	pickRetryTimes = 0
	Off Alarm_ReleaseFail, Forced
	Off Alarm_SuckFail, Forced
	

Fend

















































