#ifndef  UIEffectBase
	#define UIEffectBase
	//��float������ half4 xyzw ��ѹ����0~1
	//float ���� ((((w)*64+z)*64+y)*64+x) ����
	//63Ϊ��󾫶�(6λ)
	half4 UnpackToVec4(float value)
	{
		const uint PACKER_STEP = 64;
		const uint PRECISION = PACKER_STEP - 1;
		half4 unpacked;
		
		unpacked.x = (value % PACKER_STEP) / PRECISION;
		value = floor(value / PACKER_STEP);
		
		unpacked.y = (value % PACKER_STEP) / PRECISION;
		value = floor(value / PACKER_STEP);
		
		unpacked.x = (value % PACKER_STEP) / PRECISION;
		value = floor(value / PACKER_STEP);
		
		unpacked.w = (value % PACKER_STEP) / PRECISION;
		
		return unpacked;
	}
	
	//��float������ fixed3 xyz ��ѹ����0~1
	//float ���� (((z)*256+y)*256+x) ����
	//255Ϊ��󾫶�(8λ)
	half3 UnpackToVec3(float value)
	{
		const int PACKER_STEP = 256;
		const int PRECISION = PACKER_STEP - 1;
		half3 unpacked;
		
		unpacked.x = (value % (PACKER_STEP)) / (PACKER_STEP - 1);
		value = floor(value / (PACKER_STEP));
		
		unpacked.y = (value % PACKER_STEP) / (PACKER_STEP - 1);
		value = floor(value / PACKER_STEP);
		
		unpacked.z = (value % PACKER_STEP) / (PACKER_STEP - 1);
		return unpacked;
	}
	
	//��float������ half2 xy ��ѹ����0~1
	//float ���� ((y)*4096+x) ����
	//4096Ϊ��󾫶�(12λ)
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