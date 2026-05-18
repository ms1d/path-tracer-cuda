#include "../test_runner.h"
#include "ray.cuh"
#include <cassert>

__global__ void reflect_ray_kernel(ray* r, const vec<3>* p, const vec<3>* n) {
	r->reflect_inplace(*p, *n);
}

void reflect_ray_cu() {
	ray *r;
	vec<3> *p, *n;

	cudaMallocManaged(&r, sizeof(ray));
	cudaMallocManaged(&p, sizeof(vec<3>));
	cudaMallocManaged(&n, sizeof(vec<3>));

	*r = init_ray();
	*p = vec<3>(dist(rng), dist(rng), dist(rng));
	*n = vec<3>(dist(rng), dist(rng), dist(rng));
    
    // Normalize n for standard reflection
    float mag_n = n->mag();
    if (mag_n > math_precision::epsilon) *n *= (1.0f / mag_n);

    ray r_init = *r;
	reflect_ray_kernel<<<1, 1>>>(r, p, n);
	cudaDeviceSynchronize();
	
    // Manual check calculation
    float t = (r_init.o * *n - *p * *n) / (r_init.dir * *n);
    vec<3> o_prime = r_init.o - r_init.dir * (2.0f * t);
    vec<3> dir_prime = *p - o_prime;
    ray check_ray(o_prime, dir_prime);

	assert(*r == check_ray);

	cudaFree(r);
	cudaFree(p);
	cudaFree(n);
}

void reflect_ray_cpp() {
	ray r = init_ray();
	vec<3> p = vec<3>(dist(rng), dist(rng), dist(rng));
	vec<3> n = vec<3>(dist(rng), dist(rng), dist(rng));

    float mag_n = n.mag();
    if (mag_n > math_precision::epsilon) n *= (1.0f / mag_n);

    ray r_init = r;
	r.reflect_inplace(p, n);

    float t = (r_init.o * n - p * n) / (r_init.dir * n);
    vec<3> o_prime = r_init.o - r_init.dir * (2.0f * t);
    vec<3> dir_prime = p - o_prime;
    ray check_ray(o_prime, dir_prime);

	assert(r == check_ray);
}

struct reflect_ray {
	void operator()() {
		// Test for floating point accuracy on both CPU & GPU
		reflect_ray_cpp();
		reflect_ray_cu();
		
		// Hardcoded test for algorithm correctness
		reflect_ray_example();
	}

	void reflect_ray_example() {
        // Ray from (0, 2, 0) towards (0, 0, 0)
		ray r(vec<3>(0, 2, 0), vec<3>(0, -1, 0));
		vec<3> p(0, 0, 0);
		vec<3> n(0, 1, 0); // Horizontal surface normal

		ray reflected = r.reflect(p, n);
        
        // Expected: t = 2, o' = (0,-2,0), dir' = (0,2,0)
		assert(reflected.o == vec<3>(0, -2, 0));
        assert(reflected.dir == vec<3>(0, 2, 0));
	}
};

int main() {
	run_tests<reflect_ray, 64>();
	return 0;
}
