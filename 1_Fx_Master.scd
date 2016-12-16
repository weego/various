/*
// git version unifying everything from all Master FX i ever had :)

ToDo:
- ServerOptions -- turboDelay blows up...

dependencies:
Ndef(\metroIn) 	( 19MURF )
Ndef(\bpm)		( 2DelaySt, 5RHPF )

ToDo Pauls:
- Master Channel management:
- mix all / keep split
- open indiv. chans (or better on mixer?!)

test sound:
Server.killAll;
s.boot;
Ndef(\nois, {PinkNoise.ar(0.2! 2)}).play;
Ndef(\pulzes, { [Pulse, LFTri, SinOsc, Blip].collect(_.ar( ExpRand(5, 800) )).scramble.pow(0.25).product.dup * 2 }).play;
Ndef(\pulzes).gui;
*/

// MC fine tweaked 2014 for Sakra Pauls

q=q?();
q.mfx = q.mfx ? ();
q.numChans = q.numChans ? 2;


// tempo dependencies //
if( Ndef(\bpm).source.isNil  ){ Ndef(\bpm, {|bpm=80| bpm })  };
Ndef(\bpm).set(\bpm, rrand(50, 130).postcln );

if( Ndef(\metroIn).source.isNil  ){
	Ndef(\metroIn, {|bpm=80| Impulse.kr(Ndef(\bpm).kr/60 * 2*[2,1,0.5, 0.25, 0.125]) })
};
(
// and specs for them fof gui control.
600.do{|i| Spec.add( ("wet" ++ i).asSymbol, \unipolar); };
600.do{|i| Spec.add( ("mix" ++ i).asSymbol, \unipolar); };
Spec.add(\speeD, [4, 0, 0, 1]);
Spec.add(\inChan, [0, 8, 0, 1]);
Spec.add( \level, [0, 20, 5]);
Spec.add( \llag, [0, 600, 8]);
Spec.add( \rLag, \llag);
Spec.add( \rSpeed, [0, 14, 5, 0.0]);
Spec.add( \coeff, [0, 0.99999, -7.5, 0.00001]);
Spec.add( \balnZ, [1/12, 12, \exp, 0, 0]);
Spec.add( \inGain, [0, 25, 6]);
Spec.add( \thresh, [0.000001, 1, \exp]);
Spec.add( \mmGain, [0, 10, \lin]);
Spec.add( \ampFIN, [0, 10, \amp, 0, 1]);
Spec.add( \gain, [1/100, 5, \amp, 0, 1]);
Spec.add(\noisefloor, \amp);
Spec.add(\limDrive, \ampx4);
Spec.add(\ampLimit, \amp);
Spec.add(\postAmp, \ampx4);
Spec.add( \inAmp, \gain);
Spec.add( \thresh, \amp);
Spec.add( \threshG, \amp);
Spec.add( \slopLo, [1/10, 10, \exp, 0.0]);
Spec.add( \slopHi, [1/10, 10, \exp, 0.0]);
Spec.add( \loCut, \freq);

Spec.add( \lowCut, \freq);
Spec.add( \higCut, \freq);
Spec.add( \midFr, [40, 12000, \exp, 1]);
Spec.add( \midDB, [-20, 20]);
Spec.add( \drive, [1, 5, \exp]);
Spec.add( \patt, [0, 36, \lin, 1]);

Spec.add( \gainL, [0.1, 10, \exp]);
Spec.add( \gainR, [0.1, 10, \exp]);
Spec.add( \hifreq, [600, 19000, \exp]);
Spec.add( \lowfreq, [10, 500, \exp]);
Spec.add( \freqSpan, [10, 7000, \exp]);
Spec.add( \octSpan, [-8, 8, \lin]);
Spec.add( \ffFrq, [10, 19000, \exp]);
Spec.add( \wetRev, [0, 1, \lin]);
Spec.add( \feedback, [1, 100, \exp, 0.1]);
Spec.add( \delayTime1, [0.005, 6, \exp]);
Spec.add( \delayTime2, [0.005, 6, \exp]);
Spec.add( \mod, [0, 1, \lin]);
Spec.add( \revTime, [0.05, 1, \exp]);
Spec.add( \revDecay, [0.001, 10, \exp]);
Spec.add( \modulation, [0, 1, \lin]);
Spec.add( \modulatie, [0, 1, \lin]);
Spec.add( \modulaNon, [0, 1, \lin]);
Spec.add( \bit, [16, 2, \lin, 1]);
Spec.add( \downsmod, [0, 1, \lin]);
Spec.add( \downsample, [44100/2, 100, \lin]);
Spec.add( \dAmp, \amp);
Spec.add( \dFreq, \freq);
Spec.add( \pregain, [0.01, 20, \linear]);
Spec.add( \postgain, [0.01, 20, \linear]);
Spec.add( \combScale, \amp);
Spec.add( \apScale, \amp);
Spec.add( \predelay, [0.0001, 1, \linear]);
Spec.add( \revDcy, [0.01, 12, \linear, 0, 1]);
Spec.add( \apDecay, [0.01, 12, \linear, 0, 1]);
Spec.add( \combdecay, [0.1, 15, \linear, 0, 15]);
Spec.add( \ixivAmp, \amp);
Spec.add( \bFreq, \freq);
Spec.add( \pFreq, \freq);
Spec.add( \pDb, [-60, 32, \linear, 0, 1]);
Spec.add( \pRq, \rq);
Spec.add( \loSlop, [1, 0.0, \linear, 0, 1]);
Spec.add( \rqL, \rq);
Spec.add( \rqH, \rq);
Spec.add( \modL, \unipolar);
Spec.add( \monomix, \unipolar);
Spec.add( \modH, [0, 32, 5, 1/1000]);
Spec.add( \freqL, \freq);
Spec.add( \freqH, \freq);
Spec.add( \ampC, \gain);
Spec.add( \op, [0.95, 0.5, 1]);
Spec.add( \lpfreq, \freq);
Spec.add( \lagW, [0.01, 30, \exp, 0.0]);
Spec.add( \speedW, [0.0001, 4, \exp, 0.0]);
Spec.add( \widthW, [0.0, 0.5, 4]);
Spec.add( \spreadX, [1.01, 5.0, \exp, 0.0]);
Spec.add(\gainX, \gain);
Spec.add( \rotWh, [0, 100, 5, 0.01]);
Spec.add( \ampWh, [0.01, 100, \exp, 0.0]);
Spec.add( \ampExp, [0.1, 10, \exp, 0.0]);
Spec.add( \lagWheel, [0.1, 120, \exp, 0.1]);
Spec.add( \dimension, [0, 120, 6, 0.0]);
Spec.add( \slewU, [0, 24000, 4]);
Spec.add( \slewD, [0, 24000, 4]);
Spec.add( \miX, \pan);
Spec.add( \fftGain, \amp);
Spec.add(\xFreq, \freq);
Spec.add(\loGain, [0, 10, \amp, 0, 1]);
Spec.add(\hiGain, [0, 10, \amp, 0, 1]);
Spec.add(\compRatio, [1, 10, \exp, 0.1, 3]);
Spec.add(\hSpeed , [0, 40, 5]);
Spec.add(\indiv, \amp);
Spec.add(\oct, [-8, 8, \lin, 1]);
Spec.add(\width, \unipolar);
Spec.add(\mainDT, [0, 6, 3]);
Spec.add(\glide, [0, 30, 5]);
Spec.add(\feedbT, [0, 10, 3]);
// RevFB
Spec.add(\feedbackR, [0, 0.5, \amp]);
Spec.add(\animRate, [0.01, 100, \exp]);
Spec.add(\animDepth, [0.0, 1, \amp]);
Spec.add(\hfDamping, [0, 1]);
Spec.add(\predelay, [0.0, 0.2, \amp]);
Spec.add(\revTime, [0.01, 100, \exp]);
Spec.add(\inFilter, [-0.99, 0.99]);
Spec.add(\leakCoeff, [0.9, 0.998]);
Spec.add(\combScale, [0.1, 2, \exp]);
Spec.add(\apScale, [0.1, 2, \exp]);
Spec.add(\direct, \amp);
);
(
// add your own fx stuff here!
q.mfx.fx = IdentityDictionary
[
	'00_in' -> { arg in, level=1, llag=0.2, noisefloor=0.001;
		LeakDC.ar(in * level.lag(llag) )
		+ BrownNoise.ar(0.001).madd(noisefloor ! q.numChans);
	}
	,
	'0_DBComp' -> {	 arg in, xFreq=350, thresh=0.5, loGain=2, hiGain=0.5, compRatio=2;
		DualBandComp.ar(
			in,
			xFreq, loGain,  hiGain, thresh, compRatio
		)
	}
	,
	'0_comp' -> { arg in, thresh=0.5, slopLo=0.9, slopHi=0.5;
		Compander.ar(
			in, in,
			thresh, slopLo, slopHi,
			0.03, 0.05
		)
	}
	,
	'0_gate' -> {|in, threshG = 0.03, attG=0.01, decG=1|
		Compander.ar(
			in, in,
			threshG, 10, 1,
			attG, decG
		)
	}
	,
	'0freqBal' -> { arg in, bFreq=200, pan=0;
		var split, lo;
		pan = LinExp.kr(pan, -1,1, 1/20,20);
		lo = LPF.ar(in, bFreq);
		split = [lo, in-lo] * [ pan.reciprocal, pan ];
		split.sum;
	}
	,
	'0fft_Mess' -> { arg signal, fftGain=0.1;
		signal = signal.asArray.collect({|chan, i|
			var signal = FFT(LocalBuf(2**10), chan);
			signal = PV_MagSquared(signal);
			signal = PV_LocalMax(signal, 31);
			signal = IFFT(signal);
		});
		signal * (fftGain);
	}
	,

	'0OnePolBal' -> { arg in, coeff= 0.6, balnZ = 0.5;
		var split, lo;
		lo = OnePole.ar(in, coeff);
		split = [lo, in-lo] * [ balnZ.reciprocal, balnZ ];
		split.sum;
	}
	,
	'0_par_EQ' -> { arg in, pFreq=90, pRq=0.9, pDb=5;
		BPF.ar(in, pFreq, pRq, pDb.dbamp) + in
	}
	,
	'1shift' -> { arg in;
		FreqShift.ar(
			in,
			MouseY.kr(9000, 0.1, \exponential),
			Blip.kr(
				MouseX.kr.range(-3,3).cubed,
				12
			).madd(2pi)
		)
	}
	,
	'1ring' -> { arg in, widefreq=20, modulation=0;
		SinOsc.ar(
			widefreq.lag(0.3)
			* LFDNoise3.kr(
				modulation.squared ! q.numChans
				* 30
				* (Amplitude.kr(in)),
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
		pitch = pitch.flop[0].fold(80, 10000).lag(1/20);
		changeTrig = (HPZ1.kr(pitch.cpsmidi.round(1/sens)).abs
			> (5/sens));
		changeTrig = Trig.kr(changeTrig, SinOsc.kr(0.12).range(0.1, 2));
		timer = Timer.kr(changeTrig);
		rq = timer.expexp(0.1, 10, 1, 0.05).clip(0.01, 2).lag(1/130);
		ffreq1 = Fold.kr(pitch * 1.5, 20, 18000);
		ffreq2 = Fold.kr(pitch * timer.sqrt, 20, 18000).lag2(2);

		RLPF.ar(in, ffreq1, rq.lag(0.5)) -
		RLPF.ar(in, ffreq2, rq + pi % 1.5 + 0.01)
	},
	'1sluu' -> {arg in, slewU = 400, slewD = 9000, miX=0;
		var sl = Slew.ar(in, slewU, slewD);
		XFade2.ar(sl, in-sl, miX)
	}
	,

	'19MURF' -> { | in, rq= 0.2, drive = 2, gain=1, speeD=2, patt =0|
		var bands = [200, 300, 450, 675, 1000, 1500, 2200, 3400];
		var numBands = bands.size;
		var insm = in * Line.kr(0,1,0.01);
		var filts = insm.collect({ |chan,i|
			var pipe = BPF.ar(chan, bands, rq);
			pipe = pipe.madd(drive).distort;
			MoogFF.ar(pipe * Line.kr(0,1,0.01), bands, gain) * 6;
		}).flop;
		var metro16 =   Ndef(\metroIn).kr(1, speeD);
		var metro025 =  Ndef(\metroIn).kr(1, (speeD+2).max(4));
		var vary =  TIRand.kr(0, 3, metro025).madd(pi);
		var steps = Stepper.kr(  metro16  );
		var restep = (
			Hasher.kr(steps + vary + patt.madd(0.1) ) % 1 * numBands
		).trunc;
		var steppd = Select.ar(restep, filts);
		steppd;
	},

	'2DelaySt'	-> { arg in, delayTime1 = 1, delayTime2 = 0.76, mod=0.66, feedback=3;
		var dtKr, comb, tempo;
		tempo = 15 / Ndef(\bpm).kr;   // quarter tempo..
		dtKr = [delayTime1, delayTime2 ].lag(1.0);
		comb = CombL.ar(
			HPF.ar(in, 200),
			6,
			dtKr * ( 1 - LFDNoise3.kr(mod.sqrt!2 * 4, 0.8 * mod).cubed ),
			dtKr * feedback,
			0.8
		);

		Rotate2.ar(comb[0], comb[1], SinOsc.kr(0.025)) + in;
	}
	,
	'2revFB'	-> { |in, feedbackR = 0.025, revTime = 3, animRate = 0.3, animDepth = 0.3,
		hfDamping = 0.1, predelay = 0.02, inFilter = 0.6,
		leakCoeff = 0.995, combScale = 1, direct = 0.2|
		var fbIn = LocalIn.ar(1);
		// all in is mono mixed:     1>n FX !!
		var fb = Limiter.ar(
			(fbIn * feedbackR)
			+ in.sum
			+ (PinkNoise.ar(0.0001) + Dust2.ar(2, 0.01))
		);
		var snd = AdCVerb2.ar(fb,
			nOuts: q.numChans,         // fixed number of decorrelated output channels
			animRate: animRate.lag(0.5),
			animDepth: animDepth.lag(0.5),
			revTime: revTime.lag(0.5),
			hfDamping: hfDamping.lag(0.5),
			predelay: predelay.lag(0.5),
			numCombs:     8,     // fixed number - increase for more density
			numAllpasses: 4,     // fixed number - increase for more diffuseness
			inFilter: inFilter,
			leakCoeff: leakCoeff,
			combScale: combScale.lag2(5)
		) + (in * direct);

		// round off highs somewhat
		// maybe resurrect DualBandComp?
		var out = OnePole.ar(snd.softclip, 0.4);
		LocalOut.ar(out.mean);
		out
	},
	'0turboDLY' -> { arg in, mainDT = 3, glide=7, feedbT = 0.1, dry=1;
		var out;
		var n = (q.numChans*2).max(10); // so many taps
		var inMono = in.asArray.mean;
		var mixIn = Limiter.ar((LocalIn.ar(1) * feedbT) + inMono) * 8;
		var modz = { SinOsc.kr(
			LFNoise1.kr(1/30).exprange(0.2, 3),
			Rand(0,2pi),
			0.75,
			0.25
		)
		} ! n;
		var trigz = modz + 0.1 + Impulse.kr(0) > 0;
		var dts = mainDT.lag2(glide) * (TRand.kr(0.1, 1, trigz ) + 0.001);
		var dly = DelayL.ar(mixIn, 3, dts, modz.clip(0, 1));

		LocalOut.ar(LeakDC.ar(dly.mean));

		out = SplayAz.ar(q.numChans, dly);
		OnePole.ar(out, 0.7) + in.madd(dry);
	}
	,


	'5RHPF'	-> { arg in, freqH = 400, modH =0.5, rqH =0.75;
		var fr, seq, tempo;
		tempo = Ndef(\bpm).kr / 60;   // quarter tempo..
		fr = SinOsc.kr((modH * tempo), [0, 0.4]).pow(Rand(0.7,1.4)).exprange(0.5, 3).madd(freqH).fold(20, 19000);
		RHPF.ar(in, fr, rqH)
	}
	,

	'5RLPF'	-> { arg in, freqL = 4000, modL = 0.6, rqL = 0.5; var fr;

		fr = (freqL
			+ LFDNoise3.kr(
				Amplitude.kr(in).sqrt
				* modL.cubed
				* 20
				! q.numChans
			).exprange(1/3, 3)
			.madd(freqL * modL)
		).cpsmidi.round(2).fold(15, 133).midicps;

		RLPF.ar(in, fr, rqL )
	},

	'3funFilt' -> { arg in, gain=1, att=0.01, dcy=0.75, ffFrq= 5000, octSpan= -5, rq=0.7;
		var amp;
		in = in * gain;
		amp = Amplitude.ar(in, att, dcy); // was: AmplitudeMod
		RHPF.ar(in,
			(ffFrq * (amp * octSpan * 12).midiratio).fold(20, 19000),
			rq
		)
	}
	,
	'3ParF' -> { arg in, spreadX=2, gainX=1, pitpit=0;
		var pix, l, r, freqs, amp, verso;
		in = in * gainX;
		amp = Amplitude.kr(in, 0.01, 0.2);
		pix = Pitch.kr(in).lag(0.01, 0.5);
		verso = pitpit.clip(0,1).madd(2, -1) * (pix[1] - 0.5) * [1, -1] + 0.5;
		freqs = (
			(pix[0] * verso[0])
			+ (amp.linexp(0, 1, 5000, 80).madd(verso[1]))
			* [spreadX.reciprocal, spreadX]
		).fold(20, 19000);


		l = LPF.ar(in[0], freqs).madd([1, -1]).sum;
		r = LPF.ar(in[1], freqs).madd([1, -1]).sum;
		[l,r]
	}
	,
	/* 	'3AdCVerb' -> {| in, predelay=0.048, revTime=3, combScale=1, apScale=1, mod=0.05 |
	var sig, y, z;
	AdCVerb.ar( in, revTime, LFNoise1.kr(0.2!2,0.1*mod, 0.11),  2, predelay,
	8, 4, 0.6, combScale = 1, apScale = 1);

	}
	,
	*/
	'3thrasher' -> { arg in, bit = 7, downsample= 6000, downsmod=0.75;
		var zin, zout;
		zin = in;
		zout = zin.round(2.pow(bit).reciprocal);
		zout = downsample<22050 *
		Latch.ar(
			zout,
			Impulse.ar(
				downsample
				* LFDNoise1.kr(
					downsmod.cubed * 75 ! 2,
					0.25, 0.75
				).abs
			)
		)
		+ (downsample >= 22050 * zout)
	}
	,
	'1ixiDist' -> { |in, pregain=2, dFreq= 4000, postgain=1, loSlop=0.6 |
		var sig, sigtocomp, fx, y, z;
		sig = in;
		sigtocomp = LPF.ar((sig * pregain).distort, dFreq, postgain).distort;
		fx = Compander.ar(sigtocomp, sigtocomp, 1, loSlop, 1 );
		LeakDC.ar(fx, mul: 0.5 );
	}
	,
	'5Hreveb' -> { arg in, revTime=0.6, revDecay=0.05, modulatie=0.7;
		var zin, zout, env, lag = 0.5;

		revTime = revTime.lag(lag)*0.5;
		revDecay = revDecay.lag(lag);
		modulatie = modulatie.lag(lag).squared * 3;
		zin = HPF.ar(in, 100);
		zout = zin;
		10.do({
			zout = AllpassL.ar(
				Rotate2.ar(zout[0], zout[1], {Rand(-0.3, 0.9)}).neg,
				0.3,
				{Rand(0.001,0.3)}.dup(q.numChans)
				* LFDNoise1.kr(modulatie,revTime,revTime),
				revDecay
			)
		});
		LeakDC.ar( zout, 0.9 ) + in;
	},

	'6noone' -> { arg in, revDecay=3, revTime=0.5, modulaNon=0.01, ampC=0.5, op=0.7, lpfreq= 2000;
		var zin, zout, env, lag = 0.5, seq, fr, mousex, n=4;

		revTime = revTime * 0.5;
		revDecay = revDecay.lag(lag);
		op=op;
		mousex = MouseStrum.kr((1 .. (n)) / (n+1), \x, 0).sum;
		seq = Drand( [Dseq([0, -7, 0, 12, 0, -12, -4, -7, -24, 0, 2], 1), Drand({Rand(-0.0, -12)}, 3)], inf);
		fr = Demand.ar( K2A.ar((mousex.sum)), 0, seq.midiratio);

		modulaNon = modulaNon.squared + Line.kr(1, 0, 0.01);
		zin = in * ampC * (1 - LFNoise1.kr(0.1 ! q.numChans).squared);
		zout = zin;
		3.do({|i|
			zout = CombL.ar(
				OnePole.ar(HPF.ar(zout, ExpRand(80, 120.0)), op),
				0.2,
				(	{Rand(0.01, 0.2)}.dup(q.numChans)
					* LFDNoise1.kr(modulaNon, revTime, revTime+0.001)
					* [fr, fr.madd(0.501), fr.madd(1.33)].rotate(i)
				),
				revDecay
			).postcln
		});
		zout = LPF.ar(zout, lpfreq);
		Limiter.ar(zout).postcln; //.clump(q.numChans).sum;
	},

	'7roto' -> { arg in, rSpeed = 0.02, rLag=5;
		var sins, n = q.numChans;
		sins = LFSaw.ar(rSpeed.lag(rLag), 0, 1, (1..n)-1*2/n * 0.67 );
		({ arg i; PanAz.ar(n, in[i], sins[i], 1, 1.9) } ! n).sum;
	}
	,
	'7pulsHACK' -> { arg in, hSpeed = 1, oct=0, indiv = 0, width=0.9;
		var hacks, n = q.numChans;
		hacks = {|i| LFPulse.ar((2**oct) * (i+1 ** indiv) * hSpeed, 0, width).lag(1/2000) } ! n;
		in * hacks;
	}
	,

	'8wheel'-> { | in, ampWh = 1, rotWh = 0.051, dimension=16, ampExp = 0.75, lagWheel=12.5|

		var wheelXY, xys, dists, dt, dAmp, rad=1, radiuScale=0.9;
		var poly = q.numChans;
		var wheelRotAngle;
		dimension = dimension.lag3(lagWheel);
		// n speaker poses
		xys = ((0,1..poly-1) / poly * 2pi)
		.collect({ arg ang; Polar(1, ang).asPoint });

		in.collect({|chan, i|
			wheelRotAngle = LFSaw.kr(rotWh.neg.lag3(lagWheel), i / in.size * pi, pi);
			// 1 wheel pos
			wheelXY = Polar(1, wheelRotAngle).asPoint;

			dists = xys.collect({ arg point;
				point.dist(wheelXY) * dimension + 1
			});

			dt = dists.sqrt / 330;	// ha amp compensated;
			dAmp = (dists **
				(	ampExp.neg *
					(dimension ** 0.45)
				).reciprocal.lag3(1)
			);
			chan = Limiter.ar(chan  * dAmp * ampWh.lag(0.1) , 0.97, 0.1);
			DelayC.ar(chan, 0.5, dt);
		}).sum
	},


	'8ascrambl'-> { | in|
		// Scramble.ar(in);
		in.scramble
	},
/*	'9aorderWheel'-> { | in|
		in[[0, 2, 1, 3]]
	},*/

	'8monomix'-> { | in |
		in.mean.dup(q.numChans);
	},
	'8stereofy'-> { | in |
		Splay.ar(in);
	},
	'9springPan' -> { arg in, speedA=0.05, pAN=0,  shape = 1, widthA=2;
		var excurs = speedA > 0 * 3;
		var mod = SinOsc.kr(speedA).pow(shape).madd(excurs, pAN.lag(3)/2);
		PanAz.ar(q.numChans, in.asArray.sum, mod, 1, widthA, 0);
	},
	'8waber'-> { | in, lagW=10, widthW=0.0, speedW=0.01|
		var maxdt = 0.4;
		widthW = widthW.lag3(lagW) * maxdt;
		speedW = speedW.lag(lagW);
		DelayL.ar(
			in,
			maxdt,
			LFDNoise3.kr(speedW ! q.numChans).abs.madd(widthW)
		);
	},

	'9endFil' -> { arg in, higCut=19000, lowCut=20, midFr= 100, midDB= 3;
		var l, h;
		in = MidEQ.ar(in, midFr, 2, midDB);
		l = LPF.ar( in, lowCut);
		h = LPF.ar( in, higCut);
		h-l;
	},

	'ampFin' -> { |in, limDrive=1, ampLimit=0.9, postAmp=1 |
		var st = Limiter.ar(in * limDrive, ampLimit) * postAmp;
		LeakDC.ar(st)
	},

	'9netAnalysis' -> { arg in;
		var metro = Impulse.kr(50);
		//	var ampsFast4 = Amplitude.kr(in, 0.01, 1);
		var ampsSlow = Amplitude.kr(in, 2, 10).lag3(3);
		var ampsSuperSlow = Amplitude.kr(in, 10, 100).lag3(5);
		var tendency = ampsSlow.mean - ampsSuperSlow.mean;

		//	SendReply.kr(metro, '/compass', ampsFast4);
		SendReply.kr(metro, '/ampsSlow', ampsSlow);
		SendReply.kr(metro, '/ampsSuperSlow', ampsSuperSlow);
		SendReply.kr(metro, '/tendency', tendency);
		in
	}

];
);

// Analysis / to Network
//  ToDo: Pitch stuff / Light organ
(
q.netAddr = q.netAddr ??  { NetAddr("localhost", 571200); };

OSCdef(\netAnalysis_0, { |msg|
	var arr = msg.drop(3);
	var peak = arr.indexOf(arr.maxItem);
	var quad = arr.wrapExtend(4);
	var balLR = quad[1] - quad[0];
	var balFR = quad[3] - quad[2];
	var posPoint = Point(balLR, balFR);
	q.qPos = posPoint;
	q.netAddr.sendMsg("/amps", arr.mean);
	q.netAddr.sendMsg("/compass", #[\w, \e, \n, \s].clipAt(peak));
	q.netAddr.sendMsg("/gravityPointXY", balLR,  balFR);
}, '/ampsSlow').permanent_(true);

OSCdef(\netAnalysis_1, { |msg|
	q.ampSuperSlow = msg.drop(3).mean;
	q.netAddr.sendMsg("/ampsSuperSlow", (msg[3]));
}, '/ampsSuperSlow').permanent_(true);

OSCdef(\netAnalysis_2, { |msg|
	q.ampTendency = msg[3];
	q.netAddr.sendMsg("/ampTendency", (msg[3]));
}, '/tendency').permanent_(true);
);
// e.o. Analysis / to Network


/////make MAster FX


// add them to da Chain
q.mfx.fx.keysValuesDo({ |key,val| // key.postcln;
	ProxyChain.add(key.asSymbol, \filterIn -> val)
});

(
q.mfx.mFX = MasterFX.new(server: s,
	numChannels: q.numChans,
	slotNames: q.mfx.fx.keys
//	.reject({|it| ['1sluu', '3funFilt', '3ParF', '19MURF'].includes(it)})
	.asArray.sort,
	busIndex: 0
);

// pre-set ons:

q.mfx.mFX.pxChain.add('00_in', 1);
q.mfx.mFX.pxChain.add('0_DBComp', 1);
q.mfx.mFX.pxChain.add('1fyrFilt', 0.1);
// q.mFX.pxChain.add('0turboDLY', 0.1);
q.mfx.mFX.pxChain.add('9endFil', 1);
q.mfx.mFX.pxChain.add('ampFin', 1);


q.mfx.guiMaFX = q.mfx.mFX.gui('ma master', 40);
q.mfx.mFX.pxChain.proxy.fadeTime = 3;
);






//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
/// The Preset Quest from Installation ISpendMaLife
q.mfx.wetsToMove = [ 'wet30', 'wet40', 'wet50', 'wet60', 'wet70', 'wet80', 'wet90',
	'wet100', 'wet110', 'wet120', 'wet130', ];

q.mfx.fxToPunch = [ '5RLPF', '0turboDLY', '3thrasher', '8wheel', '5Hreveb', '1ixiDist', '2DelaySt', '0_DBComp', '8waber', '3funFilt', '1ring', '0_par_EQ', '1fyrFilt' ].sort;

// make PRESET really work!
//q.mfx.preset = NodeProxyPreset(q.mfx.fx.pxChain.proxy, q.mfx.wetsToMove);

/*
ProxyPresetGui( q.mfx.preset )
q.mfx.preset.setRand;
q.mfx.preset.setRand;
q.mfx.fx.pxChain.proxy.nodeMap;
*/

// work around it!

// this shd just collect the wets from home!
q.mfx.moveWets = {|env, much=0.8, center = 0.5|
	// q.mfx.wetsToMove
	var indices = q.mfx.stayers.asArray.collect{|e| q.mfx.fxToPunch.indexOf(e) + 3};
	var wez = indices.collect{ |i| (\wet ++ (i*10)).asSymbol };
	wez.do{|key| q.mfx.mFX.pxChain.proxy.setUni(key, (much.rand2+center).fold(0,1) ) };
};
// q.mfx.moveWets(1);
// q.mfx.moveWets(0.7);

q.mfx.punchFX = {|env, much=0.5|
	var stayers = q.mfx.fxToPunch.scramble.keep(
		(q.mfx.fxToPunch.size * much.rand).roundUp.asInteger
	).sort.asSet;
	var goers = q.mfx.fxToPunch.asSet - stayers;
	goers.do{|key| q.mfx.mFX.pxChain.remove(key) };
	stayers.do{|key| q.mfx.mFX.pxChain.add(key, 1.0.rand.pow(5))};
	q.mfx.mFX.pxChain.proxy.cleanNodeMap;  //	this.object.resetNodeMap;
	stayers
};

// which to
q.mfx.handomizeSlot = {|env, key, much=0.2, center = 0.5|
	var whichKeys = q.mfx.fx[key.postcln].postcln.def.argNames.reject{|s|s==\in};
	whichKeys.do{|key| q.mfx.mFX.pxChain.proxy.setUni(
		key,
		(much.rand2+center).fold(0,1)
	)
	};
};

// better check in object order...
q.mfx.handomizeStayers = {|a, much=0.2, center = 0.5| q.mfx.stayers.do{ |st| q.mfx.handomizeSlot( st, much, center) } };

// q.mfx.stayers = q.mfx.punchFX;
// q.mfx.moveWets(0.2, 0.4);

// apply one of these on each movement change.
q.mfx.vary = {
	if(0.6.coin){
		q.mfx.stayers = q.mfx.punchFX(0.2, 0.4).postln;
	};
	if(0.6.coin){
		q.mfx.moveWets;		q.mfx.handomizeStayers(1.0);
	};
};
/*
q.mfx.stayers = q.mfx.punchFX(0.2, 0.4).postln;\;
q.mfx.moveWets;		q.mfx.handomizeStayers(1.0);
q.mfx.punchFX(0.2, 0.4).postln;\;
q.mfx.vary;
*/
