-- Healing Groups Suck v1.9.1
-- Written by The_Groove updated by Lilamystiqu on Lothar

--Change this to increase the number of sets
HGS_SETS = 60;

--Localization stuff
HGS_DRUID = "Druid";
HGS_SHAMAN = "Shaman";
HGS_PRIEST = "Priest";
HGS_PALADIN = "Paladin";

if ( GetLocale() == "frFR" ) then
	HGS_DRUID = "Druide";
	HGS_SHAMAN = "Chaman";
	HGS_PRIEST = "Pr\195\170tre";
	HGS_PALADIN = "Paladin";
end

if ( GetLocale() == "deDE") then
	HGS_DRUID = "Druid";
	HGS_SHAMAN = "Schaman";
	HGS_PRIEST = "Priester";
	HGS_PALADIN = "Paladin";
end	
	
function HGS_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("CHAT_MSG_WHISPER");
	this:RegisterEvent("UNIT_NAME_UPDATE");

	SlashCmdList["HGS"] = HGSCommand;
	SLASH_HGS1 = "/healingroupsuck";
	SLASH_HGS2 = "/hgs";
end

function HGS_OnEvent(event, arg1)

	if (event == "CHAT_MSG_WHISPER") then
	
	local msg = arg1;
	local plr = arg2;
	if((msg == "HGS") or (msg == "hgs")) then
	HGS_PlayerBCast(plr);
	end

	elseif (event == "VARIABLES_LOADED") then
		DEFAULT_CHAT_FRAME:AddMessage("HGS Loaded.", 0.3,0.6,0.3);
		if (HGSData == nil) then
			HGS_FullReset();
		end
		HGS_Init();
		HGS_Refresh();
		Instance = HGSData["InsCurr"];
	end
end

function HGSCommand(msg)
	if (msg == "reset") then
	DEFAULT_CHAT_FRAME:AddMessage("HGS Groups Reset", 0.3, 0.6, 0.3);
		HGS_FullReset();
		HGSUpdate();
	end
	if (msg == "show") then
	DEFAULT_CHAT_FRAME:AddMessage("HGS Minimap Icon Shown", 0.3, 0.6, 0.3);
		HGSMiniMap:Show();
	end
	if (msg == "refresh") then
	DEFAULT_CHAT_FRAME:AddMessage("HGS Healers Refreshed", 0.3, 0.6, 0.3);
		HGS_Refresh();
	end
	if (msg == "hide") then
	DEFAULT_CHAT_FRAME:AddMessage("HGS Minimap Icon Hidden", 0.3, 0.6, 0.3);
		HGSMiniMap:Hide();
		HGSFrame:Hide();
	end
	if (msg == "open") then
		HGS_ShowFrame();
	end
	if (msg == "bc") then
		HGS_Broadcast();
	end
	if (string.sub (msg, 1, 4) == "pos ") then
	local ang = tonumber (string.sub (msg, 5, 7));
		HGSData["IconPos"]=ang;
		HGS_IconPos(ang);
	end
	
	if (msg == "") then
		DEFAULT_CHAT_FRAME:AddMessage("~ Healing Groups Suck v1.9.1 ~", 0.5, 1, 0.5);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs show - Shows the minimap icon", 0.3, 0.6, 0.3);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs hide - Hides the minimap icon", 0.3, 0.6, 0.3);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs open - Opens the group window", 0.3, 0.6, 0.3);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs refresh - Refresh the list of healers", 0.3, 0.6, 0.3);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs reset - Warning: Resets EVERYTHING", 0.3, 0.6, 0.3);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs bc - Broadcasts: "..HGSInstanceText:GetText(), 0.3, 0.6, 0.3);
		DEFAULT_CHAT_FRAME:AddMessage("/hgs pos # - Set minimap icon position (0-360)", 0.3, 0.6, 0.3);
	end
end

function HGS_ShowFrame()
	if(HGSFrame:IsVisible()) then
		HGSFrame:Hide();
	else
		HGSUpdate();
		HGSFrame:Show();
	end
end

function HGS_MiniMapClick(button)
	if (button == "LeftButton") then
		if(HGSFrame:IsVisible()) then
			HGSFrame:Hide();
		else
			HGSUpdate();
			HGSFrame:Show();
		end
	end
end

function SetGroupFont(healer,group,slot)
	if (HGSData[Instance][group][slot]["Class"] == HGS_PRIEST) then
		healer:SetTextColor(1,1,1);
	elseif (HGSData[Instance][group][slot]["Class"] == HGS_DRUID) then
		healer:SetTextColor(0.9,0.5,0);
	elseif (HGSData[Instance][group][slot]["Class"] == HGS_SHAMAN) then
		healer:SetTextColor(0.3,0.3,1);
   elseif (HGSData[Instance][group][slot]["Class"] == HGS_PALADIN) then
		healer:SetTextColor(1.0,0.5,0.75);
	elseif (HGSData[Instance][group][slot]["Class"] == "Other") then
		healer:SetTextColor(0.7,0.7,0.7);
	end
end

function SetHealerFont(healer,id)
	if (HGSData["Healers"][id]["Class"] == HGS_PRIEST) then
		healer:SetTextColor(1,1,1);
	elseif (HGSData["Healers"][id]["Class"] == HGS_DRUID) then
		healer:SetTextColor(0.9,0.5,0);
	elseif (HGSData["Healers"][id]["Class"] == HGS_SHAMAN)  then
		healer:SetTextColor(0.3,0.3,1);
   elseif (HGSData["Healers"][id]["Class"] == HGS_PALADIN) then
      healer:SetTextColor(1.0,0.5,0.75);
	elseif (HGSData["Healers"][id]["Class"] == "Other") then
		healer:SetTextColor(0.7,0.7,0.7);
	end
	if (HGSData["Healers"][id]["IsChosen"][Instance] == 1) then
		healer:SetTextColor(0.3,0.3,0.3);
	end
end

function UpdateFonts()
	SetHealerFont(Healer1text,1);
	SetHealerFont(Healer2text,2);
	SetHealerFont(Healer3text,3);
	SetHealerFont(Healer4text,4);
	SetHealerFont(Healer5text,5);
	SetHealerFont(Healer6text,6);
	SetHealerFont(Healer7text,7);
	SetHealerFont(Healer8text,8);
	SetHealerFont(Healer9text,9);
	SetHealerFont(Healer10text,10);
	SetHealerFont(Healer11text,11);
	SetHealerFont(Healer12text,12);
	SetHealerFont(Healer13text,13);
	SetHealerFont(Healer14text,14);
	SetHealerFont(Healer15text,15);
	SetHealerFont(Healer16text,16);
	SetHealerFont(Healer17text,17);
	SetHealerFont(Healer18text,18);
	SetHealerFont(Healer19text,19);
	SetHealerFont(Healer20text,20);
	SetHealerFont(Healer21text,21);
	SetHealerFont(Healer22text,22);
	SetHealerFont(Healer23text,23);
	SetHealerFont(Healer24text,24);
	SetHealerFont(Healer25text,25);
	SetHealerFont(Healer26text,26);
	SetHealerFont(Healer27text,27);
	SetHealerFont(Healer28text,28);
	SetHealerFont(Healer29text,29);
	SetHealerFont(Healer30text,30);
	SetHealerFont(Healer31text,31);
	SetHealerFont(Healer32text,32);
	SetHealerFont(Healer33text,33);
	SetHealerFont(Healer34text,34);
	SetHealerFont(Healer35text,35);
	SetHealerFont(Healer36text,36);
    SetHealerFont(Healer37text,37);
	
	SetGroupFont(G1Box1text,1,1);
	SetGroupFont(G1Box2text,1,2);
	SetGroupFont(G1Box3text,1,3);
	SetGroupFont(G1Box4text,1,4);
	SetGroupFont(G1Box5text,1,5);
	SetGroupFont(G1Box6text,1,6);
	SetGroupFont(G1Box7text,1,7);
	SetGroupFont(G1Box8text,1,8);
	SetGroupFont(G1Box9text,1,9);
	SetGroupFont(G1Box10text,1,10);
	SetGroupFont(G1Box11text,1,11);
	SetGroupFont(G1Box12text,1,12);

	SetGroupFont(G2Box1text,2,1);
	SetGroupFont(G2Box2text,2,2);
	SetGroupFont(G2Box3text,2,3);
	SetGroupFont(G2Box4text,2,4);
	SetGroupFont(G2Box5text,2,5);
	SetGroupFont(G2Box6text,2,6);
	SetGroupFont(G2Box7text,2,7);
	SetGroupFont(G2Box8text,2,8);
	SetGroupFont(G2Box9text,2,9);
	SetGroupFont(G2Box10text,2,10);
	SetGroupFont(G2Box11text,2,11);
	SetGroupFont(G2Box12text,2,12);

	SetGroupFont(G3Box1text,3,1);
	SetGroupFont(G3Box2text,3,2);
	SetGroupFont(G3Box3text,3,3);
	SetGroupFont(G3Box4text,3,4);
	SetGroupFont(G3Box5text,3,5);
	SetGroupFont(G3Box6text,3,6);
	SetGroupFont(G3Box7text,3,7);
	SetGroupFont(G3Box8text,3,8);
	SetGroupFont(G3Box9text,3,9);
	SetGroupFont(G3Box10text,3,10);
	SetGroupFont(G3Box11text,3,11);
	SetGroupFont(G3Box12text,3,12);

	SetGroupFont(G4Box1text,4,1);
	SetGroupFont(G4Box2text,4,2);
	SetGroupFont(G4Box3text,4,3);
	SetGroupFont(G4Box4text,4,4);
	SetGroupFont(G4Box5text,4,5);
	SetGroupFont(G4Box6text,4,6);
	SetGroupFont(G4Box7text,4,7);
	SetGroupFont(G4Box8text,4,8);
	SetGroupFont(G4Box9text,4,9);
	SetGroupFont(G4Box10text,4,10);
	SetGroupFont(G4Box11text,4,11);
	SetGroupFont(G4Box12text,4,12);

	SetGroupFont(G5Box1text,5,1);
	SetGroupFont(G5Box2text,5,2);
	SetGroupFont(G5Box3text,5,3);
	SetGroupFont(G5Box4text,5,4);
	SetGroupFont(G5Box5text,5,5);
	SetGroupFont(G5Box6text,5,6);
	SetGroupFont(G5Box7text,5,7);
	SetGroupFont(G5Box8text,5,8);
	SetGroupFont(G5Box9text,5,9);
	SetGroupFont(G5Box10text,5,10);
	SetGroupFont(G5Box11text,5,11);
	SetGroupFont(G5Box12text,5,12);

	SetGroupFont(G6Box1text,6,1);
	SetGroupFont(G6Box2text,6,2);
	SetGroupFont(G6Box3text,6,3);
	SetGroupFont(G6Box4text,6,4);
	SetGroupFont(G6Box5text,6,5);
	SetGroupFont(G6Box6text,6,6);
	SetGroupFont(G6Box7text,6,7);
	SetGroupFont(G6Box8text,6,8);
	SetGroupFont(G6Box9text,6,9);
	SetGroupFont(G6Box10text,6,10);
	SetGroupFont(G6Box11text,6,11);
	SetGroupFont(G6Box12text,6,12);

	SetGroupFont(G7Box1text,7,1);
	SetGroupFont(G7Box2text,7,2);
	SetGroupFont(G7Box3text,7,3);
	SetGroupFont(G7Box4text,7,4);
	SetGroupFont(G7Box5text,7,5);
	SetGroupFont(G7Box6text,7,6);
	SetGroupFont(G7Box7text,7,7);
	SetGroupFont(G7Box8text,7,8);
	SetGroupFont(G7Box9text,7,9);
	SetGroupFont(G7Box10text,7,10);
	SetGroupFont(G7Box11text,7,11);
	SetGroupFont(G7Box12text,7,12);

	SetGroupFont(G8Box1text,8,1);
	SetGroupFont(G8Box2text,8,2);
	SetGroupFont(G8Box3text,8,3);
	SetGroupFont(G8Box4text,8,4);
	SetGroupFont(G8Box5text,8,5);
	SetGroupFont(G8Box6text,8,6);
	SetGroupFont(G8Box7text,8,7);
	SetGroupFont(G8Box8text,8,8);
	SetGroupFont(G8Box9text,8,9);
	SetGroupFont(G8Box10text,8,10);
	SetGroupFont(G8Box11text,8,11);
	SetGroupFont(G8Box12text,8,12);
end


function HGSUpdate()
	UpdateFonts();
	Healer1text:SetText(HGSData["Healers"][1]["Name"]);
	Healer2text:SetText(HGSData["Healers"][2]["Name"]);
	Healer3text:SetText(HGSData["Healers"][3]["Name"]);
	Healer4text:SetText(HGSData["Healers"][4]["Name"]);
	Healer5text:SetText(HGSData["Healers"][5]["Name"]);
	Healer6text:SetText(HGSData["Healers"][6]["Name"]);
	Healer7text:SetText(HGSData["Healers"][7]["Name"]);
	Healer8text:SetText(HGSData["Healers"][8]["Name"]);
	Healer9text:SetText(HGSData["Healers"][9]["Name"]);
	Healer10text:SetText(HGSData["Healers"][10]["Name"]);
	Healer11text:SetText(HGSData["Healers"][11]["Name"]);
	Healer12text:SetText(HGSData["Healers"][12]["Name"]);
	Healer13text:SetText(HGSData["Healers"][13]["Name"]);
	Healer14text:SetText(HGSData["Healers"][14]["Name"]);
	Healer15text:SetText(HGSData["Healers"][15]["Name"]);
	Healer16text:SetText(HGSData["Healers"][16]["Name"]);
	Healer17text:SetText(HGSData["Healers"][17]["Name"]);
	Healer18text:SetText(HGSData["Healers"][18]["Name"]);
	Healer19text:SetText(HGSData["Healers"][19]["Name"]);
	Healer20text:SetText(HGSData["Healers"][20]["Name"]);
	Healer21text:SetText(HGSData["Healers"][21]["Name"]);
	Healer22text:SetText(HGSData["Healers"][22]["Name"]);
	Healer23text:SetText(HGSData["Healers"][23]["Name"]);
	Healer24text:SetText(HGSData["Healers"][24]["Name"]);
	Healer25text:SetText(HGSData["Healers"][25]["Name"]);
	Healer26text:SetText(HGSData["Healers"][26]["Name"]);
	Healer27text:SetText(HGSData["Healers"][27]["Name"]);
	Healer28text:SetText(HGSData["Healers"][28]["Name"]);
	Healer29text:SetText(HGSData["Healers"][29]["Name"]);
	Healer30text:SetText(HGSData["Healers"][30]["Name"]);
	Healer31text:SetText(HGSData["Healers"][31]["Name"]);
	Healer32text:SetText(HGSData["Healers"][32]["Name"]);
	Healer33text:SetText(HGSData["Healers"][33]["Name"]);
	Healer34text:SetText(HGSData["Healers"][34]["Name"]);
	Healer35text:SetText(HGSData["Healers"][35]["Name"]);
	Healer36text:SetText(HGSData["Healers"][36]["Name"]);
   Healer37text:SetText(HGSData["Healers"][37]["Name"]);

	G1Box1text:SetText(HGSData[Instance][1][1]["Name"]);
	G1Box2text:SetText(HGSData[Instance][1][2]["Name"]);
	G1Box3text:SetText(HGSData[Instance][1][3]["Name"]);
	G1Box4text:SetText(HGSData[Instance][1][4]["Name"]);
	G1Box5text:SetText(HGSData[Instance][1][5]["Name"]);
	G1Box6text:SetText(HGSData[Instance][1][6]["Name"]);
	G1Box7text:SetText(HGSData[Instance][1][7]["Name"]);
	G1Box8text:SetText(HGSData[Instance][1][8]["Name"]);
	G1Box9text:SetText(HGSData[Instance][1][9]["Name"]);
	G1Box10text:SetText(HGSData[Instance][1][10]["Name"]);
	G1Box11text:SetText(HGSData[Instance][1][11]["Name"]);
	G1Box12text:SetText(HGSData[Instance][1][12]["Name"]);

	G2Box1text:SetText(HGSData[Instance][2][1]["Name"]);
	G2Box2text:SetText(HGSData[Instance][2][2]["Name"]);
	G2Box3text:SetText(HGSData[Instance][2][3]["Name"]);
	G2Box4text:SetText(HGSData[Instance][2][4]["Name"]);
	G2Box5text:SetText(HGSData[Instance][2][5]["Name"]);
	G2Box6text:SetText(HGSData[Instance][2][6]["Name"]);
	G2Box7text:SetText(HGSData[Instance][2][7]["Name"]);
	G2Box8text:SetText(HGSData[Instance][2][8]["Name"]);
	G2Box9text:SetText(HGSData[Instance][2][9]["Name"]);
	G2Box10text:SetText(HGSData[Instance][2][10]["Name"]);
	G2Box11text:SetText(HGSData[Instance][2][11]["Name"]);
	G2Box12text:SetText(HGSData[Instance][2][12]["Name"]);

	G3Box1text:SetText(HGSData[Instance][3][1]["Name"]);
	G3Box2text:SetText(HGSData[Instance][3][2]["Name"]);
	G3Box3text:SetText(HGSData[Instance][3][3]["Name"]);
	G3Box4text:SetText(HGSData[Instance][3][4]["Name"]);
	G3Box5text:SetText(HGSData[Instance][3][5]["Name"]);
	G3Box6text:SetText(HGSData[Instance][3][6]["Name"]);
	G3Box7text:SetText(HGSData[Instance][3][7]["Name"]);
	G3Box8text:SetText(HGSData[Instance][3][8]["Name"]);
	G3Box9text:SetText(HGSData[Instance][3][9]["Name"]);
	G3Box10text:SetText(HGSData[Instance][3][10]["Name"]);
	G3Box11text:SetText(HGSData[Instance][3][11]["Name"]);
	G3Box12text:SetText(HGSData[Instance][3][12]["Name"]);

	G4Box1text:SetText(HGSData[Instance][4][1]["Name"]);
	G4Box2text:SetText(HGSData[Instance][4][2]["Name"]);
	G4Box3text:SetText(HGSData[Instance][4][3]["Name"]);
	G4Box4text:SetText(HGSData[Instance][4][4]["Name"]);
	G4Box5text:SetText(HGSData[Instance][4][5]["Name"]);
	G4Box6text:SetText(HGSData[Instance][4][6]["Name"]);
	G4Box7text:SetText(HGSData[Instance][4][7]["Name"]);
	G4Box8text:SetText(HGSData[Instance][4][8]["Name"]);
	G4Box9text:SetText(HGSData[Instance][4][9]["Name"]);
	G4Box10text:SetText(HGSData[Instance][4][10]["Name"]);
	G4Box11text:SetText(HGSData[Instance][4][11]["Name"]);
	G4Box12text:SetText(HGSData[Instance][4][12]["Name"]);

	G5Box1text:SetText(HGSData[Instance][5][1]["Name"]);
	G5Box2text:SetText(HGSData[Instance][5][2]["Name"]);
	G5Box3text:SetText(HGSData[Instance][5][3]["Name"]);
	G5Box4text:SetText(HGSData[Instance][5][4]["Name"]);
	G5Box5text:SetText(HGSData[Instance][5][5]["Name"]);
	G5Box6text:SetText(HGSData[Instance][5][6]["Name"]);
	G5Box7text:SetText(HGSData[Instance][5][7]["Name"]);
	G5Box8text:SetText(HGSData[Instance][5][8]["Name"]);
	G5Box9text:SetText(HGSData[Instance][5][9]["Name"]);
	G5Box10text:SetText(HGSData[Instance][5][10]["Name"]);
	G5Box11text:SetText(HGSData[Instance][5][11]["Name"]);
	G5Box12text:SetText(HGSData[Instance][5][12]["Name"]);

	G6Box1text:SetText(HGSData[Instance][6][1]["Name"]);
	G6Box2text:SetText(HGSData[Instance][6][2]["Name"]);
	G6Box3text:SetText(HGSData[Instance][6][3]["Name"]);
	G6Box4text:SetText(HGSData[Instance][6][4]["Name"]);
	G6Box5text:SetText(HGSData[Instance][6][5]["Name"]);
	G6Box6text:SetText(HGSData[Instance][6][6]["Name"]);
	G6Box7text:SetText(HGSData[Instance][6][7]["Name"]);
	G6Box8text:SetText(HGSData[Instance][6][8]["Name"]);
	G6Box9text:SetText(HGSData[Instance][6][9]["Name"]);
	G6Box10text:SetText(HGSData[Instance][6][10]["Name"]);
	G6Box11text:SetText(HGSData[Instance][6][11]["Name"]);
	G6Box12text:SetText(HGSData[Instance][6][12]["Name"]);

	G7Box1text:SetText(HGSData[Instance][7][1]["Name"]);
	G7Box2text:SetText(HGSData[Instance][7][2]["Name"]);
	G7Box3text:SetText(HGSData[Instance][7][3]["Name"]);
	G7Box4text:SetText(HGSData[Instance][7][4]["Name"]);
	G7Box5text:SetText(HGSData[Instance][7][5]["Name"]);
	G7Box6text:SetText(HGSData[Instance][7][6]["Name"]);
	G7Box7text:SetText(HGSData[Instance][7][7]["Name"]);
	G7Box8text:SetText(HGSData[Instance][7][8]["Name"]);
	G7Box9text:SetText(HGSData[Instance][7][9]["Name"]);
	G7Box10text:SetText(HGSData[Instance][7][10]["Name"]);
	G7Box11text:SetText(HGSData[Instance][7][11]["Name"]);
	G7Box12text:SetText(HGSData[Instance][7][12]["Name"]);

	G8Box1text:SetText(HGSData[Instance][8][1]["Name"]);
	G8Box2text:SetText(HGSData[Instance][8][2]["Name"]);
	G8Box3text:SetText(HGSData[Instance][8][3]["Name"]);
	G8Box4text:SetText(HGSData[Instance][8][4]["Name"]);
	G8Box5text:SetText(HGSData[Instance][8][5]["Name"]);
	G8Box6text:SetText(HGSData[Instance][8][6]["Name"]);
	G8Box7text:SetText(HGSData[Instance][8][7]["Name"]);
	G8Box8text:SetText(HGSData[Instance][8][8]["Name"]);
	G8Box9text:SetText(HGSData[Instance][8][9]["Name"]);
	G8Box10text:SetText(HGSData[Instance][8][10]["Name"]);
	G8Box11text:SetText(HGSData[Instance][8][11]["Name"]);
	G8Box12text:SetText(HGSData[Instance][8][12]["Name"]);

	HGSGroup1Text:SetText(HGSData[Instance][1]["Name"]);
	HGSGroup2Text:SetText(HGSData[Instance][2]["Name"]);
	HGSGroup3Text:SetText(HGSData[Instance][3]["Name"]);
	HGSGroup4Text:SetText(HGSData[Instance][4]["Name"]);
	HGSGroup5Text:SetText(HGSData[Instance][5]["Name"]);
	HGSGroup6Text:SetText(HGSData[Instance][6]["Name"]);
	HGSGroup7Text:SetText(HGSData[Instance][7]["Name"]);
	HGSGroup8Text:SetText(HGSData[Instance][8]["Name"]);

	if(HGSData[Instance][1]["Name"] ~= "Group1") then
		HGSGroup1Box:SetText(HGSData[Instance][1]["Name"]);
	else
		HGSGroup1Box:SetText("");
	end
	if(HGSData[Instance][2]["Name"] ~= "Group2") then
		HGSGroup2Box:SetText(HGSData[Instance][2]["Name"]);
	else
		HGSGroup2Box:SetText("");
	end
	if(HGSData[Instance][3]["Name"] ~= "Group3") then
		HGSGroup3Box:SetText(HGSData[Instance][3]["Name"]);
	else
		HGSGroup3Box:SetText("");
	end
	if(HGSData[Instance][4]["Name"] ~= "Group4") then
		HGSGroup4Box:SetText(HGSData[Instance][4]["Name"]);
	else
		HGSGroup4Box:SetText("");
	end
	if(HGSData[Instance][5]["Name"] ~= "Group5") then
		HGSGroup5Box:SetText(HGSData[Instance][5]["Name"]);
	else
		HGSGroup5Box:SetText("");
	end
	if(HGSData[Instance][6]["Name"] ~= "Group6") then
		HGSGroup6Box:SetText(HGSData[Instance][6]["Name"]);
	else
		HGSGroup6Box:SetText("");
	end
	if(HGSData[Instance][7]["Name"] ~= "Group7") then
		HGSGroup7Box:SetText(HGSData[Instance][7]["Name"]);
	else
		HGSGroup7Box:SetText("");
	end
	if(HGSData[Instance][8]["Name"] ~= "Group8") then
		HGSGroup8Box:SetText(HGSData[Instance][8]["Name"]);
	else
		HGSGroup8Box:SetText("");
	end

	ChannelBox:SetText(HGSData["Channel"]);
	HGSInstanceText:SetText(Instance.." - "..HGSData[Instance]["Name"]);
	--HGSCurrChan:SetText("sending to "..HGSData["Channel"]);
	HGSChanText:SetText("Channel: "..HGSData["Channel"]);
	
	InstanceBox:SetText(HGSData[Instance]["Name"]);
	HGSActiveText:SetText(HGSData[Instance][HGSData[Instance]["Active"]]["Name"]);
	HGSHealerText:SetText(HGSData[Instance]["Number"].."/"..HealerCount);
	CommentBox:SetText(HGSData[Instance]["Comment"]);
	
	HGS_IconPos(HGSData["IconPos"]);
	
end 

function GroupBox_SetName()
	if(this:GetText() == "") then
		HGSData[Instance][this:GetID()]["Name"] = "Group"..this:GetID();
	else
		HGSData[Instance][this:GetID()]["Name"] = this:GetText();
	end
	HGSGroup1Text:SetText(HGSData[Instance][1]["Name"]);
	HGSGroup2Text:SetText(HGSData[Instance][2]["Name"]);
	HGSGroup3Text:SetText(HGSData[Instance][3]["Name"]);
	HGSGroup4Text:SetText(HGSData[Instance][4]["Name"]);
	HGSGroup5Text:SetText(HGSData[Instance][5]["Name"]);
	HGSGroup6Text:SetText(HGSData[Instance][6]["Name"]);
	HGSGroup7Text:SetText(HGSData[Instance][7]["Name"]);
	HGSGroup8Text:SetText(HGSData[Instance][8]["Name"]);
	HGSActiveText:SetText(HGSData[Instance][this:GetID()]["Name"]);
	HGSData[Instance]["Active"] = this:GetID();
end

function Healer_OnClick()
	local Healer = HGSData["Healers"][this:GetID()]["Name"];
	local Class = HGSData["Healers"][this:GetID()]["Class"];
	local HGroupID = HGSData[Instance]["Active"];

	if(this:GetID() <= HealerCount or this:GetID() >= 25) then
		if(HGSData[Instance][HGroupID]["Count"] < 12) then
			HGSData["Healers"][this:GetID()]["IsChosen"][Instance] = 1;
			HGS_AddHealer(Healer,Class,HGroupID); 
		end
	end
end

function Group_OnClick()
	local HSlot;
	local HGroup = this:GetName();
	local HGroupID = this:GetID();

	if(string.find(HGroup, "Box1$")) then
		HSlot = 1;
	elseif (string.find(HGroup, "Box2")) then
		HSlot = 2;
	elseif (string.find(HGroup, "Box3")) then	
		HSlot = 3;
	elseif (string.find(HGroup, "Box4")) then
		HSlot = 4;
	elseif (string.find(HGroup, "Box5")) then
		HSlot = 5;
	elseif (string.find(HGroup, "Box6")) then
		HSlot = 6;
	elseif (string.find(HGroup, "Box7")) then
		HSlot = 7;
	elseif (string.find(HGroup, "Box8")) then
		HSlot = 8;
	elseif (string.find(HGroup, "Box9")) then
		HSlot = 9;
	elseif (string.find(HGroup, "Box10")) then
		HSlot = 10;
	elseif (string.find(HGroup, "Box11")) then
		HSlot = 11;
	elseif (string.find(HGroup, "Box12")) then
		HSlot = 12;
	end
	HGS_RemoveHealer(HSlot, HGroupID);
end


function HGS_SetActiveGroup()
	HGSActiveText:SetText(this:GetText());
	HGSData[Instance]["Active"] = this:GetID();
end

function HGS_SetChannel()
	HGSData["Channel"] = this:GetText();
	--HGSCurrChan:SetText("sending to "..HGSData["Channel"]);
	HGSChanText:SetText("Channel: "..HGSData["Channel"]);
end

function HGS_SaveInstance()
	HGSData[Instance]["Name"] = InstanceBox:GetText();
	HGSUpdate();
end

function HGS_SaveComment()
	HGSData[Instance]["Comment"] = CommentBox:GetText();
	HGSUpdate();
end



function HGS_NextInstance()
	if(Instance == HGS_SETS) then
		HGSData["InsLast"] = Instance;
		Instance = 1;
		HGSData["InsCurr"] = Instance;
	else
		HGSData["InsLast"] = Instance;
		Instance = Instance + 1;
		HGSData["InsCurr"] = Instance;
	end
	HGSUpdate();
end


function HGS_PrevInstance()
	if(Instance == 1) then
		HGSData["InsLast"] = Instance;
		Instance = HGS_SETS;
		HGSData["InsCurr"] = Instance;
	else
		HGSData["InsLast"] = Instance;
		Instance = Instance - 1;
		HGSData["InsCurr"] = Instance;
	end
	HGSUpdate();
end

function HGS_SetNewInstanceName()
	local NewName = InstanceBox:GetText();
	HGSInstanceText:SetText(NewName);
	HGSUpdate();
end

function HGS_Autosort()

	local sgroups = {};
	local scounts = {};
	local gcount = 1;
	local gindex = 1;
	local lowgroup = 1;
	local lcount = 1;
	local ccount = 1;
	local cgroup = 1;
	
	for hindex=1,HealerCount,1 do
		gcount=1;
		for group=1,8,1 do
			if ((HGSData[Instance][group]["Name"]) ~= ("Group"..group)) then
			sgroups[gcount] = group;
			scounts[gcount] = HGSData[Instance][group]["Count"];
			--DEFAULT_CHAT_FRAME:AddMessage("gc: g,c ="..gcount..": "..sgroups[gcount]..", "..scounts[gcount], 0.3, 0.6, 0.3);
			gcount = gcount +1;
			end
		end
		lcount = scounts[1];
		for gci=1,gcount-1,1 do
			ccount=scounts[gci];
			cgroup=sgroups[gci];
			--DEFAULT_CHAT_FRAME:AddMessage("gci,lc,cc,lg,gi="..gci..", "..lcount..", "..ccount..", "..lowgroup..", "..gindex, 0.3, 0.6, 0.3);
			if (ccount <= lcount) then 
				lcount = ccount;
				lowgroup = cgroup;
				
			else
				
			end
		end
				
		if(HGSData["Healers"][hindex]["IsChosen"][Instance] == 0) then
			HGSData["Healers"][hindex]["IsChosen"][Instance] = 1;
			HGS_AddHealer(HGSData["Healers"][hindex]["Name"], HGSData["Healers"][hindex]["Class"], lowgroup)
		
			if(gindex == gcount-1) then
				gindex = 1;
			else	
				gindex = gindex + 1;
			end	
		
		end	
	end
end

function HGS_IconPos(ang) 
	local r = 80;
	--HGSMiniMap:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 58 - (r * cos(ang)), (r * sin(ang)) - 58);
	
	HGSMiniMap:SetPoint("TOPLEFT","Minimap","TOPLEFT",54 - (78 * cos(ang)),(78 * sin(ang)) - 58);
end


function HGS_AddHealer(healer, class, groupid)
	HGSData[Instance][groupid]["Count"] = HGSData[Instance][groupid]["Count"] + 1;
	HGSData[Instance][groupid][HGSData[Instance][groupid]["Count"]]["Name"]= healer;
	HGSData[Instance][groupid][HGSData[Instance][groupid]["Count"]]["Class"]= class;
	HGSData[Instance]["Number"] = HGSData[Instance]["Number"] + 1;
	HGSUpdate();
end

function HGS_RemoveHealer(slot, groupid)
	local HCount = HGSData[Instance][groupid]["Count"];

	for index=1,37,1 do
		if(HGSData["Healers"][index]["Name"] == HGSData[Instance][groupid][slot]["Name"]) then
			HGSData["Healers"][index]["IsChosen"][Instance] = 0;
		end
	end

	if(slot == HCount) then
		HGSData[Instance][groupid][HCount]["Name"] = "";
		HGSData[Instance][groupid][HCount]["Class"] = "";
		HGSData[Instance][groupid]["Count"] = HCount - 1;
		HGSData[Instance]["Number"] = HGSData[Instance]["Number"] - 1;
	elseif (slot < HCount) then
		for index=slot,HGSData[Instance][groupid]["Count"] - 1,1 do
			HGSData[Instance][groupid][index]["Name"] = HGSData[Instance][groupid][index + 1]["Name"];
			HGSData[Instance][groupid][index]["Class"] = HGSData[Instance][groupid][index + 1]["Class"];
		end
		HGSData[Instance][groupid][HCount]["Name"] = "";
		HGSData[Instance][groupid][HCount]["Class"] = "";
		HGSData[Instance][groupid]["Count"] = HCount - 1;
		HGSData[Instance]["Number"] = HGSData[Instance]["Number"] - 1;
	end
	HGSUpdate();
end

function HGS_Refresh()
	RaidCount = GetNumRaidMembers();
	local name = "";
	local rank = "";
	local subgroup = "";
	local level = "";
	local class = "";
	local fileName = "";
	local zone = "";
	local online = "";
	local Priests = {};
	local Druids = {};
	local Shaman = {};
	local Paladins = {};
	local Pindex = 1;
	local Dindex = 1;
	local Sindex = 1;	
   local PaladinIndex = 1;		
	

	--DEFAULT_CHAT_FRAME:AddMessage("you are "..UnitFactionGroup('player'), 0.3, 0.6, 0.3)
	
	HGSData["Healers"] = {}; 
	
	for slot=1,37,1 do
		HGSData["Healers"][slot] = {};
		HGSData["Healers"][slot]["Name"] = "";
		HGSData["Healers"][slot]["Class"] = "";
		HGSData["Healers"][slot]["IsChosen"] = {};
		for ins=1,HGS_SETS,1 do
			HGSData["Healers"][slot]["IsChosen"][ins] = 0;
		end
	end
	
	for index=0, 40, 1 do
		name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(index);
		if(class ~= nil) then
			if(string.find(class, HGS_PRIEST)) then
				Priests[Pindex]=name;
				Pindex = Pindex + 1;
			end
			if(string.find(class, HGS_DRUID)) then
				Druids[Dindex]=name;
				Dindex = Dindex + 1;
			end
			if(string.find(class, HGS_PALADIN)) then
				Paladins[PaladinIndex]=name;
				PaladinIndex = PaladinIndex + 1;
			end
			if(string.find(class, HGS_SHAMAN)) then
				Shaman[Sindex]=name;
				Sindex = Sindex + 1;
			end
		end	
	end
			
	HealerCount= (Pindex - 1) + (Dindex - 1) + (Sindex - 1) + (PaladinIndex - 1);
	
	DEFAULT_CHAT_FRAME:AddMessage("Found "..(Pindex-1).." priests, "..(Dindex-1).." druids,  "..(Sindex-1).." shaman, and "..(PaladinIndex-1).." Paladins. ", 0.3, 0.6, 0.3);
	
	Hindex =1;
	for index=1,Pindex - 1,1 do
		HGSData["Healers"][Hindex]["Name"] = Priests[index];
		HGSData["Healers"][Hindex]["Class"] = HGS_PRIEST;
		Hindex = Hindex + 1;
	end
	for index=1,Dindex - 1,1 do
		HGSData["Healers"][Hindex]["Name"] = Druids[index];
		HGSData["Healers"][Hindex]["Class"] = HGS_DRUID;
		Hindex = Hindex + 1;
	end
	for index=1,Sindex - 1,1 do
		HGSData["Healers"][Hindex]["Name"] = Shaman[index];
		HGSData["Healers"][Hindex]["Class"] = HGS_SHAMAN;
		Hindex = Hindex + 1;
	end
	for index=1,PaladinIndex - 1,1 do
		HGSData["Healers"][Hindex]["Name"] = Paladins[index];
		HGSData["Healers"][Hindex]["Class"] = HGS_PALADIN;
		Hindex = Hindex + 1;
	end

	for index=26,33,1 do
		HGSData["Healers"][index]["Class"]="Other";
	end
	
	HGSData["Healers"][25]["Class"]=HGS_PRIEST;
	HGSData["Healers"][34]["Class"]=HGS_PRIEST;
	HGSData["Healers"][35]["Class"]=HGS_DRUID;
	HGSData["Healers"][36]["Class"]=HGS_SHAMAN;
   HGSData["Healers"][37]["Class"]=HGS_PALADIN;

	HGSData["Healers"][25]["Name"]="Everyone Else";
	HGSData["Healers"][26]["Name"]="Group1";
	HGSData["Healers"][27]["Name"]="Group2";
	HGSData["Healers"][28]["Name"]="Group3";
	HGSData["Healers"][29]["Name"]="Group4";
	HGSData["Healers"][30]["Name"]="Group5";
	HGSData["Healers"][31]["Name"]="Group6";
	HGSData["Healers"][32]["Name"]="Group7";
	HGSData["Healers"][33]["Name"]="Group8";
	HGSData["Healers"][34]["Name"]="Priests";
	HGSData["Healers"][35]["Name"]="Druids";
	HGSData["Healers"][36]["Name"]="Shamans";
	HGSData["Healers"][37]["Name"]="Paladins";
		
	hflag = 0;
	for ins=1,HGS_SETS,1 do
		for groupid=1,8,1 do
			for slot=1,12,1 do
				for index=1,37,1 do
					if(HGSData[ins][groupid][slot]["Name"] == HGSData["Healers"][index]["Name"]) then
						HGSData["Healers"][index]["IsChosen"][ins] = 1;
						hflag = 1;
					end
				end
				if (hflag == 0) then
					HGSData[ins][groupid][slot]["Class"] = "Other";
				else	
					hflag = 0;
				end
			end
		end
	end
		
	HGSUpdate();
end

function HGS_PlayerBCast(plr)
local BCast = {};
local Gindex = 1;
local Found = 0;
local Lang = DEFAULT_CHAT_FRAME.editBox.language;
	BCast[Gindex] = HGSData[Instance]["Name"];
	Gindex = Gindex + 1;
	
	for index=1,8,1 do
		if (HGSData[Instance][index]["Count"] > 0) then
			for slot=1,HGSData[Instance][index]["Count"],1 do
				if (HGSData[Instance][index][slot]["Name"] == plr) then
					Found = 1;
					BCast[Gindex] = HGSData[Instance][index]["Name"].." - ";
					for wslot=1,HGSData[Instance][index]["Count"] - 1,1 do
						BCast[Gindex] = BCast[Gindex]..HGSData[Instance][index][wslot]["Name"]..", ";
					end
					BCast[Gindex] = BCast[Gindex]..HGSData[Instance][index][HGSData[Instance][index]["Count"]]["Name"];
					Gindex = Gindex + 1;
				end
			end
		end
	end
if (Found == 1) then
	for index=1,Gindex - 1,1 do
		SendChatMessage(BCast[index], "WHISPER", Lang, plr);
	end
elseif (Found == 0) then
	--SendChatMessage("You aren't in a group", "WHISPER", Lang, plr);
		end
end

function HGS_Broadcast()
	local BCast = {};
	local Gindex = 1;
	local Channel = 0;
	local Lang = DEFAULT_CHAT_FRAME.editBox.language;

	BCast[Gindex] = HGSData[Instance]["Name"];
	Gindex = Gindex + 1;

	for index=1,8,1 do
		if (HGSData[Instance][index]["Count"] > 0) then
			BCast[Gindex] = HGSData[Instance][index]["Name"].." - ";
			for slot=1,HGSData[Instance][index]["Count"] - 1,1 do
				BCast[Gindex] = BCast[Gindex]..HGSData[Instance][index][slot]["Name"]..", ";
			end
			BCast[Gindex] = BCast[Gindex]..HGSData[Instance][index][HGSData[Instance][index]["Count"]]["Name"];
			Gindex = Gindex + 1;
		end
	end

	BCast[Gindex] = HGSData[Instance]["Comment"];
	
	for index=1,Gindex,1 do
		if(HGSData["Channel"] == "Say" or HGSData["Channel"] == "say") then
			SendChatMessage(BCast[index], "SAY", Lang);
		elseif(HGSData["Channel"] == "Party" or HGSData["Channel"] == "party") then
			SendChatMessage(BCast[index], "PARTY", Lang);
		elseif(HGSData["Channel"] == "Raid" or HGSData["Channel"] == "raid") then
			SendChatMessage(BCast[index], "RAID", Lang);
		elseif(HGSData["Channel"] == "Yell" or HGSData["Channel"] == "yell") then
			SendChatMessage(BCast[index], "YELL", Lang);
		else
			Channel = GetChannelName(HGSData["Channel"]);
			SendChatMessage(BCast[index], "CHANNEL", Lang, Channel);
		end
	end
end

function HGS_Reset()
	HGSData[Instance]["Active"] = 1;
	HGSData[Instance]["Number"] = 0;
	for group=1,8,1 do
		HGSData[Instance][group]["Count"] = 0;
			for slot=1,12,1 do
				HGSData[Instance][group][slot] = {};
				HGSData[Instance][group][slot]["Name"] = "";
				HGSData[Instance][group][slot]["Class"] = "";
			end
	end
	for slot=1,37,1 do
		HGSData["Healers"][slot]["IsChosen"][Instance] = 0;
	end
	HGSUpdate();
end

function HGS_FullReset()
	Instance = 1;
	HealerCount = 0;
	
	HGSData = {};
	HGSData["InsCurr"] = 1;
	HGSData["InsLast"] = 1;
	HGSData["IconPos"] = 40;
	HGSData["Channel"] = "Raid";


	HGSData["Healers"] = {} 

	for slot=1,37,1 do
		HGSData["Healers"][slot] = {};
		HGSData["Healers"][slot]["Name"] = "";
		HGSData["Healers"][slot]["Class"] = "";
		HGSData["Healers"][slot]["IsChosen"] = {};
		for ins=1,HGS_SETS,1 do
			HGSData["Healers"][slot]["IsChosen"][ins] = 0;
		end
	end

	for ins=1,HGS_SETS,1 do
		HGSData[ins] = {};
		HGSData[ins]["Name"] = "Set "..ins;
		HGSData[ins]["Active"] = 1;
		HGSData[ins]["Number"] = 0;
		HGSData[ins]["Comment"] = "";
		for group=1,8,1 do
			HGSData[ins][group] = {};
			HGSData[ins][group]["Name"] = "Group"..group;
			HGSData[ins][group]["Count"] = 0;
			for slot=1,12,1 do
				HGSData[ins][group][slot] = {};
				HGSData[ins][group][slot]["Name"] = "";
				HGSData[ins][group][slot]["Class"] = "";
			end
		end
	end

	HGSGroup1Box:SetText("");
	HGSGroup2Box:SetText("");
	HGSGroup3Box:SetText("");
	HGSGroup4Box:SetText("");
	HGSGroup5Box:SetText("");
	HGSGroup6Box:SetText("");
	HGSGroup7Box:SetText("");
	HGSGroup8Box:SetText("");
 
	for index=26,33,1 do
		HGSData["Healers"][index]["Class"]="Other";
	end
	
	HGSData["Healers"][25]["Class"]=HGS_PRIEST;
	HGSData["Healers"][34]["Class"]=HGS_PRIEST;
	HGSData["Healers"][35]["Class"]=HGS_DRUID;
	HGSData["Healers"][36]["Class"]=HGS_SHAMAN;
	HGSData["Healers"][37]["Class"]=HGS_PALADIN;

	HGSData["Healers"][25]["Name"]="Everyone Else";
	HGSData["Healers"][26]["Name"]="Group1";
	HGSData["Healers"][27]["Name"]="Group2";
	HGSData["Healers"][28]["Name"]="Group3";
	HGSData["Healers"][29]["Name"]="Group4";
	HGSData["Healers"][30]["Name"]="Group5";
	HGSData["Healers"][31]["Name"]="Group6";
	HGSData["Healers"][32]["Name"]="Group7";
	HGSData["Healers"][33]["Name"]="Group8";
	HGSData["Healers"][34]["Name"]="Priests";
	HGSData["Healers"][35]["Name"]="Druids";
	HGSData["Healers"][36]["Name"]="Shamans";
	HGSData["Healers"][37]["Name"]="Paladins";
			
	for ins=1,HGS_SETS,1 do
		for groupid=1,8,1 do
			for slot=1,12,1 do
				for index=1,37,1 do
					if(HGSData[ins][groupid][slot]["Name"] == HGSData["Healers"][index]["Name"]) then
						HGSData["Healers"][index]["IsChosen"][ins] = 1;
					end
				end
			end
		end
	end
	HGSUpdate();
end

function HGS_Init()
	Instance = HGSData["InsCurr"]
	
	HealerCount = 0;
	if (HGSData == nil) then
		HGSData = {};
		HGSData["InsCurr"] = 1;
		HGSData["InsLast"] = 1;
		HGSData["IconPos"] = 0;
		HGSData["Channel"] = "Raid";
	end
	
	if (HGSData["IconPos"] == nil) then
		HGSData["IconPos"] = 20;
	end
		
	if (HGSData["Healers"] == nil) then
		HGSData["Healers"] = {}; 
	end
	
	for index=1,37,1 do
		if(HGSData["Healers"][index] == nil) then
			HGSData["Healers"][index] = {};
		end
	end
		
	
	for index=26,33,1 do
		HGSData["Healers"][index]["Class"]="Other";
	end
	
	HGSData["Healers"][25]["Class"]=HGS_PRIEST;
	HGSData["Healers"][34]["Class"]=HGS_PRIEST;
	HGSData["Healers"][35]["Class"]=HGS_DRUID;
	HGSData["Healers"][36]["Class"]=HGS_SHAMAN;
	HGSData["Healers"][37]["Class"]=HGS_PALADIN;

	HGSData["Healers"][25]["Name"]="Everyone Else";
	HGSData["Healers"][26]["Name"]="Group1";
	HGSData["Healers"][27]["Name"]="Group2";
	HGSData["Healers"][28]["Name"]="Group3";
	HGSData["Healers"][29]["Name"]="Group4";
	HGSData["Healers"][30]["Name"]="Group5";
	HGSData["Healers"][31]["Name"]="Group6";
	HGSData["Healers"][32]["Name"]="Group7";
	HGSData["Healers"][33]["Name"]="Group8";
	HGSData["Healers"][34]["Name"]="Priests";
	HGSData["Healers"][35]["Name"]="Druids";
	HGSData["Healers"][36]["Name"]="Shamans";
	HGSData["Healers"][37]["Name"]="Paladins";
	
	HealerCount=0;
	if(HGSData["Healers"] == nil) then
		HGSData["Healers"] = {};
		for slot=1,24,1 do
			HGSData["Healers"][slot] = {};
			HGSData["Healers"][slot]["Class"]="";
			if(HGSData["Healers"][slot]["Name"] ~= "") then
				HealerCount = HealerCount + 1;
			end
			if(HGSData["Healers"][slot]["IsChosen"] == nil) then
				HGSData["Healers"][slot]["IsChosen"] = {};
				for ins=1,HGS_SETS,1 do
					HGSData["Healers"][slot]["IsChosen"][ins] = 0;
				end
			end
		end
	end
	
	for ins=1,HGS_SETS,1 do
		if (HGSData[ins] == nil) then
			HGSData[ins] = {};
			HGSData[ins]["Name"] = "Set "..ins;
			HGSData[ins]["Active"] = 1;
			HGSData[ins]["Number"] = 0;
			HGSData[ins]["Comment"] = "";
			for group=1,8,1 do
				if(HGSData[ins][group] == nil) then
					HGSData[ins][group] = {};
					HGSData[ins][group]["Name"] = "Group"..group;
					HGSData[ins][group]["Count"] = 0;
				end
				for slot=1,12,1 do
					HGSData[ins][group][slot] = {};
					HGSData[ins][group][slot]["Name"] = "";
					HGSData[ins][group][slot]["Class"] = "";
				end
			end
		end
	end
end