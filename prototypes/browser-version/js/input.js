/**
 * input.js
 * Input abstraction layer -- mirrors pseudocode/03-input-abstraction.md
 * Maps keyboard + touch to canonical InputEvent enum.
 */

export const InputEvent = Object.freeze({
  LEFT_FLIPPER_DOWN:  'LEFT_FLIPPER_DOWN',
  LEFT_FLIPPER_UP:    'LEFT_FLIPPER_UP',
  RIGHT_FLIPPER_DOWN: 'RIGHT_FLIPPER_DOWN',
  RIGHT_FLIPPER_UP:   'RIGHT_FLIPPER_UP',
  LAUNCH:             'LAUNCH',
  PAUSE:              'PAUSE',
  TILT:               'TILT',
  NONE:               'NONE',
});

const KEYMAP = {
  'z': InputEvent.LEFT_FLIPPER_DOWN, 'Z': InputEvent.LEFT_FLIPPER_DOWN,
  '/': InputEvent.RIGHT_FLIPPER_DOWN,
  'ArrowLeft':  InputEvent.LEFT_FLIPPER_DOWN,
  'ArrowRight': InputEvent.RIGHT_FLIPPER_DOWN,
  'ShiftLeft':  InputEvent.LEFT_FLIPPER_DOWN,
  'ShiftRight': InputEvent.RIGHT_FLIPPER_DOWN,
  ' ': InputEvent.LAUNCH,
  'p': InputEvent.PAUSE, 'P': InputEvent.PAUSE,
};

const KEYMAP_UP = {
  'z': InputEvent.LEFT_FLIPPER_UP, 'Z': InputEvent.LEFT_FLIPPER_UP,
  '/': InputEvent.RIGHT_FLIPPER_UP,
  'ArrowLeft':  InputEvent.LEFT_FLIPPER_UP,
  'ArrowRight': InputEvent.RIGHT_FLIPPER_UP,
  'ShiftLeft':  InputEvent.LEFT_FLIPPER_UP,
  'ShiftRight': InputEvent.RIGHT_FLIPPER_UP,
};

const _queue = [];
function enqueue(event) { _queue.push(event); }
export function poll() { return _queue.shift() ?? InputEvent.NONE; }

const _held = { left: false, right: false };
export function getHeldState() { return { ..._held }; }

export function init() {
  document.addEventListener('keydown', e => {
    if (e.repeat) return;
    const code = e.key === 'Shift' ? e.code : e.key;
    const evt  = KEYMAP[code];
    if (evt) {
      e.preventDefault();
      if (evt === InputEvent.LEFT_FLIPPER_DOWN)  _held.left  = true;
      if (evt === InputEvent.RIGHT_FLIPPER_DOWN) _held.right = true;
      enqueue(evt);
    }
  });

  document.addEventListener('keyup', e => {
    const code = e.key === 'Shift' ? e.code : e.key;
    const evt  = KEYMAP_UP[code];
    if (evt) {
      if (evt === InputEvent.LEFT_FLIPPER_UP)  _held.left  = false;
      if (evt === InputEvent.RIGHT_FLIPPER_UP) _held.right = false;
      enqueue(evt);
    }
  });

  const btnLeft  = document.getElementById('btn-left');
  const btnRight = document.getElementById('btn-right');

  function touchStart(side) {
    const evt = side === 'left' ? InputEvent.LEFT_FLIPPER_DOWN : InputEvent.RIGHT_FLIPPER_DOWN;
    if (side === 'left') _held.left = true; else _held.right = true;
    enqueue(evt);
    (side === 'left' ? btnLeft : btnRight).classList.add('active');
  }
  function touchEnd(side) {
    const evt = side === 'left' ? InputEvent.LEFT_FLIPPER_UP : InputEvent.RIGHT_FLIPPER_UP;
    if (side === 'left') _held.left = false; else _held.right = false;
    enqueue(evt);
    (side === 'left' ? btnLeft : btnRight).classList.remove('active');
  }

  btnLeft.addEventListener('pointerdown',  e => { e.preventDefault(); touchStart('left'); });
  btnLeft.addEventListener('pointerup',    e => { e.preventDefault(); touchEnd('left'); });
  btnLeft.addEventListener('pointerleave', e => { e.preventDefault(); touchEnd('left'); });
  btnRight.addEventListener('pointerdown',  e => { e.preventDefault(); touchStart('right'); });
  btnRight.addEventListener('pointerup',    e => { e.preventDefault(); touchEnd('right'); });
  btnRight.addEventListener('pointerleave', e => { e.preventDefault(); touchEnd('right'); });
}
