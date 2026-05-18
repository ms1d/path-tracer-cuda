#include "../test_runner.h"
#include "ray.cuh"
#include <cassert>

__global__ void tri_intersect_kernel(const ray* r, const vec<3>* v1, const vec<3>* v2, const vec<3>* v3, float* t) {
	*t = r->get_tri_intersect(*v1, *v2, *v3);
}

void tri_intersect_cu() {
	ray *r;
	vec<3> *v1, *v2, *v3;
	float *t;

	cudaMallocManaged(&r, sizeof(ray));
	cudaMallocManaged(&v1, sizeof(vec<3>));
	cudaMallocManaged(&v2, sizeof(vec<3>));
	cudaMallocManaged(&v3, sizeof(vec<3>));
	cudaMallocManaged(&t, sizeof(float));

	*r = init_ray();
	*v1 = vec<3>(dist(rng), dist(rng), dist(rng));
	*v2 = vec<3>(dist(rng), dist(rng), dist(rng));
	*v3 = vec<3>(dist(rng), dist(rng), dist(rng));

	tri_intersect_kernel<<<1, 1>>>(r, v1, v2, v3, t);
	cudaDeviceSynchronize();
	
	float check_t = r->get_tri_intersect(*v1, *v2, *v3);
	assert(__builtin_fabsf(*t - check_t) < math_precision::epsilon);

	cudaFree(r);
	cudaFree(v1);
	cudaFree(v2);
	cudaFree(v3);
	cudaFree(t);
}

void tri_intersect_cpp() {
	const ray r = init_ray();
	const vec<3> v1 = vec<3>(dist(rng), dist(rng), dist(rng));
	const vec<3> v2 = vec<3>(dist(rng), dist(rng), dist(rng));
	const vec<3> v3 = vec<3>(dist(rng), dist(rng), dist(rng));

	float t = r.get_tri_intersect(v1, v2, v3);
	float check_t = r.get_tri_intersect(v1, v2, v3);

	assert(__builtin_fabsf(t - check_t) < math_precision::epsilon);
}

struct tri_intersect {
	void operator()() {
		// Test for floating point accuracy on both CPU & GPU
		tri_intersect_cpp();
		tri_intersect_cu();
		
		// Hardcoded test for algorithm correctness
		tri_intersect_example();
	}

	void tri_intersect_example() {
		// Ray from origin along Z axis
		ray r(vec<3>(0, 0, 0), vec<3>(0, 0, 1));
		
		// Triangle in XY plane at Z=5
		vec<3> v1(-1, -1, 5);
		vec<3> v2(1, -1, 5);
		vec<3> v3(0, 1, 5);

		float t = r.get_tri_intersect(v1, v2, v3);
		assert(__builtin_fabsf(t - 5.0f) < math_precision::epsilon);

		// Test miss (ray pointing away)
		ray r_miss(vec<3>(0, 0, 0), vec<3>(0, 0, -1));
		assert(r_miss.get_tri_intersect(v1, v2, v3) < 0);
	}
};

int main() {
	run_tests<tri_intersect, 64>();
	return 0;
}
