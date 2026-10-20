float4 gFrameColor = float4(1,1,1,0.5);

technique tec0
{
    pass P0
    {
        MaterialDiffuse = gFrameColor;
        MaterialEmissive = gFrameColor;

        DiffuseMaterialSource = Material;
        EmissiveMaterialSource = Material;

        ColorOp[0] = SELECTARG1;
        ColorArg1[0] = Diffuse;
        
        AlphaOp[0] = SELECTARG1;
        AlphaArg1[0] = Diffuse;
        
        Lighting = true;
    }
}