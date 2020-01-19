import 'dart:math';

import 'package:vector_math/vector_math_64.dart' show Vector2;
import 'helpers.dart';

class Agent {
  Vector2 pos;
  Vector2 vel;
  Vector2 acc;
  Vector2 target;
  Vector2 gravity;

  double maxSpeed = 5;
  double maxForce = 1;

  bool alive = true;

  Agent(this.pos, this.target) {
    acc = Vector2.zero();
    vel = Vector2.zero();

    Random rnd = new Random();
    int min = 6;
    int max = 24;
    int r = min + rnd.nextInt(max - min);

    gravity = Vector2(0, r.toDouble() / 10.0);
  }

  void applyForce(Vector2 force) {
    acc.add(force);
  }

  Vector2 arrive() {
    var desired = target - pos;
    var distance = pos.distanceTo(target);
    double speed = this.maxSpeed;

    if (distance < 100) {
      speed = map(distance, 0, 100, 0, this.maxSpeed);
    }

    desired = desired.normalized() * speed;
    //desired.setMag(speed);
    Vector2 steer = desired - vel;
    //steer.clamp(Vector2(0,0), Vector2(-this.maxForce, this.maxForce));
    steer.clampScalar(-this.maxForce, this.maxForce);
    return steer;
  }

  void behavior() {
    if (alive == true) {
      var arriveForce = arrive() * 0.2;
      applyForce(arriveForce);
    }
  }

  void update() {
    behavior();
    pos.add(vel);
    vel.add(acc);
    acc.setZero();
  }

  void fallDown() {
    alive = false;
    applyForce(gravity);
  }
}
