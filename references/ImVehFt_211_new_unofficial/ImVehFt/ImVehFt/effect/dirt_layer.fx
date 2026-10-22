sampler body : register(s0);
sampler dirt : register(s1);
float level : register(c0);

float4 main(float2 tex : TEXCOORD0) : COLOR0
{
    float4 bodyColor = tex2D(body, tex);
    float4 dirtColor = tex2D(dirt, tex);
    dirtColor.a *= level;
    return float4(bodyColor.rgb * (1 - dirtColor.a) + dirtColor.rgb * dirtColor.a, saturate(bodyColor.a + dirtColor.a));
}