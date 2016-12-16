// f. FranK , imma
/*
{Saw.ar((60-3).midicps )*0.005}.play
{Saw.ar((60+4).midicps )*0.005}.play
*/
(
q = q ? ();

q.numPlayers = 1; 			// how many players to make
q.numChans = q.numChans ? 2;	// how many ch output



//=====//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////==========//////////


// add your own fx stuff here!
q.generatorsLibrary = IdentityDictionary
[
	'samplM' -> {| bufnum = 1, inVol = 1, pbRate= 1, laG= 0.4|
			var gen = PlayBuf.ar(1, bufnum, pbRate.cubed.lag2(laG), loop: 1);
			var gen2 = PlayBuf.ar(2, bufnum, pbRate.cubed.lag2(laG), loop: 1).sum*0.75;
			Limiter.ar( gen + gen2 * inVol );
		}
	,/*
	'stereoSampl' -> {|bufnum = 1, inVol = 1, pbRate= 1, laG= 0.4|
			var gen = PlayBuf.ar(2, bufnum, pbRate.cubed.lag2(laG), loop: 1).sum*0.75;
			Limiter.ar( gen * inVol );
		}
	,*/
	'tuner' -> { arg which = 0;
		var two = Saw.ar((60 + [-8, -3, 2, 7] ).midicps ) * 0.1;
		Select.ar(which, two);
	},
	'audioIn' -> {|inChan = 0, inVol = 1|
			var gen = SoundIn.ar(inChan);
			gen = HPF.ar(gen, 50);
			Limiter.ar( gen * inVol );
		}
	,
	'busIn' -> {|inBus = 1, inVol2 = 1|
			var gen = InFeedback.ar(inBus);
			Limiter.ar( gen * inVol2 );
		}
	,

	'dusty' -> {|densY=10, freq=1000, decay=0.03| Ringz.ar(Dust.ar(densY), freq, decay) }
];

(
// add your own fx stuff here!
q.fx1to1 = IdentityDictionary
[



	'000_Gate' -> {|in, threshG = 0.01, attG=0.01, decG=1|
			Compander.ar(
		 		in, in,
		 		threshG, 10, 1,
		 		attG, decG
			)
	},
	'00_Comp' -> {|in, threshC = 0.3, slopLo=0.9, slopHi=0.75, volC = 1|
			Compander.ar(
		 		in, in,
		 		threshC, slopLo, slopHi,
		 		0.01, 0.05
			) * volC
	},
	'0freqBal' -> { arg in, bFreq=200, balanz=1;
		var split, lo;
		lo = LPF.ar(in, bFreq);
		split = [lo, in-lo];
		( split * [ balanz.reciprocal, balanz ] ).sum;
	}
	,
/*	'2e-guit-HP' -> { arg in, freq=55, freq2=5000, rq=0.22, gainE=1.8;
		var amp = Amplitude.kr(in[0]);
		BPF.ar(in * gainE,
			(amp.linexp(0,1, freq, freq2)).fold(20, 19000),
			rq
		)
	}
	,

	'0pitch' -> { arg in, dt=4, pRatio=2;
		dt = dt.lag(3);
		in = DelayN.ar(in, 10, dt);
		in = PitchShift.ar(in, LFNoise1.kr(1).range(0.1,0.3), pRatio);
	}
	,
*/	'0pitch' -> { arg in, dt1=4, dt2=1, dt3=1.5, pRatio1=2, pRatio2=0.5, pRatio3=0.75;
		var out = [pRatio1, pRatio2, pRatio3].collect({|piz, i|
			var dt = [dt1, dt2, dt3][i].lag(3);
			in = DelayN.ar(in, 10, dt);
			in = PitchShift.ar(in, LFNoise1.kr(1).range(0.1,0.3), piz);
		});
		SplayAz.ar(q.numChans, out);
	}
	,
	'0ring' -> { arg in, widefreq=20, modulation=0;
		SinOsc.ar(
			widefreq.lag(0.3)
			* LFDNoise3.kr(
				modulation.squared * 30 * Amplitude.kr(in),
				(15 * modulation).midiratio
			),
			0,
			in
		)
	}
	,
	'1fyrFilt' -> { |in, sens=1|
		var timer, changeTrig, rq, ffreq1, ffreq2;
		var pitch = Pitch.kr(in, median: 5);
		pitch = pitch.flop.postln[0].fold(80, 10000).lag(1/20);
		changeTrig = (HPZ1.kr(pitch.cpsmidi.round(1/sens)).abs
			> (5/sens));
		changeTrig = Trig.kr(changeTrig, SinOsc.kr(0.12).range(0.1, 2));
		timer = Timer.kr(changeTrig);
		rq = timer.expexp(0.1, 10, 1, 0.05).clip(0.01, 2).lag(1/130);
		ffreq1 = Fold.kr(pitch * 1.5, 20, 18000);
		ffreq2 = Fold.kr(pitch * timer.sqrt, 20, 18000).lag2(2);

	//	Ringz.ar(K2A.ar(changeTrig), 400, 0.1, 7) +
		RLPF.ar(in, ffreq1, rq.lag(0.5)) -
	 	RLPF.ar(in, ffreq2, rq + pi % 1.5 + 0.01)
	},
	'0ffunFilt' -> { arg in, gainE=1, attT= 1, dcyT= 2, freq= 2000, octSpan= -5, rq=0.15;
		var amp;
		amp = Amplitude.kr(in[0], attT, dcyT);
		RHPF.ar(
			in * gainE,
			(
				freq **
				( ( (amp * octSpan)+1))

			).clip(50, 9000),
			rq
		)
	}
	,
	'1envFilt' -> { arg in, steps=7, dens=0.8, length=0.7, gain=1;
		var bpm = ~bpm.kr;
		var beat = ~metroIn.ar(1, 2);
		var alle4 = ~metroIn.ar(1, 4);
		var stepPhasor = beat.madd(steps).floor;
		var triggerSteppd = HPZ1.ar((beat).madd(steps).floor).abs;

		var hashi = Hasher.ar(stepPhasor
			+ length.round(0.01)
			+ Stepper.ar(alle4)
		).abs;
		var trigger = hashi < dens * triggerSteppd;
		var env = EnvGen.ar(Env.new([0, 1, 0],
			[0.02 * length, 16*(~metroIn.ar(1, 3)*steps).reciprocal-0.0002 * length], [\sin, -3]),
			 Trig.ar(trigger, SampleDur.ir)
		).clip(0, 1);
		var filtMiddle = hashi.linexp(0, 1, 80, 8000).lag(1/100);
		var filtEnvHi = env.linexp(0, 1, 1, 8).madd(filtMiddle * 1.1).clip(20, 20000);
		var filtEnvLo = env.linexp(0, 1, 1, 1/8).madd(filtMiddle).clip(20, 20000);

		var filteredPair = in.collect({ |inch|
			RLPF.ar(inch * gain, [filtEnvHi, filtEnvLo], 0.8, [1, -1]).sum
		});
		Limiter.ar(filteredPair, 1, 0.0001)

	},
	'2DelayUD'	-> { arg in, delayTime1 = 0.52, delayTime2 = 0.75, mod=0.2, rise=2.5, fall=2;
	 	var dtKr, comb, modulator, dtActual;
	 	modulator = ( 1 - LFDNoise3.kr(mod.sqrt ! q.numChans * 4, 0.8 * mod).cubed );
		dtKr = [delayTime1, delayTime2 ].lag(1.0);
		dtActual = dtKr * modulator;

	 	comb = CombL.ar(
	 		in,
	 		5.75,
	 		dtActual,
	 		dtKr * fall,
	 		1
	 	)
	 	-
	 	CombL.ar(
	 		in,
	 		5.75,
	 		dtActual,
	 		dtKr * rise,
	 		1
	 	)
	 	;
	}
	,
	'2trem' -> { arg in, speedT=6.67, pow=0.7;
		SinOsc.ar(speedT, (0..q.numChans-1) * 2pi / q.numChans, 0.5, 0.5).pow(pow)
		* in
	}
	,
/*	'1synDr' -> { arg in, decaa=1, speedS= 1, freQmx= 5000;
		var amp = Amplitude.kr( in, 0.001, decaa );
		var lfos = [
				{ LFDNoise1.kr(speedS * Rand(0.5, 2) ) } ! 3,
				{ SinOsc.kr(speedS * Rand(0.15, 2) ) } ! 3,
				{ LFPulse.kr(speedS * Rand(0.5, 3) ) } ! 3
			].flat.scramble.postln;
		var selecta = lfos.choose;
		var sel = Select.kr(selecta.abs.linlin(0,1, 0, lfos.size-1) );

		var sig =
			Saw.ar( lfos.keep(4).abs.linexp(0, 1, 20, freQmx) ).sum
			+ LFPulse.ar( lfos.keep(4).abs.linexp(0, 1, 5, freQmx/8), 0, 0.6, [1, -1] ).sum;
		Limiter.ar(sig * amp * 3)

	}
	,*/
 	'3thrasher' -> { arg in, bit = 16, downsample= 4000, downsmod=0;
			var zin, zout;
			zin = in;
			zout = zin.round(2.pow(bit).reciprocal);
			zout = (downsample<22050) *
				Latch.ar(
					zout,
					Impulse.ar(
						downsample
						* LFDNoise1.kr(
							downsmod.cubed * 75,
							0.25, 0.75
						).abs
					)
				)
			+ (downsample >= 22050 * zout)
	}
	,
  	'0ixiDist' -> { |sig, pregain=0.048, dFreq=5000, postgain=15, dComp=0.6 |
			var sigtocomp, fx, y, z;
			sigtocomp = LPF.ar((sig * pregain).distort, dFreq, postgain, sig).distort;
			fx = Compander.ar(sigtocomp, sigtocomp, 1, dComp, 1 );
			LeakDC.ar(fx);
		}
	,
 	'4ixiVerb' -> {| in, predelay=0.048,combdecay=15, apDecay=1, ixivAmp=0.2 |
			var sig, y, z;
			sig = in;
			z = DelayN.ar(sig, 0.1, predelay, ixivAmp);
			y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), combdecay) }));
			6.do({ y = AllpassN.ar(y, 0.050, rrand(0.03, 0.05), apDecay) });
			y;
		}
	,
	'9endFilt' -> { arg in, hiCut=12000, loCut=130, laG=1;
		LPF.ar( in, loCut.lag2(laG)) -  LPF.ar( in, hiCut.lag2(laG));
	},

	// a Stereo FX; slightly reworked
		'00bufFUN' -> { arg in, newLvl=01, oldLvl=0.1, secs=1, pitch1= -2, pitch2=1, flip=1, freeze=0;
			var phaW, trans, env, sd, frams, bs, ot, lagB= 1,usedframs, offs=0, phaR;
			var buf = LocalBuf.new(10  * SampleRate.ir, 2);	// stereo!!
			ClearBuf(buf);
			frams = BufFrames.ir(buf);
			usedframs = BufSampleRate.ir(buf) * secs.max(0.0001);
			phaW = Phasor.ar(0, BufRateScale.kr(buf) * K2A.ar(1-freeze.clip(0,1)), 0, usedframs);
			phaR = Phasor.ar(0,
				BufRateScale.kr(buf) * flip.clip(-1,1)  * [pitch1, pitch2].midiratio.lag2(lagB) ,
				0, usedframs
			);
			sd = SampleDur.ir;
			bs = (SampleRate.ir / ControlRate.ir);

			ot = BufRd.ar(2, buf, 		// expands to twice stereo, thus:
				phaR % usedframs,
				1, 4
			).flop * [[1, 1], [0.001, 0.001 ]];
			ot = ot.sum;				// sum it up
			ot = Rotate2.ar(ot[0], ot[1], SinOsc.kr( (Amplitude.kr(in.first).squared * 2), 0, 3 ).wrap2(1) );

			BufWr.ar(
				(in.keep(2) * newLvl.squared.min(1).lag(0.5))
				+ (ot * oldLvl.lag(0.7).cubed),
				buf, phaW); // loop rec into the buf
			ot
	}
];

q.fx1toN = IdentityDictionary
[
	'00elefnt' ->  { arg in, newLvl= 1, oldLvl= 0, elefRate=1,
		interval = -12, pitchDrift = 0.01, lag=0.25, speed=1, density=1;

		var numVoicesPerLayer = 4;
		var numPitchLayers = 3;
		var ot, ot16;
		var bufferSize = 8  * SampleRate.ir;
		var buf = LocalBuf.new(bufferSize, 1);
		ClearBuf(buf);
		RecordBuf.ar( in.sum,
			buf, 0, newLvl.lag(0.1), oldLvl.lag(0.1), 1, 1);

		ot = { arg i;
			(PlayBuf.ar(1, buf,
				(elefRate * (i * interval).midiratio).lag(lag) * LFDNoise1.kr(0.3, pitchDrift, 1),
				startPos: Array.series(numVoicesPerLayer, 0, 1/numVoicesPerLayer) * bufferSize,
				loop: 1
			)
			* (interval * -0.5).dbamp
			)
		} ! numPitchLayers;
		ot16 = ot
			* (LFDNoise1.kr(speed ! (numPitchLayers * numVoicesPerLayer), 0.5, 0.5)
				< density).lag(lag/speed).reshapeLike(ot);
		ot16.reshapeLike( (0..7) ! 2 ).sum.postln
	},

	'0turboDLY' -> { arg in, mainDT = 3, glide=7, feedbT = 0.03, dry=1;
		var out;
		var n = (q.numChans*2).max(10); // so many taps
		var inMono = in.asArray.sum;
		var mixIn = Limiter.ar((LocalIn.ar(1) * feedbT) + inMono);
		var modz = { SinOsc.kr(
				LFNoise1.kr(1/30).exprange(0.2, 3),
				Rand(0,2pi),
				0.75,
				0.25
			)
		} ! n;
		var trigz = modz + 0.05 + Impulse.kr(0) > 0;
		var dts = (mainDT ).lag2(glide) * (TRand.kr(0.1, 1, trigz ) + 0.1);
// no Filtering, for OEROL..
//			var ffreqs = TExpRand.ar(50, 9000, trigz).trunc + 70;
//			var dly = DelayL.ar(mixIn * modz.clip(0, 1), 6, dts);    // nice lil clicky..
		var dly = DelayL.ar(mixIn, 6, dts, modz.clip(0, 1));
		var fltSnd = dly; //BPF.ar(dly, ffreqs, 1.8);
		var summ = LeakDC.ar(fltSnd.sum);
		LocalOut.ar(summ);
		out = SplayAz.ar(q.numChans, fltSnd);
		OnePole.ar(out, 0.8)
		+ inMono.asArray.wrapExtend(q.numChans).madd(dry);
	}
	,
	'5HArev12' -> { arg in, revDecay=3, revTime=0.5, modulation=0.1;
		var zin, zout, env, lag = 0.5;

		revTime = revTime.lag(lag)*0.5;
		revDecay = revDecay.lag(lag);
		modulation = modulation.lag(lag).squared * 3 + Line.kr(1,0,0.01);
		zin = in;
		zout = zin;
		12.do({
			zout = AllpassL.ar(
 				Rotate2.ar(zout[0], zout[1], {Rand(-0.6, 0.6)}),
//				zout, //.rotate(1);
				0.08,
				{Rand(0.001,0.1)}.dup * LFDNoise1.kr(modulation, revTime, revTime),
				revDecay
			)
		});
		HPF.ar( zout, 80) + in.dup(q.numChans);
	}
	,
	'3phaserSt' -> {|in, speed=0.2, rand=0, depth=0.1|
		var mods, ch, maxdt = 0.1, clocks, lpfs, dlys, lpr=1/3;
		speed = speed.lag(1) / (2.01 ** (0..3));
		speed = speed *  LFNoise2.kr(1/10 ! 4).abs.madd(rand, 1);
		clocks = LFPulse.kr(speed + 1 );
		lpfs = Lag2.kr(clocks, lpr / speed).madd(depth.lag(0.4));
		ch = DelayC.ar(in, maxdt, maxdt * lpfs);
		Splay.ar(ch.rotate(1));
	}
	,
	'2chorusSt' -> { |in, speed=0.75, depth=0.01, distanc=0.0|
		var maxDt = 0.5;
		var d = DelayC.ar(in, maxDt,
			({
				SinOsc.kr(speed * ExpRand(0.9, 1.1), Rand(0,pi)).range(0, 0.5)
				+ LFDNoise3.kr(speed).range(0, 0.5)
				* depth.lag(0.5)
				+ (Rand(0.0, 1) * distanc.lag(0.5) )
			} ! 12
			* maxDt
		));
		OnePole.ar(
			OnePole.ar(
				Splay.ar(d) + in.sum.dup,
				0.8
			),
			-0.8, 5
		)

	 }
	,'2dlys' -> { arg in, dlytime=0.1, glide=1;
		var insnd = (in.asArray.sum);
		var dlysnd = DelayL.ar(insnd, 20, (1 .. q.numChans)/q.numChans * dlytime.lag2(glide));
		dlysnd
	}
	,
	'3dlys-Feedb' -> { arg in, dlytime=0.1, feedb = 0.1, glide=4;
		var feedbacksnd = LocalIn.ar(1) * feedb;
		var insnd = (in.asArray.sum + feedbacksnd );
		var dlysnd = DelayL.ar(insnd, 20, (1 .. q.numChans) /q.numChans * dlytime.lag2(glide));
		LocalOut.ar(dlysnd.last);
		dlysnd.reverse
	}
	,
	'1waber'-> { | in, widthW=0.0, speedW=0.01, lagW=10|
		var maxdt = 0.4;
		widthW = widthW.lag3(lagW) * maxdt;
		DelayC.ar(
			in.asArray.sum,
			maxdt,
			LFDNoise3.kr(speedW ! q.numChans).abs.madd(widthW)
		);
	},
	'0springPan' -> { arg in, speedA=0.05, pAN=0,  shape = 1, widthA=2;
		var excurs = speedA > 0 * 3;
		var mod = SinOsc.kr(speedA).pow(shape).madd(excurs, pAN.lag(0.2));
		PanAz.ar(q.numChans+1, in.asArray.sum, mod, 1, widthA).drop(-1)

	}
];


q.fxNtoN = IdentityDictionary
[
	'3_reson' -> { arg in, speedR=0.1, minfreq=440, maxfreq=7000, resonance=0.01;
 		var fmod = SinOsc.kr(speedR, (1..q.numChans) /q.numChans * 2pi ).exprange(minfreq, maxfreq);
		var zout = Ringz.ar(in, fmod, resonance);
		HPF.ar( zout * 0.25, 80)
	}
	,
	'6_filtu' -> { arg in, speedR=0.1, minfreq=440, maxfreq=7000, reso=0.1;
 		var fmod = VarSaw.kr(speedR, (1..q.numChans).scramble /q.numChans, {Rand(0.2,0.8)}!q.numChans ).distort.exprange(minfreq, maxfreq);
		BPF.ar(in, fmod, reso, reso.reciprocal.pow(0.2) + 1);
	},

	'9_ampFin' -> { arg in, ampFin=1;   Limiter.ar(in, 1) * ampFin.lag(0.5) };
];

);


////////init//////////////////////////////////////////////////////////////////////
////////init//////////////////////////////////////////////////////////////////////

Spec.add( \volC -> ControlSpec(0.0, 25, \amp));
Spec.add( \volG -> ControlSpec(0.0, 25, \amp));
Spec.add( \inVol -> ControlSpec(0.0, 25, \amp));
Spec.add( \inVol2 , \inVol.asSpec);
Spec.add( \thresh, [0.000001, 1, \exp]);
Spec.add( \threshG, [0, 1, 3]);
Spec.add( \threshC -> ControlSpec(0.000001, 1, \exp));
Spec.add( \pbRate -> ControlSpec(-2, 4, \lin));
Spec.add( \laG -> ControlSpec(0.01, 40, \exp));
Spec.add( \mmGain -> ControlSpec(0, 10, \lin));
Spec.add( \gainE -> ControlSpec(0, 5, \amp));

Spec.add(\freQmx, \widefreq.asSpec);
Spec.add(\speedS, [0.001, 50, \exp]);
Spec.add(\decaa, [0.001, 3, \exp]);
Spec.add(\rand, \amp.asSpec);
Spec.add(\depth, [0, 1, 5]);
Spec.add(\distanc, \amp.asSpec);
Spec.add(\max, [0, 0.5, \lin].asSpec);
Spec.add(\speed, [1/120, 60, \exp].asSpec);

Spec.add(\inChan2, [0, 7, \lin, 1]);
Spec.add(\inBus, [1, 256, \lin, 1]);
Spec.add(\densY, [0.2, 200, \exp]);
Spec.add(\decay, [0.002, 1, \exp]);
Spec.add(\freq2, \freq.asSpec);
Spec.add(\speedT, [0.01, 120, \exp]);

Spec.add( \ampFin -> [0, 4, \lin].asSpec);
Spec.add( \inAmp -> \gain.asSpec);
Spec.add( \slopLo -> ControlSpec(1/10, 10, \exp, 0.0));
Spec.add( \slopHi -> ControlSpec(1/10, 10, \exp, 0.0));
Spec.add( \loCut, [20, 19990, \exp, 0.0]);
Spec.add( \hiCut, \slopLo.asSpec);
Spec.add( \balanz -> ControlSpec(1/30, 30, \exp, 0.0));

Spec.add( \shape -> ControlSpec(1/4, 4, \exp, 0.0));
Spec.add( \widthA -> ControlSpec(1/10, 5, \exp, 0.0));
Spec.add( \speedA -> ControlSpec(0, 1, 5, 0.0));
Spec.add(\pAN, [-0.5, 0.5, 0]);
Spec.add(\spread, [0, 2, \lin, 0.1]);
Spec.add(\bufnum, [0, 32, 0, 1]);
Spec.add(\freeze, [0, 1, 0, 1]);

Spec.add( \reso -> ControlSpec(2, 0.01, \exp, 0.0));
Spec.add( \resonance -> ControlSpec(1/10000, 0.5, \amp, 0.0));
Spec.add( \speedR -> ControlSpec(1/1000, 12, \exp, 0.0));
Spec.add( \minfreq -> \freq.asSpec);
Spec.add( \maxfreq -> \freq.asSpec);

Spec.add( \dlytime -> ControlSpec(1/10000, 20, \exp, 0.0));
Spec.add( \feedb -> ControlSpec(0, 1.5, \amp, 0.0));
Spec.add( \glide -> ControlSpec(1/50, 40, \exp, 0.0));
Spec.add(\mainDT, [0, 6]);
Spec.add(\feedbT, [0, 1.3, \amp]);

Spec.add( \lagW -> ControlSpec(0.01, 30, \exp, 0.0));
Spec.add( \speedW -> ControlSpec(0.0001, 4, \exp, 0.0));
Spec.add( \widthW -> ControlSpec(0.0, 1, \lin, 0.0));


Spec.add( \gainL -> ControlSpec(0.1, 10, \exp));
Spec.add( \gainR -> ControlSpec(0.1, 10, \exp));
Spec.add( \hifreq -> ControlSpec(600, 19000, \exp));
Spec.add( \lowfreq -> ControlSpec(10, 500, \exp));
Spec.add( \freqSpan -> ControlSpec(10, 7000, \exp));
Spec.add( \octSpan, [-8, 8, \lin]);

Spec.add( \wetRev -> ControlSpec(0, 1, \lin));
Spec.add( \feedback -> ControlSpec(1, 100, \exp));
Spec.add( \rise -> ControlSpec(1, 100, \exp));
Spec.add( \fall -> ControlSpec(1, 100, \exp));
Spec.add( \delayTime1 -> ControlSpec(0.005, 5.75, \exp));
Spec.add( \delayTime2 -> ControlSpec(0.005, 5.75, \exp));
Spec.add( \mod -> ControlSpec(0, 1, \lin));

Spec.add( \revTime -> ControlSpec(0.05, 1, \exp));
Spec.add( \revDecay -> ControlSpec(0.001, 10, \exp));
Spec.add( \modulation -> ControlSpec(0, 1, \lin));

Spec.add( \bit -> ControlSpec(16, 2, \lin, 1));
Spec.add( \downsmod -> ControlSpec(0, 1, \lin));
Spec.add( \downsample -> ControlSpec(44100/2, 100, \lin));

Spec.add( \dComp, [1, 0, \amp]);
Spec.add( \dry, \amp.asSpec);
Spec.add( \dFreq -> \freq.asSpec);
Spec.add( \pregain -> ControlSpec(0.01, 20, \linear));
Spec.add( \postgain -> ControlSpec(0.01, 20, \linear));

Spec.add( \attG -> \amp.asSpec);
Spec.add( \decG -> \amp.asSpec);
Spec.add( \combScale -> \amp.asSpec);
Spec.add( \apScale -> \amp.asSpec);
Spec.add( \predelay -> [0.0001, 0.2, \linear]);

Spec.add( \revDcy -> ControlSpec(0.01, 12, \linear, 0, 1));
Spec.add( \apDecay -> ControlSpec(0.01, 12, \linear, 0, 1));
Spec.add( \combdecay -> ControlSpec(0.1, 15, \linear, 0, 15));
Spec.add( \ixivAmp -> \amp.asSpec);
Spec.add( \bFreq -> \freq.asSpec);

Spec.add( \pFreq -> \freq.asSpec);
Spec.add( \pDb -> ControlSpec(-60, 32, \linear, 0, 1));
Spec.add( \pRq -> \rq.asSpec);

Spec.add( \pow -> ControlSpec(8, 1/8, \exp));
Spec.add( \attT, [0.001, 5, \exp]);
Spec.add( \dcyT, [0.001, 5, \exp]);

Spec.add( \pRatio, [0.001, 4, \lin]);
Spec.add( \pRatio1, [0.001, 4, \lin]);
Spec.add( \pRatio2, [0.001, 4, \lin]);
Spec.add( \pRatio3, [0.001, 4, \lin]);
Spec.add( \dt, [0.0, 10, \lin]);
Spec.add( \dt1, [0.0, 10, \lin]);
Spec.add( \dt2, [0.0, 10, \lin]);
Spec.add( \dt3, [0.0, 10, \lin]);

Spec.add( \density, \amp);
Spec.add( \newLvl, \amp);
Spec.add( \oldLvl, [0, 1.1, \amp, 0, 1]);
Spec.add( \elefRate, [-2, 4]);
Spec.add( \interval, [-24, 24, 0, 0.5]);
Spec.add( \pitchDrift, [0, 2, 3]);
Spec.add( \secs, [0, 10]);
Spec.add( \pitch1, [-24, 24, 0, 0.5]);
Spec.add( \pitch2, \pitch1);
Spec.add( \flip, [-1, 1, 0, 1]);
Spec.add(\dens, \unipolar);
Spec.add(\length, [0.005, 1.995, \lin]);
Spec.add( \steps, [2, 32, \exp, 1]);
Spec.add( \which, [0, 3, \lin, 1]);


////////CHAININ//////////////////////////////////////////////////////////////////////
////////CHAININ//////////////////////////////////////////////////////////////////////
////////CHAININ//////////////////////////////////////////////////////////////////////
////////CHAININ//////////////////////////////////////////////////////////////////////



q.generatorsLibrary.keysValuesDo { |key, func|
	ProxyChain.add(key, \mix -> func);
};

q.fx1to1.keysValuesDo { |key, func|
	ProxyChain.add(key, \filter -> func);
};

q.fx1toN.keysValuesDo { |key, func|
	ProxyChain.add(key, \filter -> func);
};

q.fxNtoN.keysValuesDo { |key, func|
	ProxyChain.add(key, \filter -> func);
};

q.genNames = q.generatorsLibrary.keys.asArray.sort;
q.filterNames = [q.fx1to1, q.fx1toN, q.fxNtoN].collect { |dict| dict.keys.asArray.sort; };



	// changed from here on:

q.makeChainGui = { |ev, pxChain, chainName, i|

	var guiname = (chainName ++ "gui").asSymbol;
	var wet2Hide, gui;
		// ugly, legalise later.
 	var panicfunc = {
 		gui.buttons.do(_.valueAction_(0));
 		pxChain.slotsInUse.asArray.do( pxChain.remove(_) );
 		pxChain.add('9_ampFin', 1);

 	};

	q.pxChain[guiname] = gui = pxChain.gui(50,
		[[ 'generators', \label ]]
		++ q.genNames.collect({ |fname| [fname, \slotCtl] })
		++ [[ 'fx1to1', \label ]]
		++ q.filterNames[0].collect({ |fname| [fname, \slotCtl] })
		++ [[ 'fx1toN', \label ]]
		++ q.filterNames[1].collect({ |fname| [fname, \slotCtl] })
		++ [[ 'fxNtoN', \label ]]
		++ q.filterNames[2].drop(-1).collect({ |fname| [fname, \slotCtl] })
		++ [['!! <ampFinal> !!', \extra, { pxChain.add('9_ampFin', 1); }]]
		++ [['!!Panic Reset!!', \extra, { panicfunc.value; }]]

	);

	gui.parent.bounds_(gui.parent.bounds.moveTo(i * 540 + 360, 330));
	gui.parent.name_(chainName.asString);
		// HIDE ampFin wet level, well not TOOO important !
//	wet2Hide = gui.editGui.replaceKeys.findKeyForValue('9_ampFin');
//	gui.editGui.ignoreKeys_([wet2Hide]);

};


q.pxChain = (); 	// keep them here by name
q.numPlayers.do { |i|
	var name = ("awunaFX" ++ i).asSymbol;

	var px = p[name];
	px.ar(q.numChans);

	px.fadeTime = 2.0;
//	px.set(\bufnum, i+1);

	q.pxChain[name] = ProxyChain.from(px, q.genNames ++ q.filterNames.flat);
	q.pxChain[name].add('9_ampFin', 1);
	q.pxChain[name].add('audioIn', 1);

	q.pxChain[name].add('000_Gate', 1);
	q.pxChain[name].add('1fyrFilt', 0.25);
	q.pxChain[name].add('3phaserSt', 0.9);

	q.makeChainGui(q.pxChain[name], name, i);
	px.play(vol:0);
};
);
///////end init//////////////////////////////////////////////////////////////////////

/** wenn kaputt gegangen:

q.makeChainGui(q.pxChain[\wunaFX0], \wunaFX0, 0);


q.pxChain.awunaFX0gui.parent.name_("fer")
q.pxChain.awunaFX0gui.dump
**/
// _________________________ ______________________________________