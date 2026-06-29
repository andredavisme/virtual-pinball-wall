/**
 * engine.js -- requestAnimationFrame game loop
 * Mirrors pseudocode/01-game-loop.md state machine:
 *   ATTRACT -> PLAYING -> PAUSED -> GAME_OVER -> ATTRACT
 */

import { GAME_CONFIG, DEFAULT_TABLE_LAYOUT } from './config.js';
import { createWorld, resetBall, resetTargets, activateFlipper, releaseFlipper, stepFlippers } from './physics.js';
import { init as initInput, poll, InputEvent } from './input.js';
import { drawFrame, notifyBumperHit, notifyTargetHit } from './renderer.js';
import { sounds, unlock } from './audio.js';
import { postScore, getLeaderboard } from './supabase.js';

const GameState = Object.freeze({
  ATTRACT:   'ATTRACT',
  PLAYING:   'PLAYING',
  PAUSED:    'PAUSED',
  GAME_OVER: 'GAME_OVER',
});

const canvas          = document.getElementById('game-canvas');
const ctx             = canvas.getContext('2d');
const scoreDisplay    = document.getElementById('score-display');
const ballsDisplay    = document.getElementById('balls-display');
const overlayAttract  = document.getElementById('overlay-attract');
const overlayPaused   = document.getElementById('overlay-paused');
const overlayGameover = document.getElementById('overlay-gameover');
const attractHiScore  = document.getElementById('attract-hiscore');
const finalScoreLabel = document.getElementById('final-score-label');
const leaderboardList = document.getElementById('leaderboard-list');
const initialsInput   = document.getElementById('initials-input');
const btnSubmit       = document.getElementById('btn-submit-initials');

let gameState         = GameState.ATTRACT;
let currentScore      = 0;
let ballsRemaining    = GAME_CONFIG.balls_per_game;
let initialsConfirmed = false;
let cachedLeaderboard = [];
let tableLayout       = DEFAULT_TABLE_LAYOUT;
let physicsState      = null;
let mEngine           = null;
let lastTime          = 0;

function resizeCanvas() {
  const maxW = Math.min(window.innerWidth, 480);
  const maxH = window.innerHeight - 120;
  const w    = Math.min(maxW, maxH * 9 / 16);
  canvas.width  = Math.round(w);
  canvas.height = Math.round(w * 16 / 9);
}

function addScore(value) {
  currentScore += value;
  scoreDisplay.textContent = currentScore.toLocaleString();
}

function showOverlay(name) {
  overlayAttract.classList.toggle('hidden',  name !== 'attract');
  overlayPaused.classList.toggle('hidden',   name !== 'paused');
  overlayGameover.classList.toggle('hidden', name !== 'gameover');
}

function showAttractScreen() {
  showOverlay('attract');
  if (cachedLeaderboard.length > 0) {
    attractHiScore.textContent = `HI SCORE  ${cachedLeaderboard[0].score.toLocaleString()}`;
  }
}

function launchBall() {
  showOverlay(null);
  Matter.Body.applyForce(physicsState.ball, physicsState.ball.position, { x: 0, y: -0.045 });
  sounds.launch();
}

function onBallDrained() {
  sounds.drain();
  ballsRemaining--;
  ballsDisplay.textContent = ballsRemaining;
  if (ballsRemaining <= 0) {
    gameState = GameState.GAME_OVER;
    // Fetch and cache leaderboard once on GAME_OVER entry -- not per frame
    getLeaderboard(GAME_CONFIG.active_table_id).then(lb => {
      cachedLeaderboard = lb;
      renderLeaderboard();
    });
    finalScoreLabel.textContent = `SCORE  ${currentScore.toLocaleString()}`;
    initialsConfirmed = false;
    initialsInput.value = '';
    showOverlay('gameover');
  } else {
    resetBall(physicsState.ball, tableLayout);
    resetTargets(physicsState.targets, tableLayout);
  }
}

function onInitialsConfirmed(initials) {
  // Triggered by UI -- never called from render loop (per pseudocode)
  initialsConfirmed = true;
  postScore(initials, currentScore, GAME_CONFIG.active_table_id);
  cachedLeaderboard = [{ player_initials: initials, score: currentScore }, ...cachedLeaderboard]
    .sort((a, b) => b.score - a.score).slice(0, 10);
  renderLeaderboard();
}

function renderLeaderboard() {
  // Populate from pre-cached data -- no network call here
  leaderboardList.innerHTML = '';
  cachedLeaderboard.forEach(entry => {
    const li = document.createElement('li');
    li.innerHTML = `<span>${entry.player_initials}</span><span>${Number(entry.score).toLocaleString()}</span>`;
    leaderboardList.appendChild(li);
  });
}

function resetGame() {
  currentScore   = 0;
  ballsRemaining = GAME_CONFIG.balls_per_game;
  scoreDisplay.textContent = '0';
  ballsDisplay.textContent = ballsRemaining;
  resetBall(physicsState.ball, tableLayout);
  resetTargets(physicsState.targets, tableLayout);
  physicsState.flippers.forEach(f => {
    f.isActive = false; f.currentAngle = f.restAngle;
    Matter.Body.setAngle(f.body, f.restAngle);
  });
}

function setupCollisions() {
  Matter.Events.on(mEngine, 'collisionStart', event => {
    event.pairs.forEach(({ bodyA, bodyB }) => {
      const ball  = [bodyA, bodyB].find(b => b.label === 'ball');
      const other = [bodyA, bodyB].find(b => b !== ball);
      if (!ball || !other) return;

      if (other.label.startsWith('bumper_')) {
        const idx = parseInt(other.label.split('_')[1], 10);
        const val = other.scoreValue ?? tableLayout.bumpers[idx]?.score_value ?? 100;
        addScore(val); notifyBumperHit(idx); sounds.bumper();
        const dir = Matter.Vector.normalise(Matter.Vector.sub(ball.position, other.position));
        Matter.Body.applyForce(ball, ball.position, { x: dir.x * 0.025, y: dir.y * 0.025 });
      }

      if (other.label.startsWith('target_') && other.active !== false) {
        const idx = parseInt(other.label.split('_')[1], 10);
        const val = other.scoreValue ?? tableLayout.targets[idx]?.score_value ?? 50;
        addScore(val); other.active = false; notifyTargetHit(idx); sounds.target();
      }
    });
  });
}

function gameLoop(timestamp) {
  const delta = Math.min(timestamp - lastTime, 50);
  lastTime = timestamp;

  let inputEvt;
  while ((inputEvt = poll()) !== InputEvent.NONE) {
    switch (gameState) {
      case GameState.ATTRACT:
        if (inputEvt === InputEvent.LAUNCH) { gameState = GameState.PLAYING; launchBall(); }
        break;
      case GameState.PLAYING:
        if (inputEvt === InputEvent.LEFT_FLIPPER_DOWN)  { activateFlipper(physicsState.flippers[0]); sounds.flip(); }
        if (inputEvt === InputEvent.LEFT_FLIPPER_UP)    { releaseFlipper(physicsState.flippers[0]); }
        if (inputEvt === InputEvent.RIGHT_FLIPPER_DOWN) { activateFlipper(physicsState.flippers[1]); sounds.flip(); }
        if (inputEvt === InputEvent.RIGHT_FLIPPER_UP)   { releaseFlipper(physicsState.flippers[1]); }
        if (inputEvt === InputEvent.PAUSE) { gameState = GameState.PAUSED; showOverlay('paused'); }
        break;
      case GameState.PAUSED:
        if (inputEvt === InputEvent.PAUSE) { gameState = GameState.PLAYING; showOverlay(null); }
        break;
      case GameState.GAME_OVER:
        if (initialsConfirmed && inputEvt !== InputEvent.NONE) { resetGame(); gameState = GameState.ATTRACT; showAttractScreen(); }
        break;
    }
  }

  if (gameState === GameState.PLAYING) {
    stepFlippers(physicsState.flippers);
    Matter.Engine.update(mEngine, delta);
    if (physicsState.ball.position.y > physicsState.drainY) onBallDrained();
  }

  drawFrame(ctx, physicsState, tableLayout);
  requestAnimationFrame(gameLoop);
}

async function init() {
  resizeCanvas();
  window.addEventListener('resize', () => {
    resizeCanvas();
    physicsState = createWorld(canvas, tableLayout);
    mEngine = physicsState.engine;
    setupCollisions();
  });

  document.addEventListener('pointerdown', unlock, { once: true });
  document.addEventListener('keydown',     unlock, { once: true });

  initInput();

  physicsState = createWorld(canvas, tableLayout);
  mEngine      = physicsState.engine;
  setupCollisions();

  cachedLeaderboard = await getLeaderboard(GAME_CONFIG.active_table_id);
  showAttractScreen();

  canvas.addEventListener('pointerdown', () => {
    if (gameState === GameState.ATTRACT) { gameState = GameState.PLAYING; launchBall(); }
  });

  btnSubmit.addEventListener('click', () => {
    const val = initialsInput.value.trim().toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 3);
    if (val.length > 0) onInitialsConfirmed(val);
  });
  initialsInput.addEventListener('keydown', e => { if (e.key === 'Enter') btnSubmit.click(); });

  lastTime = performance.now();
  requestAnimationFrame(gameLoop);
}

init();
