#include "../test_runner.h"
#include "ray.cuh"
#include <cassert>

__global__ void equate_ray_kernel(const ray* r1, const ray* r2, int* isEqual) {
	*isEqual = *r1 == *r2 ? 1 : 0;
}

void equate_ray_cu() {
	ray *r1, *r2;
	int *isEqual;

	cudaMallocManaged(&r1, sizeof(ray));
	cudaMallocManaged(&r2, sizeof(ray));
	cudaMallocManaged(&isEqual, sizeof(int));

	*r1 = init_ray();
	*r2 = *r1;

	equate_ray_kernel<<<1, 1>>>(r1, r2, isEqual);
    cudaDeviceSynchronize();

	assert(*isEqual == 1);

	cudaFree(r1);
	cudaFree(r2);
	cudaFree(isEqual);
}

void equate_ray_cpp() {
	const ray r1 = init_ray(), r2 = r1;
	bool isEqual = r1 == r2;
	assert(isEqual);
}

struct equate_ray {
	void operator()() {
		// Test for floating point accuracy on both CPU & GPU
		equate_ray_cpp();
		equate_ray_cu();
	}
};

int main() {
	run_tests<equate_ray, 64>();
	return 0;
}
