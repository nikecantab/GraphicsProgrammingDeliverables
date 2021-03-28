#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

Texture2D _MainTex;
sampler2D _MainTexSampler = sampler_state 
{
	Texture = <_MainTex>;
};

float4 NoFXPS(float2 uv : VPOS) : COLOR
{
	uv = (uv + 0.5) * float2(1.0 / 1080.0, 1.0 / 1080.0);
	float4 color = tex2D(_MainTexSampler, uv);
	//#if OPENGL
		//uv.y = 1 - uv.y;
	//#endif

		return color;
}

technique NoFX
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL NoFXPS();
	}
};


float4 MonochromePS(float2 uv : VPOS) : COLOR
{
	uv = (uv + 0.5) * float2(1.0 / 1080.0, 1.0 / 1080.0);
	float4 color = tex2D(_MainTexSampler, uv);

	float3 luminosity = float3(0.299, 0.587, 0.114);
	color.rgb = dot(color.rgb, luminosity);

	//color.rgb = lerp( dot( float3(1,1,1), color.rgb) * 0.3333, c, 0);

	//#if OPENGL
		//uv.y = 1 - uv.y;
	//#endif

	return color;
}

technique Monochrome
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL MonochromePS();
	}
};

float4 SelectiveColorSwapPS(float2 uv : VPOS) : COLOR
{
	uv = (uv + 0.5) * float2(1.0 / 1080.0, 1.0 / 1080.0);
	float4 color = tex2D(_MainTexSampler, uv);

	float3 test_color = float3(0, 0, 0);
	float3 new_color = float3(.6, 0, 0);
	float threshold = .6;

	float3 diff = test_color - color.rgb;

	if (abs(length(diff)) <= threshold)
	{
		color.rgb = new_color * (float3(1, 1, 1) - diff);
	}

	return color;
}

technique SelectiveColorSwap
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL SelectiveColorSwapPS();
	}
};


float4 InvertPS( float2 uv : VPOS ) : COLOR
{
	uv = (uv + 0.5) * float2(1.0 / 1080.0, 1.0 / 1080.0);
	float4 color = tex2D(_MainTexSampler, uv);
//#if OPENGL
	//uv.y = 1 - uv.y;
//#endif

	return 1 - color;
}

technique Invert
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL InvertPS();
	}
};

float4 ChromaticAberrationPS( float2 uv : VPOS ) : COLOR
{
	uv = (uv + 0.5) * float2(1.0 / 1080.0, 1.0 / 1080.0);
//#if OPENGL
	//uv.y = 1 - uv.y;
//#endif

	float strength = 5;
	float3 rgbOffset = 1 + float3(0.01, 0.005, 0) * strength;
	float dist = distance(uv, float2(0.5, 0.5));
	float2 dir = uv - float2(0.5, 0.5);
	rgbOffset = normalize(rgbOffset * dist);

	float2 uvR = float2(0.5, 0.5) + rgbOffset.r * dir;
	float2 uvG = float2(0.5, 0.5) + rgbOffset.g * dir;
	float2 uvB = float2(0.5, 0.5) + rgbOffset.b * dir;

	float4 colorR = tex2D(_MainTexSampler, uvR);
	float4 colorG = tex2D(_MainTexSampler, uvG);
	float4 colorB = tex2D(_MainTexSampler, uvB);

	return float4(colorR.r, colorG.g, colorB.b, 1);
}

technique ChromaticAberration
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL ChromaticAberrationPS();
	}
};

//bloom

//snes pixellate effect