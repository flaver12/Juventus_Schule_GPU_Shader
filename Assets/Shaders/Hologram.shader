Shader "Unlit/SpecialFX/Cool Hologram" // Name in the shader select menu
{
    Properties // Public Properties for unity
    {
        // !!! REMEMBER NO SEMICOLONE HERE !!!
        //VariableName DisplayName Type   Default Value
        _MainTex ("Albedo Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) =  (1,1,1,1) // White
        _Transparency("Transparency", Range(0.0, 0.5)) = 0.25
        _CutoutThresh("Cutout Threshhold", Range(0.0, 1.0)) = 0.2
        _Distance("Distance", Float) = 1
        _Amplitude("Amplitude", Float) = 1
        _Speed ("Speed", Float) = 1
        _Amount("Amount", Range(0.0,1.0)) = 1
    }
    SubShader // Shader code, we can have multiple sub shader. Eg: One for PC build one for the ps4 build
    {
        // Tell unity how to setup the renderer
        // For ref: https://docs.unity3d.com/Manual/SL-SubShaderTags.html
        Tags {"Queue" = "Transparent" "RenderType"="Transparent" } // Tell unity how to render this
        LOD 100 // Level of detail

        // For ref: https://docs.unity3d.com/2020.1/Documentation/Manual/SL-CullAndDepth.html
        ZWrite Off // do not write to the depth buffer

        // Tell the shader how to blend the pixels together
        // For ref: https://docs.unity3d.com/2020.1/Documentation/Manual/SL-Blend.html
        Blend SrcAlpha OneMinusSrcAlpha

        Pass // Talk to the GPU
        {
            CGPROGRAM // Actual shader code
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc" // import helper functions

            struct appdata
            {
                float4 vertex : POSITION; // Packed array with 4 floats x,y,z,w
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _Transparency;
            float _CutoutThresh;
            float _Distance;
            float _Amplitude;
            float _Speed;
            float _Amount;

            // Flow Mesh -> vertex -> fragment -> Image
            // Property data: Colors, textures, vlues set by user in the inspector
            v2f vert (appdata v) // Vertex function, Takes the shape of the model, potentially modifies it
            {
                v2f o;
                // Time.y = time in seconds
                // Apply this sin movement to the vertecies in object space 
                v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Amplitude) * _Distance * _Amount;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target // Fragment function, Applies color to the shape output by the vert function
            {
                // sample the texture
                // + make it brighter, * just add the color(tint a sprite)
                fixed4 col = tex2D(_MainTex, i.uv) + _TintColor; // Add the color to the color we get from the texture
                col.a = _Transparency; // Set the alpha to a value from 0.0 -> 0.25
                
                // this will do the same then
                // if (col.r < _CutoutThresh) discard;
                clip(col.r - _CutoutThresh); // discard cerent pixel data

                return col;
            }
            ENDCG
        }
    }
}
