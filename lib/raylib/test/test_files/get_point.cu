#include "../test_runner.h"
#include "ray.cuh"
#include <cassert>

__global__ void get_point_kernel(const ray* r, float t, vec<3>* res) {
	*res = r->get_point(t);
}

void get_point_cu() {
	ray *r;
	vec<3> *res;
	float t;

	cudaMallocManaged(&r, sizeof(ray));
	cudaMallocManaged(&res, sizeof(vec<3>));

	*r = init_ray();
	t = dist(rng) * 100.0f;

	get_point_kernel<<<1, 1>>>(r, t, res);
	cudaDeviceSynchronize();
	
	vec<3> check_vec = r->o + r->dir * t;
	assert(*res == check_vec);

	cudaFree(r);
	cudaFree(res);
}

void get_point_cpp() {
	const ray r = init_ray();
	float t = dist(rng) * 100.0f;

	vec<3> res = r.get_point(t);
	vec<3> check_vec = r.o + r.dir * t;

	assert(res == check_vec);
}

struct get_point {
	void operator()() {
		// Test for floating point accuracy on both CPU & GPU
		get_point_cpp();
		get_point_cu();
		
		// Hardcoded test for algorithm correctness
		get_point_example();
	}

	void get_point_example() {
		ray r(vec<3>(1, 1, 1), vec<3>(1, 0, 0));
		vec<3> p = r.get_point(5.0f);
		assert(p == vec<3>(6, 1, 1));
	}
};

int main() {
	run_tests<get_point, 64>();
	return 0;
}
