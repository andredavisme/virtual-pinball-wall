/**
 * audio.js -- Web Audio API sound engine
 * AudioContext requires a user gesture to start (browser policy).
 */

let ctx = null;
let unlocked = false;

function getCtx() {
  if (!ctx) ctx = new (window.AudioContext || window.webkitAudioContext)();
  if (ctx.state === 'suspended') ctx.resume();
  return ctx;
}

export function unlock() {
  if (!unlocked) { getCtx(); unlocked = true; }
}

function playTone({ freq = 440, type = 'sine', duration = 0.08, gain = 0.3, decay = 0.06 } = {}) {
  if (!unlocked) return;
  const c = getCtx();
  const osc = c.createOscillator();
  const env = c.createGain();
  osc.connect(env); env.connect(c.destination);
  osc.type = type; osc.frequency.value = freq;
  env.gain.setValueAtTime(gain, c.currentTime);
  env.gain.exponentialRampToValueAtTime(0.001, c.currentTime + decay);
  osc.start(c.currentTime); osc.stop(c.currentTime + duration);
}

export const sounds = {
  bumper()  { playTone({ freq: 900,  type: 'square',   duration: 0.10, gain: 0.25, decay: 0.08 }); },
  flip()    { playTone({ freq: 200,  type: 'triangle', duration: 0.05, gain: 0.20, decay: 0.04 }); },
  drain()   { playTone({ freq: 440, type: 'sine', duration: 0.3, gain: 0.3, decay: 0.25 });
              playTone({ freq: 220, type: 'sine', duration: 0.4, gain: 0.2, decay: 0.35 }); },
  target()  { playTone({ freq: 660,  type: 'sine',     duration: 0.08, gain: 0.20, decay: 0.06 }); },
  launch()  { playTone({ freq: 330,  type: 'sawtooth', duration: 0.15, gain: 0.25, decay: 0.12 }); },
  score()   { playTone({ freq: 1100, type: 'sine',     duration: 0.12, gain: 0.20, decay: 0.10 }); },
};
