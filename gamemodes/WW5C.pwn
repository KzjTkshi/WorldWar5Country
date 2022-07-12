// INCLUDE
#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <YSI\y_ini>
#include <ZCMD>

#include "modules\defines.pwn"

#define DATABASE_ADDRESS "localhost" //Change this to your Database Address
#define DATABASE_USERNAME "root" // Change this to your database username
#define DATABASE_PASSWORD "" //Change this to your database password
#define DATABASE_NAME "gmtest"

#define WW5C::%0(%1) forward %0(%1); public %0(%1)

//Paths
#define BIRU 0x003DF5AA
enum pInfo
{
	pID,
	pName[MAX_PLAYER_NAME],
	bool:pSpawn,
	pMoney,
	pAdmin,
}
new PlayerInfo[MAX_PLAYERS][pInfo];

stock ClearChat()
{
	for(new a = 0; a < 135; a++) SendClientMessageToAll(-1, " ");
	return 1;
}
// Pickup Tas
new BF1;
new BF2;
new BF3;
new BF4;
new BF5;
new BF6;
new BF7;

//variables
new MySQL:sqlcon;
new tCP[30];
new UnderAttack[30];
new Captured[30];
new CP[30];
new Zone[30];
new timer[MAX_PLAYERS][30];
new CountVar[MAX_PLAYERS] = 25;
new InCP[MAX_PLAYERS];
new CountTime[MAX_PLAYERS];

new FirstSpawn[MAX_PLAYERS];

#pragma tabsize 0


main()
{
	print("\n----------------------------------");
	print(" World War 5 Country ");
	print("----------------------------------\n");
}

//colors

#define COLOR_GREEN 0x008000FF
#define COLOR_BLUE 0x0000FFFF
#define COLOR_BRIGHTRED 0xFF000AAA
#define COLOR_AQUA 0x00FFFFAA
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_BEIGE 0xFFF8DCAA
#define COLOR_BLACK 0x000000AA
#define COLOR_LIGHTERBLUE 0x00BFFFAA
#define COLOR_BLUELIGHT 0x1E90FFAA
#define COLOR_BLUEMEDIUM 0x0000CDAA
#define COLOR_BLUEDARK 0x00008BAA
#define COLOR_PINK 0xFF1493AA
#define COLOR_PINKDARK 0xFF00FFAA
#define COLOR_GREENLIGHT 0x00FF00AA
#define COLOR_GREENDARK 0x006400AA
#define COLOR_MAROON 0x800000AA
#define COLOR_OKER 0x808000AA
#define COLOR_ORANGE 0xFF4500AA
#define COLOR_ORANGELIGHT 0xFF8C00AA
#define COLOR_PURPLE 0x800080AA
#define COLOR_VIOLETDARK 0x9400D3AA
#define COLOR_INDIGO 0xAB0082AA
#define COLOR_RED 0xFF0000AA
#define COLOR_SAND 0xFFDEADAA
#define COLOR_SILVER 0xC0C0C0AA
#define COLOR_TEAL 0x008080AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_GOLD 0xFFD700AA
#define COLOR_BROWN 0x8B4513AA
#define COLOR_BROWNLIGHT 0xA0522DAA
#define COLOR_GRAY 0xA9A9A9AA
#define COLOR_GRAYDARK 0x696969AA
#define C_GANG_GREEN 0x15FF0077
#define COLOR_PURPLES 0xA86EFC77

// spawn coordinates
new Float:Rebals[][] =
{
   {-367.1493,2205.4155,42.4844,245.1246},
   {-379.1219,2240.8486,42.4695,89.7823},
   {-392.1632,2246.2773,42.4162,60.3521}

};

new Float:ArabSpawn[][] =
{
   {-796.8353,1559.8621,27.1244,88.3696},
   {-729.4165,1558.1375,41.1295,351.5721},
   {-772.0912,1615.7186,27.1244,358.4655}
};
new Float:MercSpawn[][] =
{
   {-148.6964,1111.9276,19.7500,270.2336},
   {203.1372,1872.8495,13.1406,263.0270},
   {-392.1632,2246.2773,42.4162,60.3521}
};
new Float:RusSpawn[][] =
{
   {-148.6964,1111.9276,19.7500,270.2336},
   {-89.2924,1163.3394,19.7422,183.4396},
   {-204.2620,1081.1177,19.7422,270.8604}
};

new Float:EuroSpawn[][] =
{
   {-252.7739,2603.1516,62.8582,263.5070},
   {-200.1243,2665.6450,62.7293,275.1005},
   {-276.1315,2718.0430,62.6376,352.9625}
};

new Float:UsaSpawn[][] =
{
   {203.1372,1872.8495,13.1406,263.0270},
   {230.5600,1937.8513,30.0547,12.6714},
   {245.1640,1839.8844,23.2422,342.5678}
};
new Float:AsiaSpawn[][] =
{
   {-1477.8877,2618.1267,58.7813,87.5035},
   {-1401.9437,2649.2827,55.6875,260.1520},
   {-1515.2573,2522.1611,55.8376,9.5062}
};


new RandomMessages[][] = {

  " Random Messages here"
  };

// Teams

#define TEAM_USA 0
#define TEAM_RUSS 1
#define TEAM_ARAB 2
#define TEAM_EURO 3
#define TEAM_REBELS 4
#define TEAM_ASIA 5
#define TEAM_LATINO 6
#define TEAM_NONE 7


// Classes

#define ASSAULT 1
#define SNIPER 2
#define MEDIC 3

//dialogs
#define DIALOG_HELP 789
#define DIALOG_CMDS 790
#define DIALOG_RANKS 791


// team bases zones
new USA_BASE;
new RUSS_BASE;
new ARAB_BASE;
new EURO_BASE;
new REBELS_BASE;
new ASIAN_BASE;


// capzones definitions
#define Zone1 0
#define Zone2 1
#define Zone3 2
#define Zone4 3
#define Zone5 4
#define Zone6 5
#define Zone7 6
#define Zone8 7
#define Zone9 8


// teams,classes definitions
new gTeam[MAX_PLAYERS];
new gPlayerClass[MAX_PLAYERS];
new PickedClass[MAX_PLAYERS];

public OnGameModeInit()
{
    UsePlayerPedAnims();
    DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
	SetGameModeText("WORLD WAR 5");
	SetTimer("RandomMessage", 120000, 1);
	SendRconCommand("hostname World War 5 Country");
    AddPlayerClass(287,203.1372,1872.8495,13.1406,263.0270,0,0,0,0,0,0); // USA SPAWN 1
    AddPlayerClass(285,-148.6964,1111.9276,19.7500,270.2336,0,0,0,0,0,0); // RUSSUA SPAWN 1
    AddPlayerClass(179,-796.8353,1559.8621,27.1244,88.3696,0,0,0,0,0,0); // Arabz
    AddPlayerClass(165,-252.7739,2603.1516,62.8582,263.5070,0,0,0,0,0,0); // Euro SPAWN 1
    AddPlayerClass(100,-382.1090,2208.1689,42.3969,284.9675,0,0,0,0,0,0); // REBELS spawn
    AddPlayerClass(122,-1477.8877,2618.1267,58.7813,87.5035,0,0,0,0,0,0); // spawn asia
    
    USA_BASE = GangZoneCreate(-54,1668,426,2136); //a51
    RUSS_BASE = GangZoneCreate(-378,960,144,1248); // Middle Desert Town
    ARAB_BASE = GangZoneCreate(-930,1392,-648,1674); //arab
    EURO_BASE = GangZoneCreate(-378,2556,-78,2814); // Northern Village
    ASIAN_BASE = GangZoneCreate(-1662,2460,-1350,2736); // Korean Town
    REBELS_BASE = GangZoneCreate(-516,2112,-288,2298); // Ghosts Town
    
    

	CreateVehicle(522,-231.3270870,2671.1950680,62.3588790,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-232.8657070,2671.2932130,62.3588790,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-234.4156340,2671.2922360,62.3588790,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-236.2406160,2671.2932130,62.3588790,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-237.9906160,2671.2932130,62.3588790,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-239.7158050,2671.2185060,62.3588790,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-177.4187620,1154.8553470,19.5103650,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-176.1042940,1154.9934080,19.5103650,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-174.6547700,1155.0881350,19.5103650,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-173.1548920,1155.0388180,19.5103650,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-171.7546230,1155.1634520,19.5103650,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-170.4796910,1155.1877440,19.5103650,0.0000000,-1,-1,40); //NRG-500
	CreateVehicle(522,-169.2546230,1155.1889650,19.5103650,0.0000000,-1,-1,40); //NRG-500


	CreateVehicle(507,-169.7802000,1193.7305000,19.4832000,272.1584000,53,53,40); //Elegant
	CreateVehicle(507,-151.3201000,1193.4274000,19.4921000,270.2192000,53,53,40); //Elegant
	CreateVehicle(432,-132.8332000,1214.5040000,19.7549000,359.7852000,-1,-1,40); //Rhino
	CreateVehicle(432,-143.8001000,1213.6923000,19.7513000,1.2314000,-1,-1,40); //Rhino
	CreateVehicle(432,-163.7118000,1227.4756000,19.7552000,92.3068000,-1,-1,40); //Rhino
	CreateVehicle(432,-162.9769000,1215.4075000,19.7552000,92.4037000,-1,-1,40); //Rhino
	CreateVehicle(432,-148.0277000,1183.0833000,19.7562000,269.6900000,-1,-1,40); //Rhino
	CreateVehicle(432,-80.7883000,1053.4082000,19.7529000,90.7146000,-1,-1,40); //Rhino
	CreateVehicle(432,-80.8473000,1045.3708000,19.7413000,91.6475000,-1,-1,40); //Rhino
	CreateVehicle(432,-243.6082000,1081.1266000,19.7272000,178.3251000,-1,-1,40); //Rhino
	CreateVehicle(432,-259.8210000,1218.5247000,19.7549000,358.7866000,-1,-1,40); //Rhino
	CreateVehicle(432,-250.5950000,1216.1040000,19.7551000,2.0934000,-1,-1,40); //Rhino
	CreateVehicle(432,-236.8259000,1214.0068000,19.7550000,1.2626000,-1,-1,40); //Rhino
	CreateVehicle(433,-228.7815000,1217.0042000,20.1753000,181.5212000,-1,-1,40); //Barracks
	CreateVehicle(433,-218.9273000,1216.7688000,20.1735000,178.4961000,-1,-1,40); //Barracks
	CreateVehicle(433,-197.2750000,1214.2571000,20.1787000,182.0692000,-1,-1,40); //Barracks
	CreateVehicle(433,-200.4926000,1171.9255000,20.1027000,179.7394000,-1,-1,40); //Barracks
	CreateVehicle(433,-153.7065000,1084.7604000,20.1406000,266.1849000,-1,-1,40); //Barracks
	CreateVehicle(470,-158.6108000,1167.2167000,19.7354000,178.3675000,-1,-1,40); //Patriot
	CreateVehicle(470,-145.2791000,1153.0159000,19.6592000,272.3667000,-1,-1,40); //Patriot
	CreateVehicle(470,-82.8678000,1158.0170000,19.7345000,271.8048000,-1,-1,40); //Patriot
	CreateVehicle(470,-32.2315000,1184.7002000,19.3484000,359.4193000,-1,-1,40); //Patriot
	CreateVehicle(470,-10.5601000,1220.7673000,19.3413000,4.1551000,-1,-1,40); //Patriot
	CreateVehicle(470,-2.0027000,1221.7136000,19.3442000,1.9967000,-1,-1,40); //Patriot
	CreateVehicle(470,5.4184000,1218.5588000,19.3461000,357.7910000,-1,-1,40); //Patriot
	CreateVehicle(470,-80.4464000,1222.3505000,19.7347000,91.6395000,-1,-1,40); //Patriot

	CreateVehicle(402,-305.8307000,1114.7781000,19.5790000,358.0663000,-1,-1,40); //Buffalo
	CreateVehicle(402,-304.1901000,1028.3877000,19.4255000,92.2054000,-1,-1,40); //Buffalo
	CreateVehicle(402,-304.0491000,1023.7325000,19.4255000,90.1839000,-1,-1,40); //Buffalo
	CreateVehicle(402,-304.7504000,1007.6920000,19.4253000,90.9390000,-1,-1,40); //Buffalo
	CreateVehicle(402,-173.3682000,1018.7441000,19.5736000,271.4858000,-1,-1,40); //Buffalo
	CreateVehicle(402,-172.7404000,1013.4344000,19.5738000,269.0490000,-1,-1,40); //Buffalo
	CreateVehicle(402,-77.2107000,1076.8668000,19.5736000,179.3166000,-1,-1,40); //Buffalo
	CreateVehicle(402,-23.2576000,1143.3752000,19.4968000,271.0952000,-1,-1,40); //Buffalo
	CreateVehicle(402,-70.9021000,1185.6937000,19.4937000,4.7178000,-1,-1,40); //Buffalo
	CreateVehicle(548,-131.3202000,993.5706000,22.3230000,273.4375000,-1,-1,40); //Cargobob
	CreateVehicle(520,-132.2480000,1025.1906000,21.3739000,272.3754000,-1,-1,40); //Hydra
	CreateVehicle(425,-169.5678000,988.2139000,21.2705000,89.2718000,-1,-1,40); //Hunter
	CreateVehicle(487,-93.1889000,1027.0336000,19.8679000,260.7979000,-1,-1,40); //Maverick
	CreateVehicle(487,-126.4990000,1050.4193000,20.8552000,87.3708000,-1,-1,40); //Maverick
	CreateVehicle(470,-91.7931000,1157.5265000,19.7338000,273.4672000,-1,-1,40); //Patriot
	CreateVehicle(471,-120.0205000,1141.9608000,19.1744000,173.4989000,-1,-1,40); //Quad
	CreateVehicle(471,-122.9541000,1142.5817000,19.2001000,186.2512000,-1,-1,40); //Quad
	CreateVehicle(471,-126.2311000,1141.1714000,19.2241000,180.4574000,-1,-1,40); //Quad
	CreateVehicle(471,-130.1885000,1141.0081000,19.2220000,178.7012000,-1,-1,40); //Quad
	CreateVehicle(468,-112.3525000,1120.9099000,19.4105000,72.9971000,-1,-1,40); //Sanchez
	CreateVehicle(468,-112.5510000,1117.9872000,19.4110000,81.6557000,-1,-1,40); //Sanchez
	CreateVehicle(468,-112.5225000,1116.2460000,19.4116000,58.3526000,-1,-1,40); //Sanchez
	CreateVehicle(468,-112.6650000,1114.5563000,19.4107000,73.8427000,-1,-1,40); //Sanchez
	CreateVehicle(487,-226.0801000,2716.0386000,67.1165000,268.1381000,54,29,40); //Maverick
	CreateVehicle(487,-344.9044000,2676.9741000,63.8829000,23.0436000,54,29,40); //Maverick
	CreateVehicle(487,-563.5708000,2601.9707000,66.0528000,272.8370000,54,29,40); //Maverick
	CreateVehicle(487,-417.3027000,2191.2710000,42.6609000,9.3595000,54,29,40); //Maverick
	CreateVehicle(487,333.7563000,1961.2158000,17.8156000,95.5012000,54,29,40); //Maverick
	CreateVehicle(487,334.1656000,1924.0676000,17.8218000,79.1497000,54,29,40); //Maverick
	CreateVehicle(487,332.2151000,1867.0376000,17.9470000,89.0947000,54,29,40); //Maverick
	CreateVehicle(522,292.3523000,1878.6427000,17.2000000,56.2868000,-1,-1,40); //NRG-500
	CreateVehicle(522,292.3821000,1883.3024000,17.2067000,52.2745000,-1,-1,40); //NRG-500
	CreateVehicle(578,-1507.3623000,1982.4646000,48.8080000,0.6026000,-1,-1,40); //DFT-30
	CreateVehicle(511,-1484.9375000,1976.6157000,49.1932000,1.9646000,-1,-1,40); //Beagle
	CreateVehicle(578,-296.5619000,2612.9839000,63.9745000,261.1927000,-1,-1,40); //DFT-30


	AddStaticVehicleEx(432,-214.8000000,2732.6999500,62.8000000,0.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(432,-222.3000000,2732.6999500,62.8000000,0.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(432,-229.8000000,2732.3999000,62.8000000,0.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(425,-307.3999900,2679.1001000,66.4000000,0.0000000,95,10,40); //Hunter
	AddStaticVehicleEx(520,-213.0000000,2661.0000000,66.4000000,0.0000000,-1,-1,40); //Hydra
	AddStaticVehicleEx(427,-237.1000100,2596.8000500,63.0000000,0.0000000,-1,-1,40); //Enforcer
	AddStaticVehicleEx(402,-231.8000000,2595.8000500,62.6000000,0.0000000,109,122,40); //Buffalo
	AddStaticVehicleEx(427,-204.6000100,2597.0000000,63.0000000,0.0000000,-1,-1,40); //Enforcer
	AddStaticVehicleEx(415,-219.7000000,2595.8999000,62.6000000,0.0000000,63,62,40); //Cheetah
	AddStaticVehicleEx(415,-210.7000000,2595.6999500,62.6000000,0.0000000,63,62,40); //Cheetah
	AddStaticVehicleEx(447,-249.8000000,2586.0000000,65.0000000,0.0000000,32,32,40); //Seasparrow
	AddStaticVehicleEx(487,-203.6000100,2734.3000500,63.0000000,0.0000000,165,169,40); //Maverick
	AddStaticVehicleEx(487,-287.8999900,2618.6001000,63.4000000,0.0000000,165,169,40); //Maverick
	AddStaticVehicleEx(560,-175.3999900,2708.6001000,62.4000000,0.0000000,45,58,40); //Sultan
	AddStaticVehicleEx(560,-200.8000000,2716.1001000,62.5000000,0.0000000,45,58,40); //Sultan
	AddStaticVehicleEx(490,-284.2999900,2606.8999000,63.2000000,0.0000000,-1,-1,40); //FBI Rancher
	AddStaticVehicleEx(432,-271.0000000,2674.8000500,62.7000000,270.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(425,-751.0999800,1637.3000500,28.0000000,0.0000000,95,10,40); //Hunter
	AddStaticVehicleEx(520,-786.2000100,1437.1999500,14.7000000,90.0000000,-1,-1,40); //Hydra
	AddStaticVehicleEx(520,-814.5999800,1436.0000000,14.7000000,90.0000000,-1,-1,40); //Hydra
	AddStaticVehicleEx(432,-776.7000100,1557.3000500,27.2000000,270.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(487,-797.2999900,1596.5000000,30.0000000,0.0000000,151,149,40); //Maverick
	AddStaticVehicleEx(487,-822.2000100,1558.0999800,30.9000000,0.0000000,151,149,40); //Maverick
	AddStaticVehicleEx(447,-810.0000000,1477.3000500,26.1000000,0.0000000,32,32,40); //Seasparrow
	AddStaticVehicleEx(522,-783.0000000,1517.0999800,26.7000000,0.0000000,37,37,40); //NRG-500
	AddStaticVehicleEx(470,-745.2000100,1577.8000500,27.1000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-745.0999800,1569.3000500,27.1000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-744.2999900,1562.5000000,27.1000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-865.7000100,1544.5999800,23.1000000,90.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-865.7000100,1554.3000500,23.9000000,90.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-865.7999900,1563.1999500,24.6000000,90.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(601,-791.4000200,1567.8000500,27.0000000,0.0000000,245,245,40); //S.W.A.T. Van
	AddStaticVehicleEx(522,-794.2999900,1547.4000200,26.8000000,0.0000000,76,117,40); //NRG-500
	AddStaticVehicleEx(522,-785.9000200,1547.5999800,26.8000000,0.0000000,215,142,40); //NRG-500
	AddStaticVehicleEx(522,-788.2000100,1547.4000200,26.8000000,0.0000000,132,4,40); //NRG-500
	AddStaticVehicleEx(522,-792.5000000,1548.1999500,26.8000000,0.0000000,37,37,40); //NRG-500
	AddStaticVehicleEx(522,-729.2999900,1517.8000500,38.4000000,0.0000000,132,4,40); //NRG-500
	AddStaticVehicleEx(521,-820.5999800,1543.6999500,26.8000000,0.0000000,115,10,40); //FCR-900
	AddStaticVehicleEx(560,-797.7000100,1630.5999800,26.9000000,0.0000000,111,103,40); //Sultan
	AddStaticVehicleEx(487,217.0000000,1929.5999800,23.5000000,0.0000000,165,169,40); //Maverick
	AddStaticVehicleEx(520,308.1000100,2047.5999800,18.6000000,180.0000000,-1,-1,40); //Hydra
	AddStaticVehicleEx(432,280.1000100,2019.0999800,17.7000000,270.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(432,280.3999900,2028.0000000,17.7000000,270.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(425,367.8999900,1982.9000200,21.8000000,0.0000000,95,10,40); //Hunter
	AddStaticVehicleEx(522,213.7000000,1860.1999500,12.8000000,0.0000000,37,37,40); //NRG-500
	AddStaticVehicleEx(522,215.8000000,1860.1999500,12.8000000,0.0000000,215,142,40); //NRG-500
	AddStaticVehicleEx(522,218.2000000,1858.6999500,12.8000000,0.0000000,189,190,40); //NRG-500
	AddStaticVehicleEx(522,220.8000000,1859.1999500,12.8000000,0.0000000,37,37,40); //NRG-500
	AddStaticVehicleEx(522,211.8000000,1860.0999800,12.8000000,0.0000000,215,142,40); //NRG-500
	AddStaticVehicleEx(470,201.7000000,1888.3000500,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,226.3000000,1886.4000200,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,254.5000000,1835.0999800,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,219.7000000,1915.1999500,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,210.8999900,1914.9000200,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,202.1000100,1916.0000000,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(522,186.7000000,1928.5000000,17.4000000,0.0000000,189,190,40); //NRG-500
	AddStaticVehicleEx(470,277.8999900,1983.3000500,17.8000000,270.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,279.2000100,1992.0999800,17.8000000,270.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,308.2999900,1929.1999500,17.8000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(476,279.1000100,1955.6999500,18.8000000,270.0000000,167,162,40); //Rustler
	AddStaticVehicleEx(497,-423.6000100,2206.8999000,42.7000000,0.0000000,-1,-1,40); //Police Maverick
	AddStaticVehicleEx(461,-371.2000100,2229.1001000,42.2000000,90.0000000,14,49,40); //PCJ-600
	AddStaticVehicleEx(461,-371.3999900,2226.8999000,42.2000000,90.0000000,14,49,40); //PCJ-600
	AddStaticVehicleEx(461,-370.6000100,2224.8999000,42.2000000,90.0000000,14,49,40); //PCJ-600
	AddStaticVehicleEx(461,-370.6000100,2223.1001000,42.2000000,90.0000000,14,49,40); //PCJ-600
	AddStaticVehicleEx(461,-370.2999900,2221.5000000,42.2000000,90.0000000,14,49,40); //PCJ-600
	AddStaticVehicleEx(461,-369.6000100,2219.3000500,42.2000000,90.0000000,14,49,40); //PCJ-600
	AddStaticVehicleEx(535,-393.7000100,2193.1001000,42.3000000,0.0000000,61,74,40); //Slamvan
	AddStaticVehicleEx(535,-389.2000100,2193.6001000,42.3000000,0.0000000,61,74,40); //Slamvan
	AddStaticVehicleEx(535,-386.6000100,2193.6999500,42.3000000,0.0000000,61,74,40); //Slamvan
	AddStaticVehicleEx(470,-395.6000100,2238.1999500,42.5000000,290.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-394.6000100,2234.0000000,42.5000000,289.9950000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-391.5000000,2221.6999500,42.5000000,289.9950000,95,10,40); //Patriot
	AddStaticVehicleEx(497,-348.7000100,2211.3999000,42.7000000,0.0000000,-1,-1,40); //Police Maverick
	AddStaticVehicleEx(432,-1525.5999800,2531.6001000,55.8000000,0.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(432,-1505.8000500,2530.0000000,55.8000000,0.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(470,-1534.0999800,2627.8000500,55.9000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-1529.3000500,2629.1001000,55.9000000,0.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-1534.6999500,2648.5000000,55.9000000,190.0000000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-1529.8000500,2642.3000500,55.9000000,189.9980000,95,10,40); //Patriot
	AddStaticVehicleEx(470,-1523.8000500,2642.8999000,55.9000000,189.9980000,95,10,40); //Patriot
	AddStaticVehicleEx(489,-1401.9000200,2630.8000500,56.1000000,90.0000000,214,218,40); //Rancher
	AddStaticVehicleEx(489,-1402.5000000,2641.0000000,56.0000000,90.0000000,214,218,40); //Rancher
	AddStaticVehicleEx(489,-1402.3000500,2653.5000000,56.0000000,90.0000000,214,218,40); //Rancher
	AddStaticVehicleEx(489,-1437.8000500,2650.8000500,56.2000000,90.0000000,214,218,40); //Rancher
	AddStaticVehicleEx(487,-1530.1999500,2584.3000500,60.9000000,0.0000000,165,169,40); //Maverick
	AddStaticVehicleEx(487,-1511.9000200,2585.8000500,61.3000000,0.0000000,165,169,40); //Maverick
	AddStaticVehicleEx(447,-1520.5000000,2619.6001000,59.8000000,0.0000000,32,32,40); //Seasparrow
	AddStaticVehicleEx(411,-1451.5000000,2656.3999000,55.6000000,0.0000000,32,32,40); //Infernus
	AddStaticVehicleEx(411,-1455.4000200,2657.0000000,55.6000000,0.0000000,32,32,40); //Infernus
	AddStaticVehicleEx(516,-1500.4000200,2527.8000500,55.6000000,0.0000000,94,112,40); //Nebula
	AddStaticVehicleEx(432,-1514.9000200,2531.6001000,55.8000000,0.0000000,95,10,40); //Rhino
	AddStaticVehicleEx(520,-1449.9000200,2508.5000000,61.6000000,0.0000000,-1,-1,40); //Hydra
	AddStaticVehicleEx(425,-1449.9000200,2541.6001000,59.6000000,0.0000000,95,10,40); //Hunter
	CreateObject(3279,-160.0000000,2615.8999000,60.7000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (1)
	CreateObject(3279,-153.6000100,2654.8000500,63.6000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (2)
	CreateObject(3279,-364.0000000,2703.8999000,62.8000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (3)
	CreateObject(3279,-223.8000000,2691.8999000,61.7000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (4)
	CreateObject(9241,-214.2000000,2661.3000500,63.7000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (1)
	CreateObject(9241,-307.5996100,2678.0000000,63.7000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (3)
	CreateObject(3279,-861.4000200,1579.4000200,24.9000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (5)
	CreateObject(3279,-849.4000200,1628.8000500,26.3000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (7)
	CreateObject(3279,-864.0000000,1430.4000200,13.1000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (8)
	CreateObject(8251,307.5000000,2054.3999000,20.6000000,0.0000000,0.0000000,270.0000000); //object(pltschlhnger02_lvs) (1)
	CreateObject(4874,369.7999900,1966.1999500,20.5000000,0.0000000,0.0000000,270.0000000); //object(helipad1_las) (2)
	CreateObject(9241,-1449.5000000,2541.1999500,56.9000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (3)
	CreateObject(9241,-1450.0000000,2507.3999000,58.9000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (3)
	CreateObject(5816,284.8999900,1855.9000200,25.8000000,0.0000000,0.0000000,90.0000000); //object(odrampbit) (1)
	CreateObject(3279,-160.0000000,2615.8999000,60.7000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (1)
	CreateObject(3279,-153.6000100,2654.8000500,63.6000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (2)
	CreateObject(3279,-364.0000000,2703.8999000,62.8000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (3)
	CreateObject(3279,-223.8000000,2691.8999000,61.7000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (4)
	CreateObject(9241,-214.2000000,2661.3000500,63.7000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (1)
	CreateObject(9241,-307.5996100,2678.0000000,63.7000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (3)
	CreateObject(3279,-861.4000200,1579.4000200,24.9000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (5)
	CreateObject(3279,-849.4000200,1628.8000500,26.3000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (7)
	CreateObject(3279,-864.0000000,1430.4000200,13.1000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (8)
	CreateObject(8251,307.5000000,2054.3999000,20.6000000,0.0000000,0.0000000,270.0000000); //object(pltschlhnger02_lvs) (1)
	CreateObject(4874,369.7999900,1966.1999500,20.5000000,0.0000000,0.0000000,270.0000000); //object(helipad1_las) (2)
	CreateObject(9241,-1449.5000000,2541.1999500,56.9000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (3)
	CreateObject(9241,-1450.0000000,2507.3999000,58.9000000,0.0000000,0.0000000,0.0000000); //object(copbits_sfn) (3)
	CreateObject(5816,284.8999900,1855.9000200,25.8000000,0.0000000,0.0000000,90.0000000); //object(odrampbit) (1)


    // briefcases
    BF1 = CreatePickup(1210, 2, 229.94, 1929.07, 17.64);
    BF2 = CreatePickup(1210,2,-252.4021,2603.1230,62.8582, -1);
    BF3 = CreatePickup(1210, 2, -365.27, 2220.66, 42.49);
    BF4 = CreatePickup(1210, 2, -814.32, 1567.55, 26.96);
    BF5 = CreatePickup(1210, 2, -1507.04, 2609.88, 55.83);
    BF6 = CreatePickup(1210, 2, -2279.75, 2289.33, 4.96);
    BF7 = CreatePickup(1210, 2, -146.11, 1131.19, 19.74);
    
    
    // Gangzones
    //Zone 1
    CP[Zone1] = CreateDynamicCP(379.3820,2536.7795,16.5391,5,0,0,-1,25);
    Zone[Zone1] = GangZoneCreate(78,2412,462,2628); // DA
    
    CP[Zone2] = CreateDynamicCP(-551.0111,2594.2004,53.9348,5,0,0,-1,25);
    Zone[Zone2] = GangZoneCreate(-672,2472,-462,2670); // Army Restuarent
    
    CP[Zone3] = CreateDynamicCP(-34.5398,2350.1331,24.3026,5,0,0,-1,25);
    Zone[Zone3] = GangZoneCreate(-96,2280,48,2406); // Snake Farms
    
    CP[Zone4] = CreateDynamicCP(262.8434,2897.5767,9.5997,5,0,0,-1,25);
    Zone[Zone4] = GangZoneCreate(186,2832,330,2988); // Northern Beach
    
    CP[Zone5] = CreateDynamicCP(-909.5822,2690.5254,42.3703,5,0,0,-1,25);
    Zone[Zone5] = GangZoneCreate(-966,2664,-666,2796); // Rusty Bridge
    
    CP[Zone6] = CreateDynamicCP(633.7563,1688.3315,6.9922,5,0,0,-1,25);
    Zone[Zone6] = GangZoneCreate(462,1584,708,1788); // Gas Station
    
    CP[Zone7] = CreateDynamicCP(-348.0113,1565.5128,75.7663,5,0,0,-1,25);
    Zone[Zone7] = GangZoneCreate(-432,1458,-210,1680); // Radar Station
    
    CP[Zone8] = CreateDynamicCP(-1194.1002,1815.9631,41.8145,5,0,0,-1,25);
    Zone[Zone8] = GangZoneCreate(-1290,1716,-1050,1884); // Clukin's Restuarent
    
    CP[Zone9] = CreateDynamicCP(-1471.4646,1864.6365,32.6328,5,0,0,-1,25);
    Zone[Zone9] = GangZoneCreate(-1536,1770,-1362,1914); // Gas Station 2

    for(new x=0; x < sizeof(UnderAttack); x++) UnderAttack[x] = 0;
    for(new x=0; x < sizeof(Captured); x++) Captured[x] = 0;
    for(new x=0; x < sizeof(tCP); x++) tCP[x] = TEAM_NONE;
	return 1;
	
	
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    switch(classid)
    {
        case 0:
   	    {
              gTeam[playerid] = TEAM_USA;
              GameTextForPlayer(playerid, "~b~AMERIKA SERIKAT", 5000, 5);
              SetPlayerPos(playerid, 1522.6503,-806.6635,72.1700);
              SetPlayerFacingAngle(playerid, 8298);
              SetPlayerCameraPos(playerid, 1514.0861,-806.9355,72.0768);
              SetPlayerCameraLookAt(playerid, 1522.6503,-806.6635,72.1700);
        }
        case 1:
        {
               gTeam[playerid] = TEAM_RUSS;
               GameTextForPlayer(playerid, "~r~RUSSIAN", 5000, 5);
               SetPlayerPos(playerid, 1279.3276,-778.4965,95.9663);
               SetPlayerFacingAngle(playerid,8298);
               SetPlayerCameraPos(playerid,1266.1062,-778.3137,95.9665);
               SetPlayerCameraLookAt(playerid,1279.3276,-778.4965,95.9663);
        }
        case 2:
        {
               gTeam[playerid] = TEAM_ARAB;
               GameTextForPlayer(playerid, "~y~ARAB", 5000, 5);
               SetPlayerPos(playerid, 1522.6503,-806.6635,72.1700);
               SetPlayerFacingAngle(playerid, 8298);
               SetPlayerCameraPos(playerid, 1514.0861,-806.9355,72.0768);
               SetPlayerCameraLookAt(playerid, 1522.6503,-806.6635,72.1700);
         }
         case 3:
         {
               gTeam[playerid] = TEAM_EURO;
               GameTextForPlayer(playerid, "~g~EROPA", 5000, 5);
               SetPlayerPos(playerid, 1279.3276,-778.4965,95.9663);
               SetPlayerFacingAngle(playerid,8298);
               SetPlayerCameraPos(playerid,1266.1062,-778.3137,95.9665);
               SetPlayerCameraLookAt(playerid,1279.3276,-778.4965,95.9663);
         }
         case 4:
         {
               gTeam[playerid] = TEAM_REBELS;
               GameTextForPlayer(playerid, "~br~REBELS", 5000, 5);
               SetPlayerPos(playerid, 1279.3276,-778.4965,95.9663);
               SetPlayerFacingAngle(playerid,8298);
               SetPlayerCameraPos(playerid,1266.1062,-778.3137,95.9665);
               SetPlayerCameraLookAt(playerid,1279.3276,-778.4965,95.9663);
        }
        
        case 5:
        {
               gTeam[playerid] = TEAM_ASIA;
               GameTextForPlayer(playerid, "~y~ASIAN", 5000, 5);
               SetPlayerPos(playerid, 1522.6503,-806.6635,72.1700);
               SetPlayerFacingAngle(playerid, 8298);
               SetPlayerCameraPos(playerid, 1514.0861,-806.9355,72.0768);
               SetPlayerCameraLookAt(playerid, 1522.6503,-806.6635,72.1700);
         }
         
        case 6:
         {
               gTeam[playerid] = TEAM_NONE;
               GameTextForPlayer(playerid, "~w~MERC", 5000, 5);
               SetPlayerPos(playerid, 1279.3276,-778.4965,95.9663);
               SetPlayerFacingAngle(playerid,8298);
               SetPlayerCameraPos(playerid,1266.1062,-778.3137,95.9665);
               SetPlayerCameraLookAt(playerid,1279.3276,-778.4965,95.9663);
        }
	}
    return 1;
}

stock IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY)
{
    new Float:X, Float:Y, Float:Z;

    GetPlayerPos(playerid, X, Y, Z);
    if(X >= MinX && X <= MaxX && Y >= MinY && Y <= MaxY) {
        return 1;
    }
    return 0;
}

public OnPlayerConnect(playerid)
{
	FirstSpawn[playerid] = 1;
	
    GangZoneShowForPlayer(playerid, USA_BASE, COLOR_LIGHTERBLUE);
    GangZoneShowForPlayer(playerid, RUSS_BASE, COLOR_RED);
    GangZoneShowForPlayer(playerid, ARAB_BASE, COLOR_ORANGELIGHT);
    GangZoneShowForPlayer(playerid, EURO_BASE, COLOR_GREENLIGHT);
    GangZoneShowForPlayer(playerid, ASIAN_BASE, COLOR_YELLOW);
   // GangZoneShowForPlayer(playerid, LATINO_BASE, COLOR_PURPLES);
    GangZoneShowForPlayer(playerid, REBELS_BASE, COLOR_BROWNLIGHT);
    
    SetPlayerMapIcon(playerid, 5, -36.5458, 2347.6426, 24.1406, 19,2,MAPICON_GLOBAL); //snake farms
    SetPlayerMapIcon(playerid, 6, -1194.1002,1815.9631,41.8145, 19,2,MAPICON_GLOBAL); // cluck'in
    SetPlayerMapIcon(playerid, 7, -1471.4646,1864.6365,32.6328, 19,2,MAPICON_GLOBAL); // 2nd gas station
    SetPlayerMapIcon(playerid, 8, 379.3820,2536.7795,16.5391, 19,2,MAPICON_GLOBAL); // DA
    SetPlayerMapIcon(playerid, 9, -909.5822,2690.5254,42.3703, 19,2,MAPICON_GLOBAL); // Rusty Bridge
    SetPlayerMapIcon(playerid, 10, 262.8434,2897.5767,9.5997, 19,2,MAPICON_GLOBAL); // Northern Beach
    SetPlayerMapIcon(playerid, 11, -551.0111,2594.2004,53.9348, 19,2,MAPICON_GLOBAL); // Army Res
    SetPlayerMapIcon(playerid, 12, 633.7563,1688.3315,6.9922, 19,2,MAPICON_GLOBAL); // cluck'in
    SetPlayerMapIcon(playerid, 13, -348.0113,1565.5128,75.7663, 19,2,MAPICON_GLOBAL); // cluck'in
    
    InCP[playerid] = -1;
    for(new x=0; x < sizeof(tCP); x++)
    {
		switch(x)
		{
		    case TEAM_NONE: GangZoneShowForAll(Zone[x], COLOR_WHITE);
		    case TEAM_USA: GangZoneShowForPlayer(playerid, Zone[x], COLOR_LIGHTERBLUE);
		    case TEAM_RUSS: GangZoneShowForPlayer(playerid, Zone[x], COLOR_RED);
		    case TEAM_ARAB: GangZoneShowForPlayer(playerid, Zone[x], COLOR_ORANGELIGHT);
		    case TEAM_EURO: GangZoneShowForPlayer(playerid, Zone[x], COLOR_GREENLIGHT);
		    case TEAM_REBELS: GangZoneShowForPlayer(playerid, Zone[x], COLOR_BROWNLIGHT);
		    case TEAM_ASIA: GangZoneShowForPlayer(playerid, Zone[x], COLOR_YELLOW);
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SavePlayerData(playerid);
    for(new x=0; x < sizeof(UnderAttack); x++)
    {
        if(InCP[playerid] == x) UnderAttack[x] = 0;
    }
	return 1;
}

public OnPlayerSpawn(playerid)
{
    	SendClientMessage(playerid, COLOR_RED,"Anda memiliki Perlindungan Pembunuhan Anti-Spawn selama 10 detik");
	if(!PlayerInfo[playerid][pSpawn])
	{
	    PlayerInfo[playerid][pSpawn] = true;
	    GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
	}
    switch(gTeam[playerid])
    {
        case TEAM_USA:
        {
            SetPlayerSkin(playerid, 287);
	        SetPlayerTeam(playerid, 0);
	        SetPlayerColor(playerid, COLOR_BLUE);
	        new rand = random(sizeof(UsaSpawn));
		    SetPlayerPos(playerid, UsaSpawn[rand][0], UsaSpawn[rand][1], UsaSpawn[rand][2]);
        }
        case TEAM_RUSS:
        {
            SetPlayerSkin(playerid, 285);
	        SetPlayerTeam(playerid, 1);
	        SetPlayerColor(playerid, COLOR_RED);
	        new rand = random(sizeof(RusSpawn));
		    SetPlayerPos(playerid, RusSpawn[rand][0], RusSpawn[rand][1], RusSpawn[rand][2]);
        }
        case TEAM_ARAB:
        {
            SetPlayerSkin(playerid, 179);
	        SetPlayerTeam(playerid, 2);
	        SetPlayerColor(playerid, COLOR_ORANGELIGHT);
	        new rand = random(sizeof(ArabSpawn));
		    SetPlayerPos(playerid, ArabSpawn[rand][0], ArabSpawn[rand][1], ArabSpawn[rand][2]);
        }
		case TEAM_EURO:
		{
		    SetPlayerSkin(playerid, 165);
	        SetPlayerTeam(playerid, 3);
	        SetPlayerColor(playerid, COLOR_GREENLIGHT);
	        new rand = random(sizeof(EuroSpawn));
	   	   	SetPlayerPos(playerid, EuroSpawn[rand][0], EuroSpawn[rand][1], EuroSpawn[rand][2]);
		}
		case TEAM_REBELS:
		{
		    SetPlayerSkin(playerid, 100);
	        SetPlayerTeam(playerid, 4);
	        SetPlayerColor(playerid, COLOR_BROWN);
	        new rand = random(sizeof(Rebals));
		    SetPlayerPos(playerid, Rebals[rand][0], Rebals[rand][1], Rebals[rand][2]);
		}
		case TEAM_ASIA:
		{
		    SetPlayerSkin(playerid, 122);
	        SetPlayerTeam(playerid, 5);
	        SetPlayerColor(playerid, COLOR_YELLOW);
	        new rand = random(sizeof(AsiaSpawn));
		    SetPlayerPos(playerid, AsiaSpawn[rand][0], AsiaSpawn[rand][1], AsiaSpawn[rand][2]);
		}
		case TEAM_NONE:
		{
		    SetPlayerSkin(playerid, 108);
       		// SetPlayerTeam(playerid, );
        	SetPlayerColor(playerid, COLOR_WHITE);
      		new rand = random(sizeof(MercSpawn));
	  		SetPlayerPos(playerid, MercSpawn[rand][0], MercSpawn[rand][1], MercSpawn[rand][2]);
		}
    }
    
    switch(gPlayerClass[playerid])
    {
        case ASSAULT:
        {
            TogglePlayerControllable(playerid, 1);
	        ResetPlayerWeapons(playerid);
	        GivePlayerWeapon(playerid, 31, 200);//m4
	        GivePlayerWeapon(playerid, 29, 100);//mp5
	        GivePlayerWeapon(playerid, 27, 100);//  combat
	        GivePlayerWeapon(playerid, 24, 70);//deagle
        }
        case SNIPER:
        {
            TogglePlayerControllable(playerid, 1);
	        ResetPlayerWeapons(playerid);
	        GivePlayerWeapon(playerid, 23, 200);//silent pistol
	        GivePlayerWeapon(playerid, 34, 250);//sniper
	        GivePlayerWeapon(playerid, 29, 250);//mp5
	        GivePlayerWeapon(playerid, 4, 1);//knife
	        RemovePlayerMapIcon(playerid, 0);
        }
        case MEDIC:
        {
            TogglePlayerControllable(playerid, 1);
	        ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 33, 200);
	  		GivePlayerWeapon(playerid, 22, 200);
	    	GivePlayerWeapon(playerid, 25, 200);
	     	GivePlayerWeapon(playerid, 11, 2);
        }
    }
        if(FirstSpawn[playerid] == 1)
    {
    	ShowPlayerDialog(playerid, 999, DIALOG_STYLE_LIST, "{6EF83C}Pilih Kelas:", "Assault\nSniper\nMedic", "Choose","");
		FirstSpawn[playerid] = 0;
    }

    if(GetPlayerScore(playerid) >= 20000)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Pangkat Anda adalah: Legenda");
        SetPlayerHealth(playerid, 1000);
        SetPlayerArmour(playerid, 1000);

    }
    if(GetPlayerScore(playerid) >= 7000)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Pangkat Anda adalah: Jendral");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 100);

    }
    if(GetPlayerScore(playerid) >= 2500)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Pangkat Anda adalah: Letnan Kolonel");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 90);

    }
    else if(GetPlayerScore(playerid) >= 750 && GetPlayerScore(playerid) < 2500)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Pangkat Anda adalah: Kolonel");
        SendClientMessage(playerid, 0xFFFFFFFF, "RANK BONUS: Granades ; Tec-9 ; 50 Armor");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 50);
    }
    else if(GetPlayerScore(playerid) >= 300 && GetPlayerScore(playerid) < 750)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Pangkat Anda adalah: Letnan");
        SendClientMessage(playerid, 0xFFFFFFFF, "BONUS PERINGKAT: Knife ; Combat Shotgun ; 40 Armor");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 40);

    }
    else if(GetPlayerScore(playerid) >= 150 && GetPlayerScore(playerid) < 300)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Pangkat Anda adalah Perwira");
        SendClientMessage(playerid, 0xFFFFFFFF, "BONUS PERINGKAT: D-Eagle ; 30 Armor");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 30);
    }
    else if(GetPlayerScore(playerid) >= 50 && GetPlayerScore(playerid) < 150)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Peringkat Anda adalah: Kopral");
        SendClientMessage(playerid, 0xFFFFFFFF, "BONUS PERINGKAT: MP5 ; 20 Armor");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 20);
    }
    else if(GetPlayerScore(playerid) >= 0 && GetPlayerScore(playerid) < 50)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "Peringkat Anda adalah: Pribadi");
		SendClientMessage(playerid, 0xFFFFFFFF, "BONUS PERINGKAT: Shotgun ; Silenced Colt ; Baseball Bat ; 10 Armor");
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 10);

    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new killername[MAX_PLAYER_NAME], playername[MAX_PLAYER_NAME], string[150];
	
	GetPlayerName(killerid, killername, sizeof(killername));
	GetPlayerName(playerid, playername, sizeof(playername));

    SendDeathMessage(killerid, playerid, reason);
    SendClientMessage(playerid, 0xAAAAAAAA, "Anda meninggal. Kehilangan $10,00 untuk kematian tragismu.");
    GivePlayerMoney(playerid, -2500);
    GivePlayerMoney(killerid, 5500);
    SetPlayerScore(killerid, GetPlayerScore(killerid)+1);
    format(string, 150, "~w~Killed by ~r~%s", killername);
    GameTextForPlayer(playerid, string,2500,3);
    
    format(string, 150, "Kamu Membunuh %s. Hadiah: $55,00 + 1 score", playername); // Telling the player who he killed and the reward he got.
    SendClientMessage(killerid, 0xAAAAAAAA, string);
    SetPlayerWantedLevel(killerid, 0);



    for(new x=0; x < sizeof(UnderAttack); x++)
    {
		if(InCP[playerid] == x)
		{
	        KillTimer(timer[playerid][x]);
	    	KillTimer(CountTime[playerid]);
	    	UnderAttack[x] = 0;
		}
    }
    
    if(IsPlayerInArea(playerid, -54,1668,426,2136))
		{
			if(gTeam[playerid] == TEAM_USA)
			{
				if(IsPlayerInAnyVehicle(killerid))
				{
					if(GetVehicleModel(GetPlayerVehicleID(killerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 520 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 447)
					{
						SetPlayerHealth(killerid,0);
						GameTextForPlayer(killerid,"~y~Pemerkosaan Dasar Tidak Diizinkan", 3000, 3);

					}
				}
			}
		}
		if(IsPlayerInArea(playerid, -378,960,144,1248))
		{
			if(gTeam[playerid] == TEAM_RUSS)
			{
				if(IsPlayerInAnyVehicle(killerid))
				{
					if(GetVehicleModel(GetPlayerVehicleID(killerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 520 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 447)
					{
						SetPlayerHealth(killerid,0);
						GameTextForPlayer(killerid,"~y~Pemerkosaan Dasar Tidak Diizinkan", 3000, 3);
					}
				}
			}
		}
		if(IsPlayerInArea(playerid, -930,1392,-648,1674))
		{
			if(gTeam[playerid] == TEAM_ARAB)
			{
				if(IsPlayerInAnyVehicle(killerid))
				{
					if(GetVehicleModel(GetPlayerVehicleID(killerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 520 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 447)
					{
						SetPlayerHealth(killerid,0);
						GameTextForPlayer(killerid,"~y~Pemerkosaan Dasar Tidak Diizinkan", 3000, 3);
					}
				}
			}
		}
		if(IsPlayerInArea(playerid, -378,2556,-78,2814))
		{
			if(gTeam[playerid] == TEAM_EURO)
			{
				if(IsPlayerInAnyVehicle(killerid))
				{
					if(GetVehicleModel(GetPlayerVehicleID(killerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 520 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 447)
					{
						SetPlayerHealth(killerid,0);
						GameTextForPlayer(killerid,"~y~Pemerkosaan Dasar Tidak Diizinkan", 3000, 3);
					}
				}
			}
		}
		
		if(IsPlayerInArea(playerid, -516,2112,-288,2298))
		{
			if(gTeam[playerid] == TEAM_REBELS)
			{
				if(IsPlayerInAnyVehicle(killerid))
				{
					if(GetVehicleModel(GetPlayerVehicleID(killerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 520 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 447)
					{
						SetPlayerHealth(killerid,0);
						GameTextForPlayer(killerid,"~y~Pemerkosaan Dasar Tidak Diizinkan", 3000, 3);
					}
				}
			}
		}
		
  		if(IsPlayerInArea(playerid, -1662,2460,-1350,2736))
		{
			if(gTeam[playerid] == TEAM_ASIA)
			{
				if(IsPlayerInAnyVehicle(killerid))
				{
					if(GetVehicleModel(GetPlayerVehicleID(killerid)) == 432 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 520 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 425 || GetVehicleModel(GetPlayerVehicleID(killerid)) == 447)
					{
						SetPlayerHealth(killerid,0);
						GameTextForPlayer(killerid,"~y~Pemerkosaan Dasar Tidak Diizinkan", 3000, 3);
					}
				}
			}
		}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
       if (strcmp("/cmds", cmdtext, true, 5) == 0)
       {
			new msg[400];
			
			format(msg, 400, "{09FF00}%s• /help -> {FFFFFF}Semua informasi yang terkait dengan server akan ditampilkan di sini.\n", msg);
			format(msg, 400, "{09FF00}%s• /rules -> {FFFFFF}Hal-hal umum yang HARUS* dipatuhi di server.\n", msg);
			format(msg, 400, "{09FF00}%s• /pm -> {FFFFFF}Jika Anda ingin berbicara dengan seseorang secara pribadi, Anda dapat menggunakan ini.\n", msg);
			format(msg, 400, "{09FF00}%s• /st -> {FFFFFF}Ingin berganti tim? Perintah ini akan membantu Anda.\n", msg);
			format(msg, 400, "{09FF00}%s• /sc -> {FFFFFF}Mau pindah kelas? Perintah ini akan membantu Anda.\n", msg);
			format(msg, 400, "{09FF00}%s• /cmds -> {FFFFFF}Menunjukkan perintah yang paling penting dari server.\n", msg);
			format(msg, 400, "{09FF00}%s• /report -> {FFFFFF}Jika Anda melihat seorang peretas, gunakan ini untuk mengumumkan kepada admin tentang hal itu.\n", msg);
            format(msg, 400, "{09FF00}%s• /admins -> {FFFFFF}Menunjukkan admin online dan On-Duty saat ini.\n", msg);
            format(msg, 400, "{09FF00}%s• /ranks -> {FFFFFF}Menunjukkan peringkat dan informasinya.\n\n", msg);
			format(msg, 400, "{FF0000}%sUntuk informasi lebih lanjut silahkan baca /rules dan /help. Terima kasih.", msg);

			ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, "{737373}WW5-C Commands", msg, "OK", "Close");
            return 1;
       }

       if (strcmp("/help", cmdtext, true, 5) == 0)
       {
			new msg[400];
			
			format(msg, 400, "{09FF00}%s• /help -> {FFFFFF}Semua informasi yang terkait dengan server akan ditampilkan di sini.\n", msg);
			format(msg, 400, "{09FF00}%s• /report -> {FFFFFF}Jika Anda melihat seorang peretas, gunakan ini untuk mengumumkan kepada admin tentang hal itu.\n", msg);
			format(msg, 400, "{09FF00}%s• /pm -> {FFFFFF}Jika Anda ingin berbicara dengan seseorang secara pribadi, Anda dapat menggunakan ini.\n", msg);
			format(msg, 400, "{09FF00}%s• /admins -> {FFFFFF}Menunjukkan admin online dan On-Duty saat ini.\n", msg);
			format(msg, 400, "{FF0000}%sJika Anda tidak yakin tentang sesuatu, jangan ragu untuk bertanya secara online /admins.\n\n", msg);

			ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "{737373}WW5-C Help", msg, "OK", "Close");
            return 1;
       }

       if (strcmp("/rules", cmdtext, true, 6) == 0)
       {
            new msg[400];
       
       		format(msg, 400, "{09FF00}%s• Penghinaan - Penghinaan tidak diperbolehkan [Kemungkinan Peringatan]\n",msg);
			format(msg, 400, "{09FF00}%s• Berapi - Berapi tidak diperbolehkan [Kemungkinan Peringatan]\n",msg);
			format(msg, 400, "{09FF00}%s• Memprovokasi - Memprovokasi tidak diperbolehkan [Peringatan]\n", msg);
			format(msg, 400, "{09FF00}%s• Pembunuhan Tim - Pembunuhan Tim tidak diperbolehkan [Kick]\n", msg);
			format(msg, 400, "{09FF00}%s• Peretasan - Peretasan tidak diizinkan DAN* ditoleransi. [Ban]\n\n", msg);
			format(msg, 400, "{FF0000}%sPelanggaran aturan yang terus-menerus di bawah ini akan menyebabkan tindakan yang relevan segera diambil.", msg);

            ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, "{737373}WW5-C Rules", msg, "Agree", "");
            return 1;
       }
       
       if (strcmp("/ranks", cmdtext, true, 6) == 0)
       {
            ShowPlayerDialog(playerid, DIALOG_RANKS, DIALOG_STYLE_MSGBOX, "{737373}WW5-C Ranks", "Private - 0 score \nKopral - 50 \nLetnan - 150 \nMajor - 300\nKolonel - 750 \nLetnan Kolonel - 2500 \nJendral - 7000 \nLegenda - 20000", "OK", "Close");
            return 1;
       }
       
       if (strcmp("/st", cmdtext, true, 10) == 0)
       {
        ForceClassSelection(playerid);
        SendClientMessage(playerid, COLOR_RED,"Anda akan berganti tim setelah kematian berikutnya!");
        return 1;
       }
        
       if (strcmp("/kill", cmdtext, true, 10) == 0)
       {
        ForceClassSelection(playerid);
        SetPlayerHealth(playerid, 0.00);
        return 1;
       }
	   if(strcmp("/sc", cmdtext, true, 10) == 0)
	   {
		 FirstSpawn[playerid] = 1;
		 SendClientMessage(playerid, COLOR_RED,"Anda akan mengubah kelas setelah kematian berikutnya !");
		 SetPlayerHealth(playerid, -1.00);
		 ForceClassSelection(playerid);
		 
		 return 1;
	   }
	   
       return 0;
}
		
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_RANKS:
	    {
	        if(response)
			{
				if(listitem == 0)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang Pribadi");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 0 skor.");
				}
				if(listitem == 1)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang Kopral:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 50 skor.");

				}
				if(listitem == 2)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang pangkat Perwira:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 150 skor.");
				}
				if(listitem == 3)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang pangkat Letnan:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 300 skor.");
				}
				if(listitem == 4)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang pangkat Kolonel:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 650 skor.");
				}
				if(listitem == 5)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang pangkat Letnan Kolonel:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 2500 skor.");
				}
				if(listitem == 6)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang pangkat Jendral:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 7000 skor.");
				}
				if(listitem == 7)
				{
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Informasi tentang pangkat Legenda:");
	        		SendClientMessage(playerid, 0xFFFFFFFF, "Untuk peringkat ini Anda membutuhkan setidaknya 29900 skor.");
				}
			}
	    }
	    case 999:
	    {
     		if(response)
      		{
      		    switch(listitem)
      		    {
       			    case 0:
       			    {
                    	if(GetPlayerScore(playerid) >= 0)
                        {
	                        SendClientMessage(playerid, COLOR_WHITE, "Anda memilih Assault sebagai kelas Anda.");
	                        ShowPlayerDialog(playerid, 11, DIALOG_STYLE_MSGBOX, "{6EF83C}Assault Class:", "{F81414}Kemampuan:\n{FFFFFF}Kelas Solo, bagus dalam serangan infanteri.\n\n{F81414}Senjata:\n\n{FFFFFF}M4\n{FFFFFF}Shotgun\n{FFFFFF}Deagle", "Play","");
	                        gPlayerClass[playerid] = ASSAULT;//
	                        PickedClass[playerid] = 1;
	                        SetPlayerVirtualWorld(playerid, 0);
	                        TogglePlayerControllable(playerid, 1);
	                        ResetPlayerWeapons(playerid);
	                        GivePlayerWeapon(playerid, 31, 200);//m4
	                        GivePlayerWeapon(playerid, 29, 100);//mp5
	                        GivePlayerWeapon(playerid, 27, 100);//  combat
	                        GivePlayerWeapon(playerid, 24, 70);//deagle
                        }
                    }
					case 1:
                    {
                    	if(GetPlayerScore(playerid) >= 0)
                        {
	                        SendClientMessage(playerid, COLOR_WHITE, "Anda memilih Sniper sebagai kelas Anda.");
	                        ShowPlayerDialog(playerid, 11, DIALOG_STYLE_MSGBOX, "{6EF83C}Sniper Class:", "{F81414}Kemampuan:\n{FFFFFF}Kelas Pencari Lokasi, Selalu tidak terlihat di peta.\n\n{F81414}Senjata:\n\n{FFFFFF}Sniper Rifle\n{FFFFFF}Mp5\n{FFFFFF}Pisau", "Play","");
	                        gPlayerClass[playerid] = SNIPER;
	                        PickedClass[playerid] = 2;
	                        RemovePlayerMapIcon(playerid, 0);
	                        SetPlayerVirtualWorld(playerid, 0);
	                        TogglePlayerControllable(playerid, 1);
	                        ResetPlayerWeapons(playerid);
	                        GivePlayerWeapon(playerid, 34, 250);//sniper
	                        GivePlayerWeapon(playerid, 29, 250);//mp5
	                        GivePlayerWeapon(playerid, 4, 1);//knife
                        }
                    }

                	case 2:
                    {
                    	if(GetPlayerScore(playerid) >= 0)
                        {
	                        SendClientMessage(playerid, COLOR_WHITE, "Anda memilih Medis sebagai kelas Anda.");
	                        ShowPlayerDialog(playerid, 11, DIALOG_STYLE_MSGBOX, "{6EF83C}Medic Class:", "{F81414}Kemampuan:\n{FFFFFF}Kelas Dukungan , dapat menggunakan /heal \n\n{F81414}Senjata:\n\n{FFFFFF}Spas12\n{FFFFFF}Pistol Senyap\n{FFFFFF}RPG\n{FFFFFF} Granat", "Play","");
	                        gPlayerClass[playerid] = MEDIC;
	                        PickedClass[playerid] = 3;
	                        SetPlayerVirtualWorld(playerid, 0);
	                        TogglePlayerControllable(playerid, 1);
	                        ResetPlayerWeapons(playerid);
	                        GivePlayerWeapon(playerid, 33, 200);
	                        GivePlayerWeapon(playerid, 22, 200);
	                        GivePlayerWeapon(playerid, 25, 200);
	                        GivePlayerWeapon(playerid, 11, 2);
                        }
					}
                }
			}
		}
		case 2:
		{
		    if(response)
		    {
	  			switch(listitem)
	        	{
	        	    case 0:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 5000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
						GivePlayerMoney(playerid, -5000);
	                    ShowDialog(playerid);
						SetPlayerHealth(playerid, 100.0);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli Fataj Seharga $50,00");
					}
	        	    case 1:
	        	    {
	                    if(GetPlayerMoney(playerid) < 5500) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	                    ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -5500);
	        	        ShowDialog(playerid);
	        	        SetPlayerArmour(playerid, 100.0);
                  		SendClientMessage(playerid, COLOR_WHITE, "Anda membeli Armor Seharga $55,00");
	        	    }
	        	    case 2:
	        	    {
	        	        ShowPlayerDialog(playerid, 30, DIALOG_STYLE_LIST, "Weapons", "M4 - $80,00\nAK47 - $80,00\nMP5 - $60,00\nUZI - $120,00\nCombat Shotgun - $100,00$\nShotgun - $50,00\nDesert Eagle - $60,00\nSilent Pistol - $30,00\nPistol - $30,00$\nTec 9 - $30,00\nSawn-Off Shotgun - $80,00\nRPG - $100,00", "Buy", "Exit");
	 	 			}
	 			}
	    	}
    	}
    	case 30:
    	{
    	    if(response)
    	    {
	    	    switch(listitem)
	        	{
	        	    case 0:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 8000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -8000);
	        	        GivePlayerWeapon(playerid, 31, 300);
	        	        ShowDialog(playerid);
						SendClientMessage(playerid,COLOR_WHITE, "You bought M4 with 300 Ammo.");
	        	    }
	        	    case 1:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 8000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -8000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 30, 300);
						SendClientMessage(playerid, COLOR_WHITE, "You bought AK 47 with 300 Ammo.");
	        	    }
	        	    case 2:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 6000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	                 	ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -6000);
	        	        GivePlayerWeapon(playerid, 29, 300);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli MP5 dengan 300 Ammo.");
	        	    }
	        	    case 3:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 12000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -12000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 28, 500);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli UZI dengan 300 Ammo.");
	        	    }
	        	    case 4:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 10000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -10000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 27, 300);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli SPAZ-12 dengan 300 Ammo.");
	        	    }
	        	    case 5:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 5000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -5000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 25, 300);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli Shotgun dengan 300 Ammo.");
	        	    }
	        	    case 6:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 6000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -6000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 24, 100);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli Desert Eagle dengan 100 Ammo.");
	        	    }
	        	    case 7:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 3000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -3000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 23, 300);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli Silencer dengan 300 Ammo.");
	        	    }
	        	    case 8:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 3000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -3000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 22, 300);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli Pistol dengan 300 Ammo.");
      				}
          			case 9:
       	     		{
						SendClientMessage(playerid, COLOR_WHITE, " Senjata Ini Dihapus oleh Admin");
	        	    }
	        	    case 10:
        	     	{
						SendClientMessage(playerid, COLOR_WHITE, " Senjata Ini Dihapus.");
	        	    }
	        	    case 11:
	        	    {
	                 	if(GetPlayerMoney(playerid) < 25000) return SendClientMessage(playerid, 0xFF0000AA, "ERROR: Anda tidak punya cukup uang.") && ShowDialog(playerid);
	        	        GivePlayerMoney(playerid, -10000);
	        	        ShowDialog(playerid);
	        	        GivePlayerWeapon(playerid, 35, 1);
						SendClientMessage(playerid, COLOR_WHITE, "Anda membeli RPG Launcher dengan 1 Ammo.");
					}
	        	}
			}
    	}
  	}
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{

    if(newstate == PLAYER_STATE_PASSENGER || newstate == PLAYER_STATE_DRIVER) SetPlayerArmedWeapon(playerid, 0);

    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if(pickupid == BF1) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
	{
    if(pickupid == BF2) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
    }
    if(pickupid == BF3) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
	{
    if(pickupid == BF4) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
    }
    if(pickupid == BF5) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
	{
    if(pickupid == BF6) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
	}
    if(pickupid == BF7) ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
	{

	 }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
  // sea sparrow rank
    new Sparrow = GetVehicleModel(GetPlayerVehicleID(playerid));
	if(PickedClass[playerid] >= 1 && GetPlayerScore(playerid) <= 300) {
    if(Sparrow == 447) {
    Slap(playerid);
    SendClientMessage(playerid,COLOR_RED,"ERROR: Anda harus menjadi kelas Mayor + Assault untuk Mengemudikan kendaraan ini.");
        }
}
	  // rhino rank
	  new Tank = GetVehicleModel(GetPlayerVehicleID(playerid));
	  if(PickedClass[playerid] >= 1 && GetPlayerScore(playerid) <= 750) {
       if(Tank == 432) {
       Slap(playerid);
       SendClientMessage(playerid,COLOR_RED,"ERROR: Anda harus menjadi kelas Kolonel + Serangan untuk Mengemudikan kendaraan ini.");
        }
}
// hydra rank
new Hydra = GetVehicleModel(GetPlayerVehicleID(playerid));
	  if(PickedClass[playerid] >= 1 && GetPlayerScore(playerid) <= 1500) {
      if(Hydra == 520) {
	    Slap(playerid);
	    SendClientMessage(playerid,COLOR_RED,"ERROR: Anda harus menjadi kelas General + Assault untuk Mengemudikan kendaraan ini.");
        }
        }
 // hunter rank
 new Hunter = GetVehicleModel(GetPlayerVehicleID(playerid));
    if(PickedClass[playerid] >= 1 && GetPlayerScore(playerid) <= 1500) {
         if(Hunter == 425) {
         Slap(playerid);
         SendClientMessage(playerid,COLOR_RED,"ERROR: Anda harus memiliki kelas General + Assault untuk Mengemudikan kendaraan ini.");
       }
       }
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    for(new x=0; x < sizeof(CP); x++)
    {
        if(checkpointid == CP[x])
        {
            if(UnderAttack[x] == 1)
         	{
             	SendClientMessage(playerid, 0xFF0000FF,"Zona ini sudah ditangkap!");
         	}
         	else if(gTeam[playerid] == tCP[x])
         	{
             	SendClientMessage(playerid, 0xFF0000FF,"Zona ini sudah ditangkap oleh tim Anda!");
         	}
         	else if(gTeam[playerid] == TEAM_NONE)
         	{
             	SendClientMessage(playerid, 0xFF0000FF,"Anda tidak memiliki tim sehingga Anda tidak dapat menangkap!");
         	}
         	else
         	{
	            UnderAttack[x] = 1;
	            timer[playerid][x] = SetTimerEx("SetCaptureZone", 25000, false,"i",playerid);
	            CountTime[playerid] = SetTimerEx("CountDown", 1, false,"i", playerid);
	            InCP[playerid] = x;
	            Captured[Zone1] = 0;
	            switch(gTeam[playerid])
	            {
	                case TEAM_USA: GangZoneFlashForAll(Zone[x], COLOR_LIGHTERBLUE);
	                case TEAM_RUSS: GangZoneFlashForAll(Zone[x], COLOR_RED);
	                case TEAM_ARAB: GangZoneFlashForAll(Zone[x], COLOR_ORANGELIGHT);
	                case TEAM_EURO: GangZoneFlashForAll(Zone[x], COLOR_GREENLIGHT);
	                case TEAM_REBELS: GangZoneFlashForAll(Zone[x], COLOR_BROWNLIGHT);
	                case TEAM_ASIA: GangZoneFlashForAll(Zone[x], COLOR_YELLOW);
	                
	            }
            	SendClientMessage(playerid, COLOR_YELLOW,"Tunggu 25 detik untuk menangkap zona ini");
         	}
		}
	}
 	return 1;
}

public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
    for(new x=0; x < sizeof(CP); x++)
    {
        if(checkpointid == CP[x])
        {
            if(Captured[x] == 1)
            {
                GangZoneStopFlashForAll(Zone[x]);
	            UnderAttack[x] = 0;
	            InCP[playerid] = 0;
	            tCP[x] = gTeam[playerid];
	            switch(gTeam[playerid])
	            {
	                case TEAM_USA: GangZoneShowForAll(Zone[x], COLOR_LIGHTERBLUE);
	                case TEAM_RUSS: GangZoneShowForAll(Zone[x], COLOR_RED);
	                case TEAM_ARAB: GangZoneShowForAll(Zone[x], COLOR_ORANGELIGHT);
	                case TEAM_EURO: GangZoneShowForAll(Zone[x], COLOR_GREENLIGHT);
	                case TEAM_REBELS: GangZoneShowForAll(Zone[x], COLOR_BROWNLIGHT);
	                case TEAM_ASIA: GangZoneShowForAll(Zone[x], COLOR_YELLOW);
	            }
			}
		}
	}
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(PlayerInfo[playerid][pAdmin] >= 1)
    {
            if(!IsPlayerInAnyVehicle(playerid))
            {
                SetPlayerPosFindZ(playerid, fX, fY, fZ);
            }
            else if(IsPlayerInAnyVehicle(playerid))
            {
                new Babatz = GetPlayerVehicleID(playerid);
                new Batz = GetPlayerVehicleSeat(playerid);
                SetVehiclePos(Babatz,fX,fY,fZ);
                SetPlayerPosFindZ(playerid, fX, fY, fZ);
                PutPlayerInVehicle(playerid,Babatz,Batz);
            }
    }
    return SendClientMessage(playerid,BIRU, "Diteleportasi ke lokasi yang ditandai.");
}

stock Slap(playerid)
{
   new Float:x, Float:y, Float:z;
   GetPlayerPos(playerid, x, y, z); SetPlayerPos(playerid,x,y,z+1);
   return 1;
}

stock ShowDialog(playerid)
{
ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Tas", "Health - $50,00\nArmour - $55,00\n\nWeapons", "Select", "Cancel");
return 1;
}

//====================F u n c t i o n======================
forward RandomMessage();
public RandomMessage()
{
	SendClientMessageToAll(COLOR_ORANGE, RandomMessages[random(sizeof(RandomMessages))]);
	return 1;
}

forward SetCaptureZone(playerid);
public SetCaptureZone(playerid)
{
    for(new x=0; x < sizeof(UnderAttack); x++)
    {
        if(InCP[playerid] == x)
        {
       		SetPlayerScore(playerid, GetPlayerScore(playerid)+5);
         	GivePlayerMoney(playerid, 5000);
         	SendClientMessage(playerid, COLOR_YELLOW,"Selamat! Anda telah berhasil merebut zona ini!! Anda mendapatkan +5 skor dan +$50,00!");
         	tCP[x] = gTeam[playerid];
         	GangZoneStopFlashForAll(Zone[x]);
         	Captured[x] = 1;
	        KillTimer(CountTime[playerid]);
         	UnderAttack[x] = 0;
         	KillTimer(timer[playerid][x]);
         	switch(gTeam[playerid])
          	{
	           	case TEAM_USA: GangZoneShowForAll(Zone[x], COLOR_LIGHTERBLUE);
	            case TEAM_RUSS: GangZoneShowForAll(Zone[x], COLOR_RED);
	            case TEAM_ARAB: GangZoneShowForAll(Zone[x], COLOR_ORANGELIGHT);
	            case TEAM_EURO: GangZoneShowForAll(Zone[x], COLOR_GREENLIGHT);
	            case TEAM_REBELS: GangZoneShowForAll(Zone[x], COLOR_BROWNLIGHT);
	            case TEAM_ASIA: GangZoneShowForAll(Zone[x], COLOR_YELLOW);
           }
        }
	}
 	return 1;
}

forward CountDown(playerid);
public CountDown(playerid)
{
    CountVar[playerid]--;
    if(CountVar[playerid] == 0)
    {
      CountVar[playerid] = 20;
      KillTimer(CountTime[playerid]);
    }
    CountTime[playerid] = SetTimerEx("CountDown", 1000, false,"i", playerid);
    return 1;
}

CMD:cc(playerid)
{
	if(PlayerInfo[playerid][pAdmin] < 1)
	
		return SendClientMessage(playerid, BIRU, "ERROR: Hanya Tersedia Untuk Admin");

	ClearChat();
	return 1;
}

static SavePlayerData(playerid)
{
	new query[2512];
	if(PlayerInfo[playerid][pSpawn])
	{
		mysql_format(sqlcon, query, sizeof(query), "UPDATE `characters` SET ");
	    mysql_format(sqlcon, query, sizeof(query), "%s`AdminLevel`='%d', ", query, PlayerInfo[playerid][pAdmin]);
	    mysql_format(sqlcon, query, sizeof(query), "%s`Money`='%d', ", query, PlayerInfo[playerid][pMoney]);
	    mysql_format(sqlcon, query, sizeof(query), "%sWHERE `pID` = %d", query, PlayerInfo[playerid][pID]);
		mysql_query(sqlcon, query, true);
	}
	return 1;
}

WW5C::LoadCharacterData(playerid)
{
	cache_get_value_name_int(0, "pID", PlayerInfo[playerid][pID]);
	cache_get_value_name(0, "Nama", PlayerInfo[playerid][pName]);
	cache_get_value_name_int(0, "AdminLevel", PlayerInfo[playerid][pAdmin]);
	cache_get_value_name_int(0, "Money", PlayerInfo[playerid][pMoney]);
    return 1;
}
