#if OPENGL
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

// External Properties
float4x4 World;
float4x4 View;
float4x4 Projection;

float3 LightDirection;
float3 ViewDirection;
float3 Ambient;

float3 CameraPosition;
float Time;

Texture2D DirtTex;
sampler2D DirtTextureSampler = sampler_state
{
    Texture = <DirtTex>;
    MipFilter = LINEAR;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
};

Texture2D SandTex;
sampler2D SandTextureSampler = sampler_state
{
    Texture = <SandTex>;
    MipFilter = LINEAR;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
};


Texture2D GrassTex;
sampler2D GrassTextureSampler = sampler_state
{
    Texture = <GrassTex>;
    MipFilter = LINEAR;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
};

Texture2D SnowTex;
sampler2D SnowTextureSampler = sampler_state
{
    Texture = <SnowTex>;
    MipFilter = LINEAR;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
};

TextureCube SkyTex;
samplerCUBE SkyTextureSampler = sampler_state
{
    Texture = <SkyTex>;
    magfilter = LINEAR;
    minfilter = LINEAR;
    mipfilter = LINEAR;
    AddressU = Mirror;
    AddressV = Mirror;
};


Texture2D PlantTex;
sampler2D PlantTextureSampler = sampler_state
{
    Texture = <PlantTex>;
    MipFilter = LINEAR;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
};


// Getting out vertex data from vertex shader to pixel shader
struct VertexShaderOutput {
    float4 position : SV_POSITION;
    float4 color : COLOR0;
    float2 tex : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    float3 texCube : TEXCOORD3;
    float3 binormal : TEXCOORD4;
    float3 tangent : TEXCOORD5;
};

// Vertex shader, receives values directly from semantic channels
VertexShaderOutput MainVS( float4 position : POSITION, float4 color : COLOR0, float3 normal : NORMAL, float3 binormal : BINORMAL, float3 tangent : TANGENT, float2 tex : TEXCOORD0 )
{
    VertexShaderOutput o = (VertexShaderOutput)0;

    o.position = mul( mul( mul(position, World), View ), Projection );
    o.color = color;
    o.normal = mul(normal, (float3x3)World);
    o.tex = tex;
    o.worldPos = mul(position, World);

    return o;
}

// Pixel Shader, receives input from vertex shader, and outputs to COLOR semantic
float4 MainPS(VertexShaderOutput input) : COLOR
{

    float d = distance(input.worldPos, CameraPosition);
    float dist1 = 200;
    float dist2 = 1000;

    // Sample texure
    //float3 dirtFar = tex2D(DirtTextureSampler, input.tex * 1).rgb;
    float3 dirtMid = tex2D(DirtTextureSampler, input.tex * 5).rgb;
    float3 dirtClose = tex2D(DirtTextureSampler, input.tex * 50).rgb;
    float3 dirt = lerp(dirtClose, dirtMid, clamp(d / dist1, 0, 1));
    /*float3 lerp2 = lerp(lerp1, dirtFar, clamp((d - dist1) / dist2, 0, 1));
    float3 texColor = lerp2;*/

    //texture blending

    float3 sandMid = tex2D(SandTextureSampler, input.tex * 5).rgb;
    float3 sandClose = tex2D(SandTextureSampler, input.tex * 100).rgb;
    float3 sand = lerp(sandClose, sandMid, clamp(d / dist1, 0, 1));

    //float3 dirtColor = float3(0, 0, 0);
    float3 grassMid = lerp(tex2D(GrassTextureSampler, input.tex * 5).rgb, float3(0.3,0.5,0.3), 0.8);
    float3 grassClose = tex2D(GrassTextureSampler, input.tex * 50).rgb;
    float3 grass = lerp(grassClose, grassMid, clamp(d / dist1, 0, 1));

    float3 rock = dirt * float3(.8, .8, .8);

    float3 snowMid = tex2D(SnowTextureSampler, input.tex * 10).rgb;
    float3 snowClose = tex2D(SnowTextureSampler, input.tex * 80).rgb;
    float3 snow = lerp(snowClose, snowMid, clamp(d / dist1, 0, 1));

    //height coloring
    float y = input.worldPos.y;
    float sandDirt = clamp((y - 80) / 10, -1, 1) * .5 + .5;
    float dirtGrass = clamp((y - 100) / 10, -1, 1) * .5 + .5;
    float grassRock = clamp((y - 150) / 10, -1, 1) * .5 + .5;
    float rockSnow = clamp((y - 200) / 10, -1, 1) * .5 + .5;
    //float3 blendedColors = float3(1, 1, 1) + lerp(lerp(dirtColor, grassColor, dirtGrass), snowColor, grassSnow);

    float3 texColor = lerp(
                            lerp( 
                                lerp(
                                    lerp(sand, dirt, sandDirt),
                                    grass, dirtGrass),
                            rock, grassRock),
                        snow, rockSnow);


    //fog
    float fogAmount = clamp((d - dist1) / dist2 * .5, 0, 1);
    float fogColor = float3(188, 214, 231) / 255.0;

    // Lighting calculation
    float3 lighting = max( dot(input.normal, LightDirection), 0.0) + Ambient;

    //all together
    float3 result = clamp(
                        lerp(texColor * lighting, fogColor, fogAmount),
                    0, 1);
    // Output
    return float4(result, 1);
}

VertexShaderOutput SkyVS(float4 position : POSITION, float3 normal : NORMAL, float2 tex : TEXCOORD0)
{
    VertexShaderOutput o = (VertexShaderOutput)0;

    o.position = mul(mul(mul(position, World), View), Projection);
    o.normal = mul(normal, (float3x3)World);
    o.worldPos = mul(position, World);

    float4 VertexPosition = mul(position, World);
    o.texCube = normalize(VertexPosition - CameraPosition);

    return o;
}

float4 SkyPS(VertexShaderOutput input) : COLOR
{
    float3 topColor = float3(68,118,189) / 255.0;
    float3 botColor = float3(188, 214, 231) / 255.0;

    float3 viewDirection = normalize(input.worldPos - CameraPosition);

    float sun = pow(max(dot(-viewDirection, LightDirection), 0.0), 512);
    float3 sunColor = float3(255, 200, 50);

    return float4(saturate(lerp(botColor, topColor, viewDirection.y) + sun * sunColor), 1);
}

float4 UnlitTransparentPS(VertexShaderOutput input) : COLOR
{
    float4 texColor = tex2D(PlantTextureSampler, input.tex);
    clip(texColor.a - .5);
    return texColor;
}

float4 LitTransparentPS(VertexShaderOutput input) : COLOR
{
    float4 texColor = tex2D(PlantTextureSampler, input.tex);
    clip(texColor.a - .5);
    //return texColor;

    float d = distance(input.worldPos, CameraPosition);
    float dist1 = 200;
    float dist2 = 1000;

    float fogAmount = clamp((d - dist1) / dist2 * .5, 0, 1);
    float fogColor = float3(188, 214, 231) / 255.0;

    // Lighting calculation
    float3 lighting = max(-dot(input.normal, LightDirection), 0.0) + Ambient; //something might be wrong with the normals, have to invert dot product
    lighting = clamp(lighting, 0, 1);
    //all together
    float3 result = clamp(
        lerp(texColor * lighting, fogColor, fogAmount),
        0.0, 1.0);

    // Output
    return float4(result,1);
}

technique Terrain
{
    pass
    {
        VertexShader = compile VS_SHADERMODEL MainVS();
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
};

technique SkyBox
{
    pass
    {
        VertexShader = compile VS_SHADERMODEL SkyVS();
        PixelShader = compile PS_SHADERMODEL SkyPS();
    }
};

technique UnlitTransparent
{
    pass
    {
        //AlphaBlendEnable = true;
        //SrcBlend = SrcAlpha;
        //DestBlend = InvSrcAlpha;
        VertexShader = compile VS_SHADERMODEL MainVS();
        PixelShader = compile PS_SHADERMODEL UnlitTransparentPS();
    }
};

technique LitTransparent
{
    pass
    {
        //AlphaBlendEnable = true;
        //SrcBlend = SrcAlpha;
        //DestBlend = InvSrcAlpha;
        VertexShader = compile VS_SHADERMODEL MainVS();
        PixelShader = compile PS_SHADERMODEL LitTransparentPS();
    }
};