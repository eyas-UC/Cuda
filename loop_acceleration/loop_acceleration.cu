#include <stdio.h>





__global__ void add_two(int* array,int array_size)
{
	// get the flattened index
	int i = blockIdx.x * blockDim.x+ threadIdx.x;
	int stride =gridDim.x * blockDim.x; //total no of threads in grid


	for (int k = i; k <array_size ; k+=stride)
	{
		array[k]+=2;
	}
}


int main()
{
	int N = 2<<10;
	// create a pointer and allocate memory for it
	printf("starting things\n");
	int * arr;
	size_t size = N * sizeof(int);
	cudaMallocManaged(&arr, size);
	// set values with 2
	cudaMemset(arr,0, size);
	printf("N=%i and size=%i\n",(int)N,(int)size);
	 // run the cuda kernel;
	add_two<<<8,16>>>(arr,N);// setting lower threads and blocks than actual data
	cudaDeviceSynchronize();


	bool all_good = true;
	for(size_t i = 0; i<N;i++)
	{
		if(arr[i]!=2)
		{
			printf("arr[%i] = %i\n", (int)i,arr[i]);
			all_good =false;
			break;
		}
	}
	printf("%s",(all_good)?"all went well!\n":"something wrong\n" );
	cudaFree(arr);
}
