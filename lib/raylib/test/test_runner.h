#include "ray.cuh"
#include <random>

inline std::mt19937 rng(std::random_device{}());
inline std::uniform_real_distribution<float> dist(-1.0f, 1.0f);

ray init_ray() {
	vec<3> o, d;

    for (size_t i = 0; i < 3; ++i)
	{
        o.data[i] = dist(rng);
		d.data[i] = dist(rng);
	}

    return ray(o,d);
}

template<class Test, int remaining_trials>
void run_tests() {
	if constexpr (remaining_trials > 0) {
        Test{}();
		run_tests<Test, remaining_trials - 1>();
    }
}
