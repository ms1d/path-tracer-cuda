# RAY

A header-only 3D ray library for CUDA and C++.
It provides core geometric intersection and reflection logic.

## Features

- **CUDA Compatible**: All methods are marked `__host__ __device__`.

- **Intersection Tests**: Includes efficient Moller-Trumbore triangle
and standard plane intersection tests.

- **Precision**: Equality tests and intersection logic use
a default epsilon of `2e-6f`.

## Method Signatures

### Constructors and Basic Ops

- `ray(const vec<3>& origin, const vec<3>& direction)`: Primary constructor.

- `get_point(float t)`: Returns the point `o + dir * t` on the ray.

- `operator==`: Equality test with tolerance.

### Intersection Logic

- `get_tri_intersect(v1, v2, v3)`: Returns the `t` value of intersection
with a triangle.

- `get_plane_intersect(p, n)`: Returns the `t` value of intersection
with a plane defined by a point and a normal.

### Reflection

- `reflect(p, n)`: Returns a new reflected ray from a point and surface normal.

- `reflect_inplace(p, n)`: Updates the current ray's origin and direction
to represent a reflection.
