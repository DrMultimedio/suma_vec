
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>

__global__ void addKernel(int *c, const int *a, const int *b)
{

}

void suma_vectores
(
	float *pA,
	float *pB,
	float *pC,
	const int & crNumElements
)
{
	for (int i = 0; i < crNumElements; ++i)
	{
		pC[i] = pA[i] + pB[i];
	}
}
__global__

void kernel_suma_vectores
(
	const float* cpA,
	const float* cpB,
	float* pC,
	const int cNumElements
)
{
	int idx = blockDim.x * blockIdx.x + threadIdx.x;
	pC[idx] = cpA[idx] + cpB[idx];
}
int main()
{
    //paso 1 -> Inicialización
	cudaSetDevice(0); //Esta función le dice al framework: voy a usar la tarjeta x

	//paso 2 -> Declaración y reserva
	const int kNumElements = 25600; //numero al azar
	size_t kNumBytes = kNumElements * sizeof(float); //bytes totales para reservar y pasarselo al malloc
	//declaro los vectores en la CPU (HOST)
	float *h_A_ = (float *)malloc(kNumBytes);
	float *h_B_ = (float *)malloc(kNumBytes);
	float *h_C_ = (float *)malloc(kNumBytes);

	if (h_A_ == NULL || h_B_ == NULL || h_C_ == NULL) {
		std::cerr << "La memoria ha fallado lol \n";
		getchar();
		exit(-1);
	}
	float* d_A_ = NULL;
	float* d_B_ = NULL;
	float* d_C_ = NULL;

	//declaro los vectores en la GPU (HOST)
	cudaMalloc((void **)&d_A_, kNumBytes);
	cudaMalloc((void **)&d_B_, kNumBytes);
	cudaMalloc((void **)&d_C_, kNumBytes);

	//le ponemos numeros aleatorios en lugar de los que les apetezca al cacharro

	for (int i = 0; i < kNumElements; ++i)
	{
		h_A_[i] = rand() / RAND_MAX;
		h_B_[i] = rand() / RAND_MAX;
 	}
	
	//PASO 3: Transferencia CPU a la GPU

	cudaMemcpy(d_A_, h_A_, kNumBytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B_, h_B_, kNumBytes, cudaMemcpyHostToDevice);

	//PASO 4: Ejecución de le kernel

	const int threads_per_block_ = 256;
	const int blocks_per_grid_ = kNumElements / threads_per_block_;

	dim3 block(threads_per_block_, 1, 1);
	dim3 grid(blocks_per_grid_, 1, 1);

	kernel_suma_vectores<<<grid, block >>>(d_A_, d_B_, d_C_, kNumElements);
	cudaError_t err_ = cudaGetLastError();
	if (err_ != cudaSuccess)
	{
		std::cerr << cudaGetErrorString(err_) << "\n";
		getchar();
		exit(-1);
	}

	//paso 5: transferencia de la gpu a la cpu

	cudaMemcpy(h_C_, d_C_, kNumBytes, cudaMemcpyDeviceToHost);

	//paso 6: Comprobación y liberación

	for (int i = 0; i < kNumElements; i++) {
		if (fabs(h_A_[i] + h_B_[i] - h_C_[i]) > 1e-5) {
			std::cerr << "fallo de verificación en la posicion" << i << "\n";
		}
	}

	free(h_A_);
	free(h_B_);
	free(h_C_);
	cudaFree(d_A_);
	cudaFree(d_B_);
	cudaFree(d_C_);

	cudaDeviceReset();
	std::cout << "Test Passed \n";
	getchar();
}
