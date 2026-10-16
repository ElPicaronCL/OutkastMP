texture baseTexture;
float baseTexture;
float2 baseSize;

sampler TextureSampler = sampler_state {
    Texture = <baseTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

static const float2 blurBuffer[16] = {
    float2(-0.326212f, -0.40581f),
    float2(-0.840144f, -0.07358f),
    float2(-0.695914f, 0.457137f),
    float2(-0.203345f, 0.620716f),
    float2(0.96234f, -0.194983f),
    float2(0.473434f, -0.480026f),
    float2(0.519456f, 0.767022f),
    float2(0.185461f, -0.893124f),
    float2(0.507431f, 0.064425f),
    float2(0.89642f, 0.412458f),
    float2(-0.32194f, -0.932615f),
    float2(-0.65432f, -0.87421f),
    float2(-0.456899f, -0.633247f),
    float2(-0.123456f, -0.865433f),
    float2(-0.664332f, -0.25680f),
    float2(-0.791559f, -0.59771f)
};

float4 PSFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0 {	
    float4 color = tex2D(TextureSampler, TextureCoordinate);
    for(int i = 0; i < 16; i++)
    {
        color += tex2D(TextureSampler, TextureCoordinate.xy + (blurBuffer[i]/baseSize*baseTexture));
    }
    return color/17;
}
 
technique Cinemify_TexBlur{
    pass P0 {
        PixelShader = compile ps_2_0 PSFunction();
    }
}