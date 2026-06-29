/**
 * physics.js
 * Matter.js body setup -- mirrors pseudocode/02-physics-engine.md
 *
 * Maps:
 *   RigidBody2D Ball     -> Matter.Bodies.circle
 *   AnimatableBody2D     -> Matter.Bodies.rectangle (compound flipper pivot via Constraint)
 *   Area2D Bumper        -> Matter.Bodies.circle (isStatic, restitution high)
 *   Area2D DrainZone     -> detected via position check
 *   StaticBody2D Walls   -> Matter.Bodies.rectangle chains
 */

const { Engine, Bodies, Body, Composite, Constraint } = Matter;

let SCALE = 1;
export function setScale(s) { SCALE = s; }
export function getScale()  { return SCALE; }
function px(v) { return v * SCALE; }

export function createWorld(canvas, tableLayout) {
  const W = canvas.width;
  SCALE = W / 720;

  const engine = Engine.create({ gravity: { x: 0, y: 2.5 } });
  const world  = engine.world;

  const ball = Bodies.circle(
    px(tableLayout.launch_position.x),
    px(tableLayout.launch_position.y),
    px(12),
    {
      label: 'ball',
      restitution: 0.6,
      friction: 0.05,
      frictionAir: 0.01,
      density: 0.004,
    }
  );

  const wallBodies = tableLayout.walls.map(w => {
    const x1 = px(w.start.x), y1 = px(w.start.y);
    const x2 = px(w.end.x),   y2 = px(w.end.y);
    const cx = (x1 + x2) / 2, cy = (y1 + y2) / 2;
    const len = Math.hypot(x2 - x1, y2 - y1);
    const angle = Math.atan2(y2 - y1, x2 - x1);
    return Bodies.rectangle(cx, cy, len, 6, {
      isStatic: true, label: 'wall', angle,
      restitution: 0.4, friction: 0.1,
    });
  });

  const floor = Bodies.rectangle(W / 2, canvas.height + 20, W * 2, 40, {
    isStatic: true, label: 'floor', restitution: 0,
  });

  const bumpers = tableLayout.bumpers.map((b, i) =>
    Bodies.circle(px(b.x), px(b.y), px(b.radius), {
      isStatic: true, label: `bumper_${i}`,
      restitution: 1.4, friction: 0,
      scoreValue: b.score_value, hitCooldown: 0,
    })
  );

  const targetBodies = tableLayout.targets.map((t, i) =>
    Bodies.rectangle(px(t.x), px(t.y), px(t.width), px(t.height), {
      isStatic: true, label: `target_${i}`,
      restitution: 0.3, friction: 0,
      scoreValue: t.score_value, active: t.active,
    })
  );

  const flipperData = tableLayout.flippers.map(f => {
    const pivotX = px(f.pivot.x);
    const pivotY = px(f.pivot.y);
    const len    = px(f.length);
    const thick  = px(10);
    const offsetX = (f.side === 'LEFT') ? len / 2 : -len / 2;

    const body = Bodies.rectangle(pivotX + offsetX, pivotY, len, thick, {
      isStatic: false,
      label: `flipper_${f.side}`,
      restitution: 0.1, friction: 0.1, frictionAir: 0.35, density: 0.08,
      collisionFilter: { category: 0x0002, mask: 0x0001 },
    });

    const pivot = Constraint.create({
      bodyA: body,
      pointA: { x: -offsetX, y: 0 },
      pointB: { x: pivotX, y: pivotY },
      stiffness: 1, length: 0,
    });

    const restAngle   = f.angle_rest   * (Math.PI / 180);
    const activeAngle = f.angle_active * (Math.PI / 180);
    Body.setAngle(body, restAngle);
    Body.setStatic(body, true);

    return { side: f.side, body, pivot, pivotX, pivotY, restAngle, activeAngle, currentAngle: restAngle, isActive: false };
  });

  Composite.add(world, [ball, ...wallBodies, floor, ...bumpers, ...targetBodies]);
  flipperData.forEach(f => Composite.add(world, [f.body, f.pivot]));

  return { engine, ball, flippers: flipperData, bumpers, targets: targetBodies, drainY: px(tableLayout.drain_y), tableLayout };
}

export function resetBall(ball, tableLayout) {
  Body.setPosition(ball, { x: SCALE * tableLayout.launch_position.x, y: SCALE * tableLayout.launch_position.y });
  Body.setVelocity(ball,  { x: 0, y: 0 });
  Body.setAngularVelocity(ball, 0);
}

export function resetTargets(targets, tableLayout) {
  targets.forEach((body, i) => { body.active = tableLayout.targets[i].active; });
}

export function activateFlipper(flipper)  { flipper.isActive = true; }
export function releaseFlipper(flipper)   { flipper.isActive = false; }

export function stepFlippers(flippers) {
  const ACTIVATE_SPEED = 0.28;
  const RELEASE_SPEED  = 0.18;
  flippers.forEach(f => {
    const target = f.isActive ? f.activeAngle : f.restAngle;
    const diff   = target - f.currentAngle;
    const speed  = f.isActive ? ACTIVATE_SPEED : RELEASE_SPEED;
    const step   = Math.sign(diff) * Math.min(Math.abs(diff), speed);
    f.currentAngle += step;
    Body.setAngle(f.body, f.currentAngle);
    Body.setStatic(f.body, true);
  });
}
