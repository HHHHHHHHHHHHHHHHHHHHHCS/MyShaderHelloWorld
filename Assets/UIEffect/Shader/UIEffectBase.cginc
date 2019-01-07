#ifndef  UIEffectBase
	#define UIEffectBase
	
	#if ADD | SUBTRACT | FILL
		#define UI_COLOR
	#endif
	
	//把float解析成 half4 xyzw 被压缩成0~1
	//float 按照 ((((w)*64+z)*64+y)*64+x) 储存
	//63为最大精度(6位)
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
	
	//把float解析成 half3 xyz 被压缩成0~1
	//float 按照 (((z)*256+y)*256+x) 储存
	//255为最大精度(8位)
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
	
	//根据ColorMode,设置颜色效果
	half4 ApplyColorEffect(half4 color, half4 factor)
	{
		#ifdef FILL//颜色替换
			color.rgb = lerp(color.rgb, factor.rgb, factor.a);
		#elif ADD//颜色叠加
			color.rgb += factor.rgb * factor.a;
		#elif SUBTRACT//颜色相减
			color.rgb -= factor.rgb * factor.a;
		#else//颜色相乘
			color.rgb = lerp(color.rgb, color.rgb * factor.rgb, factor.a);
		#endif
		
		#if CUTOFF//是否设置了裁剪
			color.a = factor.a;
		#endif
		
		return color;
	}

	//模糊用
	//Fast:3x3 EX:5x5
	//Medium:5x5 EX:9x9
	//Detail:7x7 EX:13x13
	fixed4 Tex2DBlurring(sampler2D tex,half2 texcood,half2 blur,half4 mask)
	{
		#if FASTBLUR && EX
		const int KERNEL_SIZE = 5;
		const float KERNEL_[5] = { 0.2486, 0.7046, 1.0, 0.7046, 0.2486};
		#elif MEDIUMBLUR && EX
		const int KERNEL_SIZE = 9;
		const float KERNEL_[9] = { 0.0438, 0.1719, 0.4566, 0.8204, 1.0, 0.8204, 0.4566, 0.1719, 0.0438};
		#elif DETAILBLUR && EX
		const int KERNEL_SIZE = 13;
		const float KERNEL_[13] = { 0.0438, 0.1138, 0.2486, 0.4566, 0.7046, 0.9141, 1.0, 0.9141, 0.7046, 0.4566, 0.2486, 0.1138, 0.0438};
		#elif FASTBLUR
		const int KERNEL_SIZE = 3;
		const float KERNEL_[3] = { 0.4566, 1.0, 0.4566};
		#elif MEDIUMBLUR
		const int KERNEL_SIZE = 5;
		const float KERNEL_[5] = { 0.2486, 0.7046, 1.0, 0.7046, 0.2486};
		#elif DETAILBLUR
		const int KERNEL_SIZE = 7;
		const float KERNEL_[7] = { 0.1719, 0.4566, 0.8204, 1.0, 0.8204, 0.4566, 0.1719};
		#else
		const int KERNEL_SIZE = 1;
		const float KERNEL_[1] = { 1.0 };
		#endif

		float4 o = 0;
		float sum = 0;
		float2 shift = 0;

		for(int x=0;x<KERNEL_SIZE;X++)
		{
			shift.x=blur.x*(float(x)-KERNEL_SIZE/2);//采样偏移的X点
			for(int y=0;y<KERNEL_SIZE;Y++)
			{
				shift.y=blur.y*(float(y)-KERNEL_SIZE/2);
				float2 uv = texcood+shift;
				float weight = KERNEL_[x]*KERNEL_[y];//模糊权重
				sum+=weight;
				if EX//如果是EX模糊,临界变用半透明,外面用透明
				fixed masked = min(mask.x<=uv.x,uv.x<=mask.z)*min(mask.y<=uv.y,uv.y<=mask.w);
				o+=lerp(fixed4(0.5,0.5,0.5,0),tex2D(tex,uv),masked)*weight;
				#else 
				o+=tex2D(tex,uv)*weight;
				#endif
			}
		}
		return o/sum;
	}
#endif