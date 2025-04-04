// ==========================
//  BG3 Skin Shader by Volno
// ==========================
//  v 3.1.0
// Nexus Mods (https://next.nexusmods.com/profile/Volno/about-me)
// GitHub (https://github.com/V0ln0/BG3-Substance-Painter-Shaders)
// Discord @Volno
// this software is licenced under a Attribution-ShareAlike 4.0 International (CC-BY-SA-4.0) licence
// https://creativecommons.org/licenses/by-sa/4.0/

import lib-sparse.glsl 
import lib-pbr.glsl
import lib-pom.glsl
import lib-utils.glsl
import lib-defines.glsl 


//: param auto channel_user0
uniform SamplerSparse L0_Hemo_tex;
//: param auto channel_user1
uniform SamplerSparse L1_Mel_tex;
//: param auto channel_user2
uniform SamplerSparse L2_Vien_tex; 
//: param auto channel_user3
uniform SamplerSparse L3_Yellow_tex;
//: param auto channel_user4
uniform SamplerSparse L4_Cavity_tex;
//: param auto channel_user5
uniform SamplerSparse L5_Hair_tex;
//: param auto channel_user6
uniform SamplerSparse L6_Lips_tex;
//: param auto channel_user7
uniform SamplerSparse L7_UTL_1_tex;
//: param auto channel_user8
uniform SamplerSparse L8_UTL_2_tex;
//: param auto channel_user9
uniform SamplerSparse L9_UTL_3_tex;
//: param auto channel_user10
uniform SamplerSparse L10_BM_tex;
//: param auto channel_height
uniform SamplerSparse height_tex;
//: param auto channel_normal
uniform SamplerSparse channel_normal;
//: param auto channel_ambientocclusion
uniform SamplerSparse channel_ambientocclusion;
//: param auto channel_specularlevel 
uniform SamplerSparse specularlevel_tex;



//settings


//: param custom {
//:   "default": 0.77,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Hemoglobin Amount",
//:   "group": "Skin Parameters/Hemoglobin"
//: }
uniform float HemoglobinAmount;

//: param custom { "default": [0.6523701, 0.009021491, 0.009021491], "label": "Hemoglobin Colour", "group": "Skin Parameters/Hemoglobin", "widget": "color" } 
uniform vec3 HemoglobinColour;

//: param custom {
//:   "default": 0.22,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Melanin Amount",
//:   "group": "Skin Parameters/Melanin"
//: }
uniform float MelaninAmount;

//: param custom {
//:   "default": 0.0,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Melanin Removal Amount",
//:   "group": "Skin Parameters/Melanin"
//: }
uniform float MelaninRemovalAmount;


//: param custom { "default": [0.03195167, 0.007290916, 0.00140997], "label": "Melanin Colour", "group": "Skin Parameters/Melanin", "widget": "color" } 
uniform vec3 MelaninColour;

//: param custom {
//:   "default": 0.6,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Vein Amount",
//:   "group": "Skin Parameters/Vein"
//: }
uniform float VeinAmount;

//: param custom { "default": [0, 0.2673581, 0.585973], "label": "Vein Colour", "group": "Skin Parameters/Vein", "widget": "color" } 
uniform vec3 VeinColour;

//: param custom {
//:   "default": 0.32,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Yellowing Amount",
//:   "group": "Skin Parameters/Yellowing"   
//: }
uniform float YellowingAmount;

//: param custom { "default": [0.9866056, 0.7862425, 0.1879118], "label": "Yellowing Colour", "group": "Skin Parameters/Yellowing", "widget": "color" } 
uniform vec3 YellowingColour;

//: param custom { "default": [0.01, 0.01, 0.01], "label": "Hair Colour", "group": "Skin Parameters/Misc", "widget": "color" } 
uniform vec3 HairColour;

//: param custom { "default": false, "label": "CLEA Makeup (Lipstick) Toggle", "group": "Skin Parameters/Misc"  }
uniform bool Makeup_Toggle;

//: param custom { "default": [0.5, 0.5, 0.5], "label": "Makeup Colour", "group": "Skin Parameters/Misc", "description": "<html><head/><body><p> <b>Please Note:</b> This is referes to the blue channel in the CLEA map  </p></body></html>", "widget": "color" } 
uniform vec3 MakeupColour;

//: param custom { "default": false, "label": "Non-Skin Toggle", "group": "Skin Parameters/Misc","description": "Toggles the apperance on non-skin elements, such as hornplates and nails." }
uniform bool BMmapToggle;

//: param custom { "default": [0.5, 0.5, 0.5], "label": "NonSkin Colour", "group": "Skin Parameters/Misc", "widget": "color" } 
uniform vec3 NonSkinColour;


//: param custom {
//:   "default": 0.55,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Roughness Amount",
//:   "group": "Utilities/Visual"
//: }
uniform float RoughnessAmount;

//: param custom { "default": false, "label": "Lighting Toggle", "group": "Utilities/Visual"  }
uniform bool LightingToggle;

// !!UTILITES EXPLINATION!!
//
// Channels user7, user8, & user9 ("Utility Channels", or UTL) have a duel use
// When MSK_Channel_Toggle = true, the shader will use UTL_Map_tex inplace of channel data for the **CancelMSK** (MelaninRemoval, Internals Mask, NonSkin)
// When MSK_Channel_Toggle = false, the shader will use UTL_Map_tex inplace of channel data for the **AtlasMap** (Tattoos, makeup, gith spots)
//
// This was done to reduce the amount of userchannels + make things more managable
// this thing already uses 15 channels, I refuse to use more


//: param custom { "default": false, "label": "MSK Toggle", "group": "Utilities/MSK"  }
uniform bool MSK_Channel_Toggle;

//: param custom { "default": "", "label": "MSK/Atlas", "usage": "texture", "group": "Utilities/MSK" }
uniform sampler2D UTL_Map_tex;

//: param custom {
//:   "default": 0.0,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Atlas Red Strength",
//:   "group": "Utilities/MSK" 
//: }
uniform float ULT_R_Influence;

//: param custom { "default": [1.0, 0.0, 0.0], "label": "Utility Colour R", "group": "Utilities/MSK", "widget": "color" } 
uniform vec3 ULT_R_Colour;

//: param custom {
//:   "default": 0.0,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Atlas Green Strength",
//:   "group": "Utilities/MSK" 
//: }
uniform float ULT_G_Influence;

//: param custom { "default": [0.0, 1.0, 0.0], "label": "Utility Colour G", "group": "Utilities/MSK", "widget": "color" } 
uniform vec3 ULT_G_Colour;

//: param custom {
//:   "default": 0.0,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Atlas Blue Strength",
//:   "group": "Utilities/MSK" 
//: }
uniform float ULT_B_Influence;

//: param custom { "default": [0.0, 0.0, 1.0], "label": "Utility Colour B", "group": "Utilities/MSK", "widget": "color" } 
uniform vec3 ULT_B_Colour;







void shade(V2F inputs) { 

    // BG3 SKIN crap
   
   //HMVY
    vec3 HemoglobinUser = textureSparse(L0_Hemo_tex, inputs.sparse_coord).xyz;
    vec3 MelaninUser = textureSparse(L1_Mel_tex, inputs.sparse_coord).xyz;
    vec3 VeinUser = textureSparse(L2_Vien_tex, inputs.sparse_coord).xyz;
    vec3 YellowingUser = textureSparse(L3_Yellow_tex, inputs.sparse_coord).xyz;
    
    vec3 Curvature = textureSparse(L4_Cavity_tex, inputs.sparse_coord).xyz;
    vec3 Hair = textureSparse(L5_Hair_tex, inputs.sparse_coord).xyz;   
    vec3 Lips = textureSparse(L6_Lips_tex, inputs.sparse_coord).xyz;
    float AO = getAO(inputs.sparse_coord);

    vec3 CancelMSK_R = textureSparse(L7_UTL_1_tex, inputs.sparse_coord).xyz;
    vec3 CancelMSK_G = textureSparse(L8_UTL_2_tex, inputs.sparse_coord).xyz;
    vec3 CancelMSK_B = textureSparse(L9_UTL_3_tex, inputs.sparse_coord).xyz;
    vec3 BMmap = textureSparse(L10_BM_tex, inputs.sparse_coord).xyz;
    vec4 CLEA = vec4(Curvature.x, Hair.x, Lips.x, AO);
    
    float BMmapInfluence = 0.0;
        if(BMmapToggle){
         BMmapInfluence = 1.0;
    }
    float MakeupInfluence = 0.0;
        if(Makeup_Toggle){
            MakeupInfluence = 1.0;
        }
    vec4 HMVY = vec4(HemoglobinUser.x, MelaninUser.x, VeinUser.x, YellowingUser.x);
    vec3 AtlasInfluence = vec3(ULT_R_Influence, ULT_G_Influence, ULT_B_Influence);
    vec3 AtlasMap = vec3(texture(UTL_Map_tex, inputs.tex_coord));
    vec3 CancelMSK = vec3(CancelMSK_R.x, CancelMSK_G.x, CancelMSK_B.x);
        if(MSK_Channel_Toggle) {
            CancelMSK = vec3(texture(UTL_Map_tex, inputs.tex_coord));
            AtlasMap = vec3(CancelMSK_R.x, CancelMSK_G.x, CancelMSK_B.x);
        }
    
    vec3 AtlasContribution = (vec3(CLEA.x) * dot(AtlasMap, AtlasInfluence));
    vec3 AtlasCurvature = (AtlasMap * vec3(CLEA.x));
    vec3 AtlasColour = 
        (ULT_R_Colour * vec3(AtlasCurvature.x)) +
        (ULT_G_Colour * vec3(AtlasCurvature.y)) +
        (ULT_B_Colour * vec3(AtlasCurvature.z));


    float BruisesMelanin = 1.0 - HMVY.y; 
    float MelaninDark = mix(
        mix(0.0, 0.9, clamp(BruisesMelanin / 0.9, 0.0, 1.0)), 
        2.0, 
        clamp((BruisesMelanin - 0.9) / (1.0 - 0.9), 0.0, 1.0)
        )+ MelaninAmount;
    
    float MelaninFinal = MelaninDark * ((-CancelMSK.y * MelaninRemovalAmount) + 1.0);
    vec2 _691 = vec2(clamp(HMVY.x * HemoglobinAmount, 0.0, 1.0), max(MelaninFinal, 0.0));
    vec2 HMExponents = vec2(1.0) - (vec2(1.0) / pow( vec2(2.718281), pow( max(_691, vec2(0.00001)), vec2(2.0))));
    float HemoglobinExponent = HMExponents.x;
    float MelaninExponent = HMExponents.y;
    vec3 HemoglobinColourMax = max(HemoglobinColour, vec3(0.00001));
    vec3 MelaninColourMax = max(MelaninColour, vec3(0.00001));
    vec3 VeinContribution = vec3(clamp((0.8, + HMVY.z * VeinAmount), 0.0, 1.0));
    vec3 HemoglobinMelanin = mix(pow(HemoglobinColourMax, vec3(HemoglobinExponent)), VeinColour, VeinContribution) * pow(MelaninColourMax, vec3(MelaninExponent));
    vec3 YellowingContribution = vec3(HMVY.w) * YellowingAmount;
    vec3 HemoglobinMelaninYellowing = mix(HemoglobinMelanin, (HemoglobinMelanin * YellowingColour), YellowingContribution) * vec3(0.9522, 0.7441, 0.5952);
    vec3 HMVLuminance = vec3(dot(HemoglobinMelaninYellowing, vec3(0.2126, 0.7152, 0.0722)));
    vec3 HMVY_Final = mix(HMVLuminance, HemoglobinMelaninYellowing, vec3((-HemoglobinExponent * MelaninExponent + 1.0)));
    


    vec3 WithAtlas = (HMVY_Final * (1.0 - dot(AtlasCurvature, vec3(1.0)))) + AtlasColour; 
    vec3 WithHair = mix(WithAtlas, HairColour, CLEA.y);
    vec3 WithMakeup = mix(WithHair, MakeupColour, (MakeupInfluence * CLEA.z));
    vec3 BMmapWithColour = BMmap.x * NonSkinColour;
    vec3 FinalColour = mix(WithMakeup, BMmapWithColour, (BMmapInfluence * CancelMSK.x));
    
    float Roughness_Final = mix(clamp((RoughnessAmount * CLEA.x) + (1.0 - CLEA.x), 0.0, 1.0), 0.8, CLEA.y);
    float specularLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
    float lightingInfluence = 0.0;
        if(LightingToggle){
            lightingInfluence = 1.0;
            Roughness_Final = 1.0; 
            specularLevel = 0.0;
        }
    

    
    vec3 specColor = generateSpecularColor(specularLevel, FinalColour, 0.0);
    float specOcclusion = specularOcclusionCorrection(AO, 0.0, Roughness_Final);


        
    float occlusion = AO * getShadowFactor();
    vec3 diffColor = generateDiffuseColor(FinalColour, 0.0);
    LocalVectors vectors = computeLocalFrame(inputs);
    albedoOutput(diffColor);
    diffuseShadingOutput(mix(occlusion * envIrradiance(vectors.normal), vec3(1.0), lightingInfluence));
    specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, Roughness_Final)); 
}

