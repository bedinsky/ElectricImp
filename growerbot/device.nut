// growerbot
//read serial value from growerbot and display on imp node

/*
local outputTemp = OutputPort("temp", "temp");
local outputLight = OutputPort("light", "light");
local outputMoist = OutputPort("moist", "moist");
local outputHumid = OutputPort("humid", "humid");
imp.configure("growerbot", [], [outputTemp, outputLight, outputMoist, outputHumid]);
*/
imp.configure("growerbot", [], []);


hardware.uart1289.configure(2400, 8, PARITY_NONE, 1, NO_CTSRTS);

function writeStuff()
{
local c = "";
local transString = "";
local b = hardware.uart1289.read();
local needSync = false;

while (b != -1) {
    c += b.tochar();
    b = hardware.uart1289.read();
}

   
if (c.len())
{
    server.log(c);
    
    needSync = (c.find("DD") != null);
    //server.log(needSync);
    //find location of T in sensor data string
    local tStart = c.find("T");
    
    if (tStart != null) {
        //add 1 to get rid of T at start of data string
        tStart = tStart + 1;
        //trim data string c to get rid of T and everything before
        local temp = c.slice(tStart);
        //get rid of T in temp and everything after it
        local tEnd = temp.find("T");
        if (tEnd != null) {
            temp = temp.slice(0,tEnd);
            //server.log(temp);
            transString = transString + "temp," + temp + "\n";
        }
        
    }

    //find location of M in sensor data string
    local mStart = c.find("M");
    if (mStart != null) {
        //add 1 to get rid of M at start of data string
        mStart = mStart + 1;
        //trim data string c to get rid of M and everything before
        local moist = c.slice(mStart);
        //get rid of M in moist and everything after it
        local mEnd = moist.find("M");
        if (mEnd != null) {
            moist = moist.slice(0,mEnd);
            //server.log(moist);
            transString = transString + "moist," + moist + "\n";
        }
    }    
    
    
    //find location of H in sensor data string
    local hStart = c.find("H");
    if (hStart  != null) {
        hStart = hStart + 1;
        local humid = c.slice(hStart);
        local hEnd = humid.find("H");
        if (hEnd != null) {
            humid = humid.slice(0,hEnd);
            //server.log(humid);
            transString = transString + "humid," + humid + "\n";
        }
    }
    
    //find location of L in sensor data string
    local lStart = c.find("L");
    
    if (lStart  != null) {
        lStart = lStart + 1;
        local light = c.slice(lStart);
        local lEnd = light.find("L");
        if (lEnd != null) {
            light = light.slice(0,lEnd);
            //server.log(light);
            transString = transString + "light," + light + "\n";
        }
    }
    
    agent.send("data", transString);
}

if (needSync) {
    local d = date(time() + 3600 * 2 - 3 * 60);
    local today = format("%d%02d%02d%02d%02d%02d", d.year, d.month+1, d.day, d.hour, d.min, d.sec );
    server.log(today);
    hardware.uart1289.write( format ("D%sD\n", today ));
}
//hardware.uart1289.write( "\n" );
//server.log(format ( "T%dT", time() ));
//example of changing light proportion remotely
//hardware.uart1289.write("L0.4L\n");
//example of changing moisture goal remotely
//hardware.uart1289.write("M500M\n");
//example of changing light goal remotely
//hardware.uart1289.write("B50B\n");
//example of turning on light remotely
//hardware.uart1289.write("l0\n");
//example of turning on water remotely
//hardware.uart1289.write("p1\n");
//hardware.uart1289.write("l1\n");

imp.wakeup(5, writeStuff);
}

writeStuff();

