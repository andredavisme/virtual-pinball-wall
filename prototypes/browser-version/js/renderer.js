/**
 * renderer.js
 * Canvas 2D draw calls -- mirrors pseudocode/04-ui-renderer.md
 * drawFrame() = UIRenderer.update_frame()
 */

const BUMPER_FLASH_MS = 120;
const TARGET_FLASH_MS = 200;
const bumperFlashUntil = new Map();
const targetFlashUntil = new Map();

export function notifyBumperHit(index) { bumperFlashUntil.set(index, performance.now() + BUMPER_FLASH_MS); }
export function notifyTargetHit(index) { targetFlashUntil.set(index, performance.now() + TARGET_FLASH_MS); }

export function drawFrame(ctx, physicsState, tableLayout) {
  const { ball, flippers, bumpers, targets, drainY } = physicsState;
  const W = ctx.canvas.width;
  const H = ctx.canvas.height;
  const now = performance.now();
  const scale = W / 720;

  ctx.fillStyle = '#0a0a12';
  ctx.fillRect(0, 0, W, H);

  const grad = ctx.createLinearGradient(0, 0, 0, H);
  grad.addColorStop(0,   'rgba(46,236,208,0.04)');
  grad.addColorStop(0.5, 'rgba(0,0,0,0)');
  grad.addColorStop(1,   'rgba(245,166,35,0.06)');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, W, H);

  // Walls
  ctx.strokeStyle = '#3a3a4a';
  ctx.lineWidth   = 3;
  tableLayout.walls.forEach(w => {
    ctx.beginPath();
    ctx.moveTo(w.start.x * scale, w.start.y * scale);
    ctx.lineTo(w.end.x   * scale, w.end.y   * scale);
    ctx.stroke();
  });

  // Drain line
  ctx.strokeStyle = 'rgba(224,80,80,0.3)';
  ctx.lineWidth   = 1;
  ctx.setLineDash([6, 6]);
  ctx.beginPath(); ctx.moveTo(0, drainY); ctx.lineTo(W, drainY); ctx.stroke();
  ctx.setLineDash([]);

  // Bumpers
  bumpers.forEach((b, i) => {
    const flashing = bumperFlashUntil.has(i) && now < bumperFlashUntil.get(i);
    const r = b.circleRadius ?? 28;
    const { x: cx, y: cy } = b.position;
    ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.fillStyle   = flashing ? '#ffffff' : '#f5a623';
    ctx.shadowBlur  = flashing ? 24 : 10;
    ctx.shadowColor = flashing ? '#ffffff' : '#f5a62388';
    ctx.fill();
    ctx.shadowBlur  = 0;
    ctx.strokeStyle = flashing ? '#ffffff' : '#f5a623';
    ctx.lineWidth   = 2;
    ctx.stroke();
    ctx.fillStyle   = '#0d0d0f';
    ctx.font        = `bold ${Math.round(r * 0.55)}px 'Share Tech Mono', monospace`;
    ctx.textAlign   = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(b.scoreValue ?? tableLayout.bumpers[i]?.score_value ?? '', cx, cy);
  });

  // Targets
  targets.forEach((t, i) => {
    const flashing = targetFlashUntil.has(i) && now < targetFlashUntil.get(i);
    const active   = t.active !== false;
    const { x, y } = t.position;
    const hw = (t.bounds.max.x - t.bounds.min.x) / 2;
    const hh = (t.bounds.max.y - t.bounds.min.y) / 2;
    ctx.save();
    ctx.translate(x, y); ctx.rotate(t.angle);
    ctx.fillStyle   = flashing ? '#ffffff' : (active ? '#2eecd0' : '#2a2a38');
    ctx.shadowBlur  = flashing ? 14 : (active ? 6 : 0);
    ctx.shadowColor = '#2eecd0';
    ctx.fillRect(-hw, -hh, hw * 2, hh * 2);
    ctx.shadowBlur  = 0;
    ctx.restore();
  });

  // Flippers
  flippers.forEach(f => {
    const { pivotX, pivotY, currentAngle, side, isActive } = f;
    const len = Math.abs(f.body.bounds.max.x - f.body.bounds.min.x);
    ctx.save();
    ctx.translate(pivotX, pivotY); ctx.rotate(currentAngle);
    ctx.fillStyle   = '#2eecd0';
    ctx.shadowBlur  = isActive ? 14 : 5;
    ctx.shadowColor = '#2eecd044';
    const tip = (side === 'LEFT') ? len : -len;
    ctx.beginPath();
    ctx.moveTo(0, -8); ctx.lineTo(tip, -4); ctx.lineTo(tip, 4); ctx.lineTo(0, 8);
    ctx.closePath(); ctx.fill();
    ctx.shadowBlur = 0;
    ctx.restore();
  });

  // Ball
  const bx = ball.position.x, by = ball.position.y, br = ball.circleRadius ?? 12;
  const ballGrad = ctx.createRadialGradient(bx - br * 0.3, by - br * 0.3, br * 0.05, bx, by, br);
  ballGrad.addColorStop(0, '#ffffff'); ballGrad.addColorStop(0.5, '#d0d0e0'); ballGrad.addColorStop(1, '#8888aa');
  ctx.beginPath(); ctx.arc(bx, by, br, 0, Math.PI * 2);
  ctx.fillStyle = ballGrad;
  ctx.shadowBlur = 10; ctx.shadowColor = 'rgba(200,200,255,0.5)';
  ctx.fill(); ctx.shadowBlur = 0;
}
