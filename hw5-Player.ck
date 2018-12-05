// a sample sound player goes with DataReader class
// @author Chris Chafe 

//=== TODO: modify this path and name for your system ===//
me.dir() => string dataDir;
"daily-precipitation-mm-hveravell.csv" => string dataFile;

// update rate in ms
1000 => float update; 

// new class to manage envelopes
class Env
{
  Step s => Envelope e => blackhole; // feed constant into env
  update::ms => e.duration; // set ramp time
  fun void target (float val) { e.target(val); }
}


// the actual instrument that plays the data
// currently it is setting gain and frequency based on the input data
// note that the 'instrument' currently playing the data is a SinOsc, and gain and frequency
// are being controlled. This should be changed to your physical model, and perhaps
// more parameters should be changed besides amplitude and frequency!
class Player
{
    SndBuf s => dac;
    me.dir()+"Rain_Inside_House.wav" => s.read; 
    SndBuf thund => dac;


    //rev.mix(0.05);
    Env amp, freq;
    fun void run() // sample loop to smoothly update gain
    { 
        0 => int counter;
        while (true)
        {
            <<<counter>>>;
            1 +=> counter;
            if(counter == 18){
                break;
            }
            <<<amp.e.last()*10000>>>;
            //sets the gain and frequency
            
            if(amp.e.last()*10000 > 5){
                
                me.dir()+"thunder_strike_1.wav" => thund.read; 
                1 => thund.gain;               
                
            }
            
            amp.e.last()*10000 => s.gain;
            //s.freq(freq.e.last());
            1000::ms => now;
        }
    }  spork ~ run(); // run run
}

DataReader drywhite; //instantiate a DataReader object that will read the data
drywhite.setDataSource(dataDir + dataFile); //find the data
drywhite.start(); //read the data
Player p;


while (!drywhite.isFinished())
{
    // next data point, scaled in 0.0 - 1.0 range
    drywhite.scaledVal() => float w; 
    p.amp.target(0.5 * Math.pow(w, 2.0)); //the actual values that get sent to Player amplitude
    p.freq.target(Std.mtof(80.0 + w*20.0)); //the values that get sent to our Player frequency

    update::ms => now;
}
