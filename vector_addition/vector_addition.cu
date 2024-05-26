#include <stdio.h>




/* A,B input arrays and C is the output and they all have the same size*/
__global__ void add_vectors(int* A,int* B, int* C, int array_size)
{
	// get the flattened index
	int i = blockIdx.x * blockDim.x+ threadIdx.x;
	int stride =gridDim.x * blockDim.x; //total no of threads in grid

	for (int k = i; k <array_size ; k+=stride)
	{
		C[k]=A[k] + B[k];
	}
}


int main()
{
	int N = 2<<8;
	cudaError_t syncE, asyncE;
	// create a pointer and allocate memory for it
	printf("starting things\n");
	int * arrA,*arrB, *arrC;
	size_t size = N * sizeof(int);
	cudaMallocManaged(&arrA, size);
	cudaMallocManaged(&arrB, size);
	cudaMallocManaged(&arrC, size);
	// initialization
	for(int j = 0; j < N; j++)
	{
		arrA[j]=10;
		arrB[j]=10;
		arrC[j]= 0;
	}
	printf("N=%i and size=%i\n",(int)N,(int)size);
	 // run the cuda kernel;
	add_vectors<<<8,16>>>(arrA,arrB,arrC,N);// setting lower threads and blocks than actual data
	syncE = cudaGetLastError();
	asyncE = cudaDeviceSynchronize();
	printf("%s",syncE != cudaSuccess? "synchronous Error occured\n":"Great!...No synchronous Error\n");
	printf("%s",asyncE != cudaSuccess? "asynchronous Error occured\n":"Great!...No asynchronous Error\n");

	bool all_good = true;
	for(size_t i = 0; i<N;i++)
	{
		if(arrC[i]!=20)
		{
			printf("arr[%i] = %i\n", (int)i,arrC[i]);
			all_good =false;
			break;
		}
	}
	printf("%s",(all_good)?"all went well!\n":"something wrong\n" );
	// free allocated memory
	cudaFree(arrA);
	cudaFree(arrB);
	cudaFree(arrC);
}
