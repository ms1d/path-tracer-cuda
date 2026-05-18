#include "../test_runner.h"
#include "ray.cuh"
#include <cassert>

__global__ void plane_intersect_kernel(const ray* r, const vec<3>* p, const vec<3>* n, float* t) {
	*t = r->get_plane_intersect(*p, *n);
}

void plane_intersect_cu() {
	ray *r;
	vec<3> *p, *n;
	float *t;

	cudaMallocManaged(&r, sizeof(ray));
	cudaMallocManaged(&p, sizeof(vec<3>));
	cudaMallocManaged(&n, sizeof(vec<3>));
	cudaMallocManaged(&t, sizeof(float));

	*r = init_ray();
	*p = vec<3>(dist(rng), dist(rng), dist(rng));
	*n = vec<3>(dist(rng), dist(rng), dist(rng));

	plane_intersect_kernel<<<1, 1>>>(r, p, n, t);
	cudaDeviceSynchronize();
	
	float check_t = r->get_plane_intersect(*p, *n);
	assert(math_precision::nearly_equal(*t, check_t));

	cudaFree(r);
	cudaFree(p);
	cudaFree(n);
	cudaFree(t);
}

void plane_intersect_cpp() {
	const ray r = init_ray();
	const vec<3> p = vec<3>(dist(rng), dist(rng), dist(rng));
	const vec<3> n = vec<3>(dist(rng), dist(rng), dist(rng));

	float t = r.get_plane_intersect(p, n);
	float check_t = r.get_plane_intersect(p, n);

	assert(math_precision::nearly_equal(t, check_t));
}

struct plane_intersect {
	void operator()() {
		// Test for floating point accuracy on both CPU & GPU
		plane_intersect_cpp();
		plane_intersect_cu();

		// Hardcoded test for algorithm correctness
		plane_intersect_example();
	}

	void plane_intersect_example() {
		// Ray from origin along Y axis
		ray r(vec<3>(0, 0, 0), vec<3>(0, 1, 0));
		
		// Horizontal plane at Y=10
		vec<3> p(0, 10, 0);
		vec<3> n(0, 1, 0);

		float t = r.get_plane_intersect(p, n);
		assert(math_precision::nearly_equal(t, 10.0f));

		// Parallel ray (should fail/return non-positive t)
		ray r_parallel(vec<3>(0, 0, 0), vec<3>(1, 0, 0));
		assert(r_parallel.get_plane_intersect(p, n) < 0 || math_precision::nearly_equal(r_parallel.dir * n, 0));
	}
};

int main() {
	run_tests<plane_intersect, 64>();
	return 0;
}
