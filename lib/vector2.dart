import 'dart:math' as math;

class Vector2 {
  double x=0.0;
  double y=0.0;

  Vector2(this.x, this.y);

  Vector2.zero()
      : x = 0.0,
        y = 0.0;

  Vector2.fromVector2(Vector2 other)
      : x = other.x,
        y = other.y;

  Vector2 operator +(Vector2 other) {
    return Vector2( x + other.x,  y + other.y);
  }

  Vector2 operator -(Vector2 other) {
    return Vector2( x - other.x,  y - other.y);
  }

  Vector2 operator *(double scalar) {
    return Vector2( x * scalar,  y * scalar);
  }

  Vector2 operator /(double scalar) {
    return Vector2( x / scalar,  y / scalar);
  }

  double get magnitude => math.sqrt(x * x + y * y);

  Vector2 normalized() {
    double mag = magnitude;
    return Vector2( x / mag,  y / mag);
  }

  double dot(Vector2 other) => x * other.x + y * other.y;
}
