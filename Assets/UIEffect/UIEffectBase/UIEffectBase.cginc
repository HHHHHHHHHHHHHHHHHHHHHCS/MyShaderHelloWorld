#ifndef  UIEffectBase
	#define UIEffectBase
	
	#if GRASYSCALE | SEPIA | NEGA | PIXEL | MONO | CUTOFF | HUE
		#define UI _TONE
	#endif
	
	#if ADD | SUBTRACT | FILLMODE
		#define UI_COLOR
	#endif
	
	#if FASTBLUR | MEDIUMBLUR | DETAILBLUR
		#define UI_BLUR
	#endif
	
	//把float解析成 fixed4 xyzw 被压缩成0~1
	//float 按照 ((((w)*64+z)*64+y)*64+x) 储存
	//63为最大精度(6位)
	fixed4 UnpackToVec4(float value)
	{
		const int PACKER_STEP = 64;
		const int PRECISION = PACKER_STEP - 1;
		fixed4 unpacked;
		
		unpacked.x = (value % PACKER_STEP) / PRECISION;
		value = floor(value / PACKER_STEP);
		
		unpacked.y = (value % PACKER_STEP) / PRECISION;
		value = floor(value / PACKER_STEP);
		
		unpacked.x = (value % PACKER_STEP) / PRECISION;
		value = floor(value / PACKER_STEP);
		
		unpacked.w = (value % PACKER_STEP) / PRECISION;
		
		return unpacked;
	}
	
	//把float解析成 fixed3 xyz 被压缩成0~1
	//float 按照 (((z)*256+y)*256+x) 储存
	//255为最大精度(8位)
	fixed3 UnpackToVec3(float value)
	{
		const int PACKER_STEP = 256;
		const int PRECISION = PACKER_STEP - 1;
		fixed3 unpacked;
		
		unpacked.x = (value % (PACKER_STEP)) / (PACKER_STEP - 1);
		value = floor(value / (PACKER_STEP));
		
		unpacked.y = (value % PACKER_STEP) / (PACKER_STEP - 1);
		value = floor(value / PACKER_STEP);
		
		unpacked.z = (value % PACKER_STEP) / (PACKER_STEP - 1);
		return unpacked;
	}
	
	//把float解析成 half2 xy 被压缩成0~1
	//float 按照 ((y)*4096+x) 储存
	//4096为最大精度(12位)
	half2 UnpackToVec2(float value)
	{
		const int PACKER_STEP = 4096;
		const int PRECISION = PACKER_STEP - 1;
		half2 unpacked;
		
		unpacked.x = (value % (PACKER_STEP)) / (PACKER_STEP - 1);
		value = floor(value / (PACKER_STEP));
		
		unpacked.y = (value % PACKER_STEP) / (PACKER_STEP - 1);
		return unpacked;
	}
#endif