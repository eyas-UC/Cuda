#include <stdio.h>


__global__ void hello()
{
//# if __CUDA_ARCH__>=200
	printf("ThreadIDx=%i, BlockIdx=%i \n",threadIdx.x,blockIdx.x);

//#endif 
}

int main()
{
	
	hello<<<32,32>>>();
	cudaDeviceSynchronize();
}
