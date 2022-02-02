#include "LIB\wd_core.au3"
#include "LIB\wd_helper.au3"
#include <GuiComboBoxEx.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>
#Include <Date.au3>
#include <MsgBoxConstants.au3>
#include <array.au3>
#include <StringConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <ComboConstants.au3>
#include <File.au3>
#include <String.au3>
#include "LIB\_HttpRequest.au3"
#include <Constants.au3>
Const $sFilePathTemp = @TempDir;'C:\Users\Administrator\AppData\Local\Temp\2'

Func DelTemp($sFilePath)
	local $chrome
	ConsoleWrite('>KILLING CHROME AND DRIVER'&@CRLF)
	for $chrome = 1 to 5
		Run("taskkill /F /T /IM chromedriver.exe", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		Sleep(200)
		;Run("taskkill /F /T /IM chrome.exe", "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Next
	ConsoleWrite('>REMOVE TEMP FOLER: '&$sFilePath&@CRLF)
	DirRemove($sFilePath, $DIR_REMOVE)
	Sleep(300)
	ConsoleWrite('>RECREAT TEMP FOLER: '&$sFilePath&@CRLF)
	DirCreate($sFilePath)
	Sleep(300)
EndFunc

DelTemp($sFilePathTemp)

Local $sDesiredCapabilities
$_WD_DEBUG = $_WD_DEBUG_None

Const $FILE_INPUT = 'LIST2.txt'
Const $FILE_LOG =  'LOG.txt'
Const $FILE_TEMP =  'TEMP.txt'
Const $FILE_UA =  'LIB\UA.txt'


Const $Element_Mail = '//input[@id="username"]'
Const $Element_Pass = '//input[@id="password"]'
Const $Element_Login = '//input[@id="kc-login"]'
Const $Element_NetError = '//button[@id="reload-button"]'
Const $Element_Url = 'https://connect.appen.com/qrp/core/vendors/workflows/view';

;==>[JAVASCRIPT HERE]=========

;==>[JAVASCRIPT HERE]=========


Local $hGUI = GUICreate("APPEN", 95, 110, 940, 80, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX))
Local $idButton_ = GUICtrlCreateButton("Run", 5, 5, 85, 25)
Local $idButton = GUICtrlCreateButton("Stop ALL", 5, 40, 85, 25)
GUISetState(@SW_SHOW)
WinSetOnTop("APPLE LOGIN", "", 1)


Func _FastInput($Session_, $PathID_ ,$Value_ )
 Local $Item_ = _WD_FindElement($Session_, $_WD_LOCATOR_ByXPath, $PathID_)
 _WD_ElementAction($Session_, $Item_,'value', $Value_)
 Sleep(Random(30, 50, 1))
EndFunc

Func Setup_Chrome($p__UA)
Local $iAltPort = 9516
_WD_Option('Driver', 'LIB\chromedriver.exe')
_WD_Option('Port', $iAltPort)
_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\chrome.log" --port='&$iAltPort)
;$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "excludeSwitches": [ "enable-automation"], "useAutomationExtension": false, ' & _
;         '"prefs": {"credentials_enable_service": false}}}}}'
$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "excludeSwitches": [ "enable-automation"], "useAutomationExtension": false, "prefs": {"credentials_enable_service": false, "profile.managed_default_content_settings.images": 2}, "args":["--user-agent='&$p__UA&'","--disable-blink-features=AutomationControlled"]}}}}';"headless",
EndFunc


While 1
	Sleep(10)
	$nMsg = GUIGetMsg()
	Switch $nMsg
	Case $GUI_EVENT_CLOSE
		ExitLoop
	Case $idButton_
		FileOpen($FILE_INPUT, 0)
		For $i = 1 to _FileCountLines($FILE_INPUT)

			Local $RandomLineUA = Random(1, _FileCountLines($FILE_UA) , 1)
			Local $UA_FINAL = FileReadLine($FILE_UA, $RandomLineUA)
			FileClose($FILE_UA)
			Setup_Chrome($UA_FINAL)
			ConsoleWrite('USING UA LINE: '&$RandomLineUA &' : '&$UA_FINAL&@CRLF)

			$line = FileReadLine($FILE_INPUT, $i)
			ConsoleWrite('===========================================================' & @CRLF)
			ConsoleWrite('i = ' & $i & ' ' & $line & @CRLF)

			Local $string = $line
			$var = Stringsplit ($string, Chr (9), 2)
			Local $Data_Mail = $var[0]
			Local $Data_Pass = $var[1]
			;Local $Data_Country = $var[2]

			Local $RandomLineUA = Random(1, _FileCountLines($FILE_UA) , 1)
			Local $UA_FINAL = FileReadLine($FILE_UA, $RandomLineUA)
			FileClose($FILE_UA)
			Setup_Chrome($UA_FINAL)
			ConsoleWrite('USING UA LINE: '&$RandomLineUA &' : '&$UA_FINAL&@CRLF)

			$iPID = _WD_Startup()

			ToolTip("WAITING LOGIN...", 940, 50, 'DANG LAY INFO...', $TIP_BALLOON)
			$Status = 'DONE'

			$RanWidth = Random(1024, @DesktopWidth, 1)
			$RanHeight = Random(768, @DesktopHeight, 1)


			$Session = _WD_CreateSession($sDesiredCapabilities)
			_WD_Window($Session, 'rect', '{"x":0,"y":0,"width":'&$RanWidth&',"height":'&$RanHeight&'}')

			_WD_Navigate($Session, $Element_Url)
			Sleep(300)
			$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, $Element_NetError)
			If $sElement then
				$Status = 'DIE'
				ToolTip("NETWORK ERROR - DIE PROXY", 940, 50, 'PROXY DIE', $TIP_BALLOON)
				$file = FileOpen($FILE_LOG, 1)
				FileWrite($file, $line & Chr (9) & $Status & @CRLF)
				FileClose($file)
				_WD_DeleteSession($Session)
				_WD_Shutdown()

			Else
				Sleep(300)
				_FastInput($Session, $Element_Mail ,$Data_Mail)
				ToolTip($Data_Mail, 940, 50, 'INPUT MAIL ' & @CRLF & ' ACCOUNT: ' & $i & @CRLF & ' TOTAL: ' & _FileCountLines($FILE_INPUT), $TIP_BALLOON)
				Sleep(300)
				_FastInput($Session, $Element_Pass ,$Data_Pass)
				Sleep(50)

				$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, $Element_Login)
				_WD_ElementAction($Session, $sElement, 'click')

				$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/section/div/div/div/div/div[2]/div/span[2]')
				$Element_Wrong = _WD_ElementAction($Session, $sElement, 'text')
					If $Element_Wrong = 'Invalid username or password.' then
						$Status = 'SAI_PASS'
						ToolTip($Data_Mail, 940, 50, 'WRONG ACC '&@CRLF&' ACCOUNT: '&$i&@CRLF&' TOTAL: '&_FileCountLines($FILE_INPUT), $TIP_BALLOON)
						$file = FileOpen($FILE_LOG, 1)
						FileWrite($file, $line & Chr (9) & $Status & @CRLF)
						FileClose($file)
						Sleep(10)
						_WD_DeleteSession($Session)
						_WD_Shutdown()
					Else
							Local $guidelines = ''
							$LinkLogin = _WD_Action($Session, 'url')
							if $LinkLogin = 'https://connect.appen.com/qrp/core/vendors/acknowledge_guidelines' then
								$guidelines = 'GUIDE_LINE'
								$file = FileOpen($FILE_LOG, 1)
								FileWrite($file, $line &@TAB& $guidelines & @CRLF)
								FileClose($file)

								For $UnknowLine = 3 to 30
									$lineLink = '/html/body/div[2]/div[3]/form/div[1]/div[1]/table/tbody/tr['&$UnknowLine&']/td[4]/a'
									$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, $lineLink)
									_WD_ElementAction($Session, $sElement, 'click')
									Sleep(200)
								Next
								_WD_Attach($Session, 'Appen Guidelines Acknowledgement Required')
								Sleep(200)
								For $UnknowButton = 0 to 30
									$ButtonLink = '//input[@id="acknowledge-guideline-'&$UnknowButton&'"]'
									$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, $ButtonLink)
									_WD_ElementAction($Session, $sElement, 'click')
									Sleep(100)
								Next


								Sleep(100)
								$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '//input[@name="acknowledge"]')
								_WD_ElementAction($Session, $sElement, 'click')
							EndIf

							_WD_Navigate($Session, 'https://connect.appen.com/qrp/core/vendors/payoneer_registration');'https://connect.appen.com/qrp/core/vendors/invoices')


							$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/h2')
							$Element_Deny = _WD_ElementAction($Session, $sElement, 'text')


							;_WD_Timeouts($Session, '{"pageLoad":50000}')
							$sElement = _WD_GetSource($Session)
							Local $USER_ID
							Local $USER_ID_FIND = StringRegExp($sElement, "USER_ID = '(.*)'",1)
							If Not @error then	 $USER_ID = $USER_ID_FIND[0]

							ConsoleWrite('$USER_ID: ' & $USER_ID & @CRLF)

							ConsoleWrite($line&@CRLF)

							$Json_profile = 'https://connect.appen.com/qrp/api/v2/services/user-service/users/'&$USER_ID&'/profile'
							_WD_Navigate($Session, $Json_profile)
							$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/pre')
							$g__Text_profile = _WD_ElementAction($Session, $sElement, 'text')
							$oJson_profile = _HttpRequest_ParseJSON($g__Text_profile)
							Local $userStatus = $oJson_profile.get('userStatus')

							if $Element_Deny = 'Access Denied' then $userStatus = 'TERMINATED'

							$file = FileOpen($FILE_TEMP, 1)
							FileWrite($file, $userStatus&@TAB&$line&@TAB)
							FileClose($file)

							If $userStatus = '' or $userStatus = Null then $i = $i-1

							$JsonLink = 'https://connect.appen.com/qrp/api/v2/services/project-service/vendorProjectList/'&$USER_ID&'/all'
							_WD_Navigate($Session, $JsonLink)
							$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/pre')
							$g__Text = _WD_ElementAction($Session, $sElement, 'text')
							$oJson = _HttpRequest_ParseJSON($g__Text)

							Local $projectCount = $oJson.projects.length()
							ConsoleWrite('PROJECT COUNT : ' & $projectCount & @CRLF)

								for $ii = 0 to $projectCount-1
									Local $JobName, $actions, $workType, $status, $Description, $longName

									$JobName = $oJson.get('projects['&$ii&'].projectAlias')
									$actions = $oJson.get('projects['&$ii&'].actions[0]')
									$workType = $oJson.get('projects['&$ii&'].workType')

									If $actions = 'APPLY' then;'APPLIED_OPTIONS;WORK_THIS;APPLY
Local $Junk = 'Gravel Amur Maitengwe Shoshone Dorian Dorian - AIR Pecwan Pecwan - AIR Rattle Texcoco Dutch v2 Inari-C Pecwan - EQ Ivishak Anahulu Nida FY21 Simpson-CS Simpson-PF Sphinx-FR Ivindo-LC AuSable Sepulga Banda Bosque Gregorio Nepean Anahulu-LC Selway Vistula FY21 Chariton Tilton Korean Tokenisation Oct 2020 Longfellow II Cloquallum Butler Pic-A-Boo Cedar Yost Nida FY22 Vistula FY22 Truckee Milpitas Phillips Auditors Amur -  Group 1 Amur -  Group 2 Pocomoke'

			If $JobName = 'Arrow Pic-A-Boo' then $JobName = 'Pic-A-Boo'
			If $JobName = 'Arrow Butler' then $JobName = 'Butler'

			If StringInStr('LINGUISTICS SEARCH_EVALUATION SOCIAL_MEDIA WEB_RESEARCH DATA_COLLECTION TRANSCRIPTION', $workType) and Not StringInStr($Junk, $JobName) then;DATA_COLLECTION;TRANSCRIPTION
												$file = FileOpen($FILE_TEMP, 1)
												FileWrite($file, $JobName & @TAB)
												FileClose($file)
			EndIf

			EndIf;==>$actions = 'APPLY'
		Next;==>for $ii = 0


							_WD_Navigate($Session, 'https://connect.appen.com/qrp/core/vendors/workflows')
							Sleep(100)
							$aElements = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/div[2]/div[3]/table/tbody/tr/td/div', "", True)
							$iLines = UBound($aElements)
							Local $aTable[$iLines][4]
							For $iii = 0 To UBound($aElements)-1
								$check_name_or_status = _WD_ElementAction($Session, $aElements[$iii], "Text")
								if (StringInStr($check_name_or_status, 'Qualification')) <> 0 then
									$aTable[$iii][0] = $check_name_or_status
								ElseIf (StringInStr($check_name_or_status, 'View')) <> 0 then
									$aTable[$iii-1][1] = $check_name_or_status
								EndIf
							Next
							_Array2DDeleteEmptyRows($aTable)
							$ViewTask = '//div[@class="actions right"]//a'
							$sElement_ViewTask = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, $ViewTask, '', True, False)
							for $count = 0 to ubound($sElement_ViewTask)-1
								$link_view_task = _WD_ElementAction($Session, $sElement_ViewTask[$count], 'attribute', 'href')
								$aTable[$count][2] = 'https://connect.appen.com'&$link_view_task
							Next
							$Content = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/div[2]/div[3]/table/tbody/tr/td', "", True)
							For $ii = 0 To UBound($Content)-1
								$get_content = _WD_ElementAction($Session, $Content[$ii], "Text")
								$get_content = StringStripWS($get_content, 8)
								$get_content = StringReplace($get_content, 'ViewTask', "")
								$get_content = StringReplace($get_content, 'Thisprocessiscurrentlyinprogress,butthereisnothingforyoutodoatthistime.Ifyouwishtoviewthelateststatusofthisprocess,pleaseclick"ViewStatus".', "")
								$get_content = StringReplace($get_content, 'Thisprocessiscurrentlyinprogressandwearewaitingonsomeinformationfromyoubeforewecancontinue.Pleasecheckyouremailforadditionalinstructions.Pleasecompletethefollowingtask:', "")
								$get_content = StringReplace($get_content, 'Thisprocessiscurrentlyinprogress,butthereisnothingforyoutodoatthistime.', "")
								$get_content = StringRegExpReplace($get_content, '(.*)Qualification', "")
								$get_content = StringReplace($get_content, 'ViewStatus', "")
								$aTable[$ii][3] = $get_content
							Next
							Local $aTable_Temp[$iLines]
							For $copy = 0 to UBound($aTable)-1
										$aTable_Temp[$copy] = $aTable[$copy][2]
							Next

							For $empty_name = 0 to UBound($aTable)-1
								if ($aTable[$empty_name][1] = '') Then
									_ArrayInsert($aTable_Temp, $empty_name, "NOTHING HERE")
								Else
								EndIf
							Next
							_Array1DDeleteEmptyRows($aTable_Temp)

							For $move_array_remove_ori = 0 to UBound($aTable)-1
								$aTable[$move_array_remove_ori][2] = ''
							Next

							For $move_array = 0 to UBound($aTable)-1
								$aTable[$move_array][2] = $aTable_Temp[$move_array]
							Next
							;_ArrayDisplay($aTable)
							For $check_task = 0 to UBound($aTable)-1
								If $aTable[$check_task][1] = 'View Task' and $aTable[$check_task][3] = 'Completescreeningquiz' Then
									_WD_Navigate($Session, $aTable[$check_task][2])
									$sElement = _WD_FindElement($Session, $_WD_LOCATOR_ByXPath, '/html/body/div[2]/div[3]/form/div[3]/p')
									$has_question = _WD_ElementAction($Session, $sElement, 'Text')
									if (StringInStr($has_question, 'Question')) <> 0 Then
										$file = FileOpen($FILE_LOG, 1)
										FileWrite($file, 'TASK_VIEW'&@TAB&$line&@TAB&$aTable[$check_task][0] & @TAB & $aTable[$check_task][2] & @TAB& 'Found ' & $has_question & @CRLF)
										FileClose($file)
									EndIf
						ElseIf $aTable[$check_task][1] = 'View Task' and (($aTable[$check_task][3] <> 'Completescreeningquiz') or ($aTable[$check_task][3] <> '') or ($aTable[$check_task][3] <> null )) Then
									$file = FileOpen($FILE_LOG, 1)
										FileWrite($file, 'TASK_VIEW'&@TAB&$line&@TAB&$aTable[$check_task][0] & @TAB & $aTable[$check_task][2] & @TAB& $aTable[$check_task][3] & @CRLF)
										FileClose($file)

								EndIf
							Next

							$file = FileOpen($FILE_TEMP, 1)
							FileWrite($file, @CRLF)
							FileClose($file)


					_WD_DeleteSession($Session)
					_WD_Shutdown()
					ConsoleWrite('=============================Shutdown=======================' & @CRLF)
					DelTemp($sFilePathTemp)
					Sleep(10)
					ToolTip($Data_Mail, 940, 50, 'APPLY DONE', $TIP_BALLOON)
				EndIf;==>If $Element_Wrong = 'Invalid username or password.'
			EndIf;==>$sElement then
		Next
	Case $idButton
		_WD_DeleteSession($Session)
		_WD_Shutdown()
		ExitLoop
	EndSwitch
WEnd

Func _Array2DDeleteEmptyRows(ByRef $iArray)
    Local $vEmpty = True
    For $i = UBound($iArray) - 1 To 0 Step -1
        For $j = 0 To UBound($iArray, 2)-1 Step 1
            If $iArray[$i][$j] <> "" Then
                $vEmpty = False
            EndIf
        Next
        If $vEmpty = True Then _ArrayDelete($iArray, $i)
        $vEmpty = True
    Next
EndFunc
Func _Array1DDeleteEmptyRows(ByRef $iArray)
    Local $vEmpty = True
    For $i = UBound($iArray) - 1 To 0 Step -1
            If $iArray[$i] <> "" Then
                $vEmpty = False
            EndIf
        If $vEmpty = True Then _ArrayDelete($iArray, $i)
        $vEmpty = True
    Next
EndFunc
