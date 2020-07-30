#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>




void dec_bin(unsigned long long dec,int * vet)//int vet[])
{
	int i=0;
	
	for(i=0;i<34;i++)
	{
		vet[34-1-i]=dec%2;
		dec=dec/2;
	}
}

void dec_bin2(unsigned long long dec,int vet[])
{
	int i=0;
	
	for(i=0;i<2;i++)
	{
		vet[2-1-i]=dec%2;
		dec=dec/2;
	}
}


void dec_bin64(unsigned long long dec,int * vet1)
{
	int j=0;
	
	for(j=0;j<64;j++)
	{		
		vet1[64-1-j]=dec%2;
		dec=dec/2;
	}
}




unsigned long long esa_dec(char * esa)
{
	int len=strlen(esa);
	int i=0;
	unsigned long long dec=0;

	for (i=0;i<=len-1;i++)
	{
		if (esa[i]>='A' && esa[i]<='F')
		{
			unsigned long long prova=esa[i]-'A'+10;
			unsigned long long  prova2=pow(16,(len-1)-i);
			unsigned long long prova22=prova*prova2;
			dec=dec+prova22;
		}
		else {
			unsigned long long prova3=esa[i]-'0';
			unsigned long long  prova4=pow(16,(len-1)-i);
			unsigned long long prova5=(esa[i]-'0')*pow(16,(len-1)-i);
			dec=dec+prova5;
		}
		
	}
	
	return dec;
}



void print32(char * s,int voidbit,int out,char * time,int k)
	{
	FILE * fc;
	int * vet=(int *) calloc(34,sizeof(int));
	fc=fopen("stim5.txt","a");

	dec_bin(esa_dec(s),vet);

	fprintf(fc,"%d %s ",k,time);

	// print instruction 
	fprintf(fc,"00000000000000000000000000000000");
	for (int i=0;i<34;i++)
	{
		fprintf(fc,"%d",vet[i]);
	}


	//printf void bit
	fprintf(fc,"%d",voidbit);


	//print source/destination noc plane
	fprintf(fc,"000010");



	//print the opcode to inform the testing logic whether
	//it is an expected request from CPU or a response to
	//send to the CPU
	if (out==1)
	{
		fprintf(fc,"11 \n");
	}
	else
	{
		fprintf(fc,"01 \n");
	}
	free(vet);

	
	fclose(fc);
	}


void print64(char * s1,int voidbit, int noc, int out,char * time,int k)
	{
		FILE * fc;
		char s2[2];
		char s3[17];
		int vet2[2];
		int * vet1 = (int*) calloc(64,sizeof(int));
		int testin[72];

		if (noc==1)
		{
			fc=fopen("stim1.txt","a");
		}
		else if(noc==2)
		{
			fc=fopen("stim2.txt","a");
		}
		else if (noc==3)
		{
			fc=fopen("stim3.txt","a");
		}
		else if (noc==4)
		{
			fc=fopen("stim4.txt","a");
		}
		else if (noc==6)
		{
			fc=fopen("stim6.txt","a");
		}
		
		fprintf(fc,"%d %s ",k,time);

		// print the instruction (66 bits)
		memcpy(s2,&s1[0], 1);
		s2[1]='\0';
		memcpy(s3, &s1[1], 16);
		s3[16]='\0';

	
		dec_bin2(esa_dec(s2),vet2);
		dec_bin64(esa_dec(s3),vet1);
					
		for (int i=0;i<2;i++)
		{
			fprintf(fc,"%d",vet2[i]);
		}
		for (int i=0;i<64;i++)
		{
			fprintf(fc,"%d",vet1[i]);
		}


		
		// printf the void bit 
		fprintf(fc,"%d",voidbit);


		
		// print the source/destination noc plane 
		if (noc==1)
		       {
			       fprintf(fc,"100000");
		       }
		else if (noc==2)
		{
			fprintf(fc,"010000");
		}
		else if (noc==3)
		{
			fprintf(fc,"001000");
		}
		else if(noc==4)
		{
			fprintf(fc,"000100");
		}
		else if(noc==6)
		{
			fprintf(fc,"000001");
		}
		
		
		//print the opcode to inform the testing logic whether
		//it is an expected request from CPU or a response to
		//send to the CPU
		if (out==1)
		{
			
			fprintf(fc,"%s","11 \n");
		}
		else
		{
			fprintf(fc,"%s","01 \n");
		}
				
		fclose(fc);
	}








int main () {
	FILE *fp;
	FILE *fc;
	char buf[410];

	fp = fopen("list.lst" , "r");
	fc = fopen("stim1.txt","w");
	fclose(fc);
	fc = fopen("stim2.txt","w");
	fclose(fc);
	fc = fopen("stim3.txt","w");
	fclose(fc);
	fc= fopen("stim4.txt","w");
	fclose(fc);
	fc= fopen("stim5.txt","w");
	fclose(fc);
	fc= fopen("stim6.txt","w");
	fclose(fc);
	
	char * time;

	char * noc1;
	char * void1;
	char * stop1;

	char * noc2_out;
	char * void2_out;
	char * stop2_out;
	
	char * noc3;
	char * void3;
	char * stop3;

	char * noc3_out;
	char * void3_out;
	char * stop3_out;
	
	char * noc4;
	char * void4;
	char * stop4;

	char * noc4_out;
	char * void4_out;
	char * stop4_out;
	
	char * noc5;
	char * void5;
	char * stop5;

	char * noc5_out;
	char * void5_out;
	char * stop5_out;

	char * noc6;
	char * void6;
	char * stop6;
	
	char * noc6_out;
	char * void6_out;
	char * stop6_out;
	
	const char separators[]=" \n \0";
	char subnoc1[18];
	char * subnoc1_old=(char*) malloc(18*sizeof(char));
	char * bitvoid1_old=(char*) malloc(2*sizeof(char));

	char subnoc2_out[18];
	char * subnoc2_out_old=(char*) malloc(18*sizeof(char));
	char * bitvoid2_out_old=(char*) malloc(2*sizeof(char));

	
	char subnoc3[18];
	char * subnoc3_old=(char*) malloc(18*sizeof(char));
	char * bitvoid3_old=(char*) malloc(2*sizeof(char));

	char subnoc3_out[18];
	char * subnoc3_out_old=(char*) malloc(18*sizeof(char));
	char * bitvoid3_out_old=(char*) malloc(2*sizeof(char));
	
	char subnoc4[18];
	char * subnoc4_old=(char*) malloc(18*sizeof(char));
	char * bitvoid4_old=(char*) malloc(2*sizeof(char));

	
	char subnoc4_out[18];
	char * subnoc4_out_old=(char*) malloc(18*sizeof(char));
	char * bitvoid4_out_old=(char*) malloc(2*sizeof(char));
	

	char subnoc5[10];
	char * subnoc5_old=(char*) malloc(10*sizeof(char));
	char * bitvoid5_old=(char*) malloc(2*sizeof(char));

	char subnoc5_out[10];
	char * subnoc5_out_old=(char*) malloc(10*sizeof(char));
	char * bitvoid5_out_old=(char*) malloc(2*sizeof(char));


	char subnoc6[10];
	char * subnoc6_old=(char*) malloc(10*sizeof(char));
	char * bitvoid6_old=(char*) malloc(2*sizeof(char));

	
	char subnoc6_out[18];
	char * subnoc6_out_old=(char*) malloc(18*sizeof(char));
	char * bitvoid6_out_old=(char*) malloc(2*sizeof(char));
	
	char bitvoid1[2];
	char bitvoid2_out[2];
	char bitvoid3[2];
	char bitvoid3_out[2];
	char bitvoid4[2];
	char bitvoid4_out[2];
	char bitvoid5[2];
	char bitvoid5_out[2];
	char bitvoid6[2];
	char bitvoid6_out[2];

	char s[]="000000000";
	
	int k=0;

	if (fp == NULL){
		perror("error opening file");
		exit(1);
		
	}

	while (fgets (buf, sizeof(buf), fp) !=NULL )
	{


		
		time=strtok(buf,separators);

		
		noc1=strtok(NULL,separators);
		memcpy(subnoc1, &noc1[4], 17);
		subnoc1[17]='\0';
		void1=strtok(NULL,separators);
		memcpy(bitvoid1, &void1[3], 1);
		bitvoid1[1]='\0';
		stop1=strtok(NULL,separators);
		

		
		noc2_out=strtok(NULL,separators);
		memcpy(subnoc2_out, &noc2_out[4], 17);
		subnoc2_out[17]='\0';
		void2_out=strtok(NULL,separators);
		memcpy(bitvoid2_out, &void2_out[3], 1);
		bitvoid2_out[1]='\0';
		stop2_out=strtok(NULL,separators);

		
		noc3=strtok(NULL,separators);
		memcpy(subnoc3, &noc3[4], 17);
		subnoc3[17]='\0';
		void3=strtok(NULL,separators);
		memcpy(bitvoid3, &void3[3], 1);
		bitvoid3[1]='\0';
		stop3=strtok(NULL,separators);

		
		noc3_out=strtok(NULL,separators);
		memcpy(subnoc3_out, &noc3_out[4], 17);
		subnoc3_out[17]='\0';
		void3_out=strtok(NULL,separators);
		memcpy(bitvoid3_out, &void3_out[3], 1);
		bitvoid3_out[1]='\0';
		stop3_out=strtok(NULL,separators);



		
		noc4=strtok(NULL,separators);
		memcpy(subnoc4, &noc4[4], 17);
		subnoc4[17]='\0';
		void4=strtok(NULL,separators);
		memcpy(bitvoid4, &void4[3], 1);
		bitvoid4[1]='\0';
		stop4=strtok(NULL,separators);

		
		noc4_out=strtok(NULL,separators);
		memcpy(subnoc4_out, &noc4_out[4], 17);
		subnoc4_out[17]='\0';
		void4_out=strtok(NULL,separators);
		memcpy(bitvoid4_out, &void4_out[3], 1);
		bitvoid4_out[1]='\0';
		stop4_out=strtok(NULL,separators);

		

		noc5=strtok(NULL,separators);
		memcpy(subnoc5, &noc5[4], 10);
		subnoc5[10]='\0';
		void5=strtok(NULL,separators);
		memcpy(bitvoid5, &void5[3], 1);
	        bitvoid5[1]='\0';
		stop5=strtok(NULL,separators);

		
		noc5_out=strtok(NULL,separators);
		memcpy(subnoc5_out, &noc5_out[4], 10);
                subnoc5_out[10]='\0';
		void5_out=strtok(NULL,separators);
		memcpy(bitvoid5_out, &void5_out[3], 1);
		bitvoid5_out[1]='\0';
		stop5_out=strtok(NULL,separators);



		noc6=strtok(NULL,separators);
		memcpy(subnoc6, &noc6[4], 10);
		subnoc6[10]='\0';
		void6=strtok(NULL,separators);
		memcpy(bitvoid6, &void6[3], 1);
	        bitvoid6[1]='\0';
		stop6=strtok(NULL,separators);

		
		
		noc6_out=strtok(NULL,separators);
		memcpy(subnoc6_out, &noc6_out[4], 10);
                subnoc6_out[10]='\0';
		void6_out=strtok(NULL,separators);
		memcpy(bitvoid6_out, &void6_out[3], 1);
		bitvoid6_out[1]='\0';
		stop6_out=strtok(NULL,separators);


		
		 if (atoi(bitvoid1)==0)
		 {
			 
			 if (strcmp(subnoc1,subnoc1_old)!=0 || strcmp(bitvoid1,bitvoid1_old)!=0)
			 {
				 k=k+1;
				 print64(subnoc1,0,1,0,time,k);
			 }
		 }
		 if (atoi(bitvoid2_out)==0)
		 {
			 
			 if (strcmp(subnoc2_out,subnoc2_out_old)!=0 || strcmp(bitvoid2_out,bitvoid2_out_old)!=0)
			 {
				 k=k+1;
				 print64(subnoc2_out,0,2,1,time,k);
			 }
		 }


		 if (atoi(bitvoid3)==0)
		 {

			 
			 if (strcmp(subnoc3,subnoc3_old)!=0 || strcmp(bitvoid3,bitvoid3_old)!=0)
			 {
				 k=k+1;
				 print64(subnoc3,0,3,0,time,k);
			 }
		 }

		 if (atoi(bitvoid3_out)==0)
		 {

			 
			 if (strcmp(subnoc3_out,subnoc3_out_old)!=0 || strcmp(bitvoid3_out,bitvoid3_out_old)!=0)
			 {
				 
				 k=k+1;
				 print64(subnoc3_out,0,3,1,time,k);
			 }
		 }


		 if (atoi(bitvoid4)==0)
		 {

			 
			 if (strcmp(subnoc4,subnoc4_old)!=0 || strcmp(bitvoid4,bitvoid4_old)!=0)
			 {
				 k=k+1;
				 print64(subnoc4,0,4,0,time,k);
			 }
		 }


		 if (atoi(bitvoid4_out)==0)
		 {

			 
			 if (strcmp(subnoc4_out,subnoc4_out_old)!=0 || strcmp(bitvoid4_out,bitvoid4_out_old)!=0)
			 {
				 
				 k=k+1;
				 print64(subnoc4_out,0,4,1,time,k);
			 }
		 }

		 

		 
		 if (atoi(bitvoid5)==0)
		 {
			 
			 if (strcmp(subnoc5,subnoc5_old)!=0 || strcmp(bitvoid5,bitvoid5_old)!=0)
			 {
				 k=k+1;
				 print32(subnoc5,0,0,time,k);
			 }
		 }
		 if (atoi(bitvoid5_out)==0)
		 {
			 if (strcmp(subnoc5_out,subnoc5_out_old)!=0 || strcmp(bitvoid5_out,bitvoid5_out_old)!=0)
			 {
				 k=k+1;
				 print32(subnoc5_out,0,1,time,k);
			 }
		 }




		 if (atoi(bitvoid6)==0 &&  bitvoid6[0]!='X')
		 {

			 printf("%s %s \n", subnoc6, bitvoid6); 
			 if (strcmp(subnoc6,subnoc6_old)!=0 || strcmp(bitvoid6,bitvoid6_old)!=0)
			 {
				 k=k+1;
				 print64(subnoc6,0,6,0,time,k);
			 }
		 }



		 
		 if (atoi(bitvoid6_out)==0)
		 {

			 if (strcmp(subnoc6_out,subnoc6_out_old)!=0 || strcmp(bitvoid6_out,bitvoid6_out_old)!=0)
			 {
				 k=k+1;
				 print64(subnoc6_out,0,6,1,time,k);
			 }
		 }



		 
		 memcpy(subnoc1_old,&subnoc1[0],18);
		 memcpy(bitvoid1_old,&bitvoid1[0],2);

		 memcpy(subnoc2_out_old,&subnoc2_out[0],18);
		 memcpy(bitvoid2_out_old,&bitvoid2_out[0],2);
		 
		 memcpy(subnoc3_old,&subnoc3[0],18);
		 memcpy(bitvoid3_old,&bitvoid3[0],2);

		 memcpy(subnoc3_out_old,&subnoc3_out[0],18);
		 memcpy(bitvoid3_out_old,&bitvoid3_out[0],2);

		 memcpy(subnoc4_old,&subnoc4[0],18);
		 memcpy(bitvoid4_old,&bitvoid4[0],2);

		 memcpy(subnoc4_out_old,&subnoc4_out[0],18);
		 memcpy(bitvoid4_out_old,&bitvoid4_out[0],2);
		 
		 memcpy(subnoc5_old,&subnoc5[0],10);
		 memcpy(bitvoid5_old,&bitvoid5[0],2);
		 
		 memcpy(subnoc5_out_old,&subnoc5_out[0],10);
		 memcpy(bitvoid5_out_old,&bitvoid5_out[0],2);

		 memcpy(subnoc6_old,&subnoc6[0],10);
		 memcpy(bitvoid6_old,&bitvoid6[0],2);
		 
		 memcpy(subnoc6_out_old,&subnoc6_out[0],18);
		 memcpy(bitvoid6_out_old,&bitvoid6_out[0],2);

		 
	}

	fc=fopen("stim1.txt","a");
	fprintf(fc,"0 0 000000000000000000000000000000000000000000000000000000000000000000000000001");
	fclose(fc);

	fc=fopen("stim2.txt","a");
	fprintf(fc,"0 0 000000000000000000000000000000000000000000000000000000000000000000000000001");
	fclose(fc);

	fc=fopen("stim3.txt","a");
	fprintf(fc,"0 0 000000000000000000000000000000000000000000000000000000000000000000000000001");
	fclose(fc);

	fc=fopen("stim4.txt","a");
	fprintf(fc,"0 0 000000000000000000000000000000000000000000000000000000000000000000000000001");
	fclose(fc);

	fc=fopen("stim5.txt","a");
	fprintf(fc,"0 0 000000000000000000000000000000000000000000000000000000000000000000000000001");
	fclose(fc);

	fc=fopen("stim6.txt","a");
	fprintf(fc,"0 0 000000000000000000000000000000000000000000000000000000000000000000000000001");
	fclose(fc);
		
	
}
	


		
