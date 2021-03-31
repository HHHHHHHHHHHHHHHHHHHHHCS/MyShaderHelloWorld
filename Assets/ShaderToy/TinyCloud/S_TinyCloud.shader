// https://blog.demofox.org/2017/11/26/dissecting-tiny-clouds/
// https://www.shadertoy.com/view/lsBfDz
// copy by: https://www.shadertoy.com/view/4tlBz8
Shader "Unlit/S_TinyCloud"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}
		LOD 100

		ZWrite Off
		ZTest Always
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _Noise;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}


			#define NUM_STEPS 200
			#define NUM_NOISE_OCTAVES 4

			#define HEIGHT_OFFSET 1.25

			#define USE_TEXTURE true
			#define WHITE_NOISE_GRID_SIZE 256.0

			// from "Hash without Sine" https://www.shadertoy.com/view/4djSRW
			#define HASHSCALE1 443.8975
			//  1 out, 2 in...
			float hash12(float2 p)
			{
				float3 p3 = frac(float3(p.xyx) * HASHSCALE1);
				p3 += dot(p3, p3.yzx + 19.19);
				return frac((p3.x + p3.y) * p3.z);
			}

			// NOTE: the bilinear interpolation is important! without it, the clouds look blocky.
			// You can see this by returning noise00 or by having the texture use the "nearest" filter
			float BilinearInterpolateWhiteNoise(float2 uv)
			{
				uv = frac(uv);

				float2 uvPixels = uv * WHITE_NOISE_GRID_SIZE;

				float2 uvFrac = uvPixels - floor(uvPixels);

				float2 uvDiscreteFloor = floor(uvPixels) / WHITE_NOISE_GRID_SIZE;
				float2 uvDiscreteCeil = ceil(uvPixels) / WHITE_NOISE_GRID_SIZE;

				float noise00 = hash12(float2(uvDiscreteFloor.x, uvDiscreteFloor.y));
				float noise01 = hash12(float2(uvDiscreteFloor.x, uvDiscreteCeil.y));
				float noise10 = hash12(float2(uvDiscreteCeil.x, uvDiscreteFloor.y));
				float noise11 = hash12(float2(uvDiscreteCeil.x, uvDiscreteCeil.y));

				float noise0_ = lerp(noise00, noise01, uvFrac.y);
				float noise1_ = lerp(noise10, noise11, uvFrac.y);

				float noise = lerp(noise0_, noise1_, uvFrac.x);

				return noise;
			}

			float RandomNumber(in float3 position)
			{
				// NOTE: the ceil here is important interestingly. it makes the clouds look round and puffy instead of whispy in a glitchy way
				float2 uv = (position.yz + ceil(position.x)) / float(NUM_STEPS);

				if (USE_TEXTURE)
					return tex2D(_Noise, uv).b;
				else
					return BilinearInterpolateWhiteNoise(uv);
			}

			float4 mainImage(float2 fragCoord)
			{
				float4 fragColor = 0;


				// x,y,z is the direction the ray for this pixel travels in.
				// x is into the screen
				// y is the screen's x axis. the left side is -0.8 and the right side value depends on the aspect ratio seems to be be roughly +0.8 for me.
				// z is the screen's y axis (also the up axis). it ranges from -0.8 at the bottom of the screen to 0.2 at the top of the screen
				// NOTE: in tiny clouds, this is a float4 where the y field is unused. I've made it a float3 and removed the y field.
				float3 direction = float3(0.8, fragCoord / _ScreenParams.y - 0.8);

				// this is a sky blue color
				// NOTE: tiny clouds gets the 0.8 from direction.x
				float3 skyColor = float3(0.6, 0.7, 0.8);

				// initialize the pixel color to a gradient of sky blue (at top) to white (at bottom)
				float3 pixelColor = skyColor - direction.z;

				// Tiny clouds adds a per pixel value to rayStep that is in [-1,1].
				// I think that gives it some higher frequency noise to make the clouds look a little more detailed.  
				// NOTE: this ray marches back to front so that alpha blending math is easier
				for (int rayStep = 0; rayStep < NUM_STEPS; ++rayStep)
				{
					// NOTE: tiny clouds has position as a float4 but never uses the y component. I removed it here.
					// position.z is up
					float3 position = 0.05 * float(NUM_STEPS - rayStep) * direction;

					// move the camera on the x and z axis over time
					position.xy += _Time.y;

					// tiny clouds initializes this to 2.0, but whenever using it divides it by 4. So, just dividing 2 by 4 here.
					float noiseScale = 0.5;

					// Note: position.z is the height. adding this moves the camera up. tiny clouds uses 1.0
					float signedCloudDistance = position.z + HEIGHT_OFFSET;

					// Note: each sampling doubles the position but halves the value read there. it's multiple octaves of noise i think?        
					for (int octaveIndex = 0; octaveIndex < NUM_NOISE_OCTAVES; ++octaveIndex)
					{
						position *= 2.0;
						noiseScale *= 2.0;
						signedCloudDistance -= RandomNumber(position) / noiseScale;
					}

					// Note: signed cloud distance is also cloud density if negative.
					// the below is equivelant to a lerp between the current pixel color and the color that the cloud is at that location.
					// the lerp amount is controlled by the density time 0.4.
					// The color is reversed so it "looks like" the sky color.
					// Lerping is equivelant to standard alpha blending, so we are just doing alpha compositing.
					if (signedCloudDistance < 0.0)
						pixelColor = pixelColor + (pixelColor - 1.0 - signedCloudDistance * skyColor.zyx) *
							signedCloudDistance * 0.4;
				}

				fragColor.rgb = pixelColor;
				fragColor.a = 1.0;

				return fragColor;
			}


			float4 frag(v2f i) : SV_Target
			{
				float4 col = mainImage(i.vertex.xy);
				return pow(col, 2.2);
			}
			ENDCG
		}
	}
}