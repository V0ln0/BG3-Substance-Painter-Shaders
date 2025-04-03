// ==========================
//  BG3 Armour by Volno
// ==========================
//  v 3.1.0
// Nexus Mods (https://next.nexusmods.com/profile/Volno/about-me)
// GitHub (https://github.com/V0ln0/BG3-Substance-Painter-Shaders)
// Discord @Volno
// this software is licenced under a Attribution-ShareAlike 4.0 International (CC-BY-SA-4.0) licence
// https://creativecommons.org/licenses/by-sa/4.0/


import lib-pbr.glsl
import lib-bent-normal.glsl
import lib-emissive.glsl
import lib-utils.glsl
import lib-alpha-test.glsl

//- Declare the iray mdl material to use with this shader.
//: metadata {
//:   "mdl":"mdl::alg::materials::skin_metallic_roughness::skin_metallic_roughness"
//: }

//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;
//: param auto channel_roughness
uniform SamplerSparse roughness_tex;
//: param auto channel_metallic
uniform SamplerSparse metallic_tex;
//: param auto channel_specularlevel
uniform SamplerSparse specularlevel_tex;
//: param auto channel_ambientocclusion
uniform SamplerSparse channel_ambientocclusion;
//: param auto channel_user0
uniform SamplerSparse MSKcloth_tex;


//: param custom {
//:   "group": "Geometry/Opacity",
//:   "label": "Enable alpha blending",
//:   "default": false,
//:   "asm": "opacity",
//:   "description": "<html><head/><body><p>Uses the opacity texture to progressively blend the transparent surface over the background.<br/><b>Please note</b>: The following channel needs to be present for this parameter to have an effect: <b>Opacity</b></p></body></html>",
//:   "enable": "!input.sssEnabled",
//:   "description_disabled": "<html><head/><body><p>Disable the <b>Subsurface Scattering</b> to use <b>Alpha blending</b>.</p></body></html>"
//: }

uniform_specialization bool alphaBlendEnabled;
//: state blend over {"enable":"input.alphaBlendEnabled && !input.sssEnabled && !input.translucencyEnabled"}

//: param custom {
//:   "group": "Geometry",
//:   "label": "Back-face Culling",
//:   "default": false,
//:   "description": "<html><head/><body><p>When enabled, the surface is visible on both sides, i.e. back-face culling is disabled.</p></body></html>"
//: }
uniform_specialization bool doubleSided;
//: state cull_face off {"enable":"input.doubleSided"}

//: param custom {
//:   "label": "Colour Toggle",
//:   "group": "Baldur's Gate 3/Colour",
//:   "default": true,
//:   "description": "<html><head/><body><p>Controls the colour overlay, when disabled only the <b>Base Colour</b> channel will show.</p></body></html>"
//: }
uniform bool ColourToggle;

//: param custom { "default": [0.091518, 0.091518, 0.136099], "label": "Cloth Primary Colour", "group": "Baldur's Gate 3/Colour/Cloth", "widget": "color" } 
uniform vec3 CP_Colour;

//: param custom { "default": [0.43134, 0.163641, 0.238828], "label": "Cloth Secondary Colour", "group": "Baldur's Gate 3/Colour/Cloth", "widget": "color" } 
uniform vec3 CS_Colour;

//: param custom { "default": [0.190463, 0.186989, 0.197516], "label": "Cloth Tertiary Colour", "group": "Baldur's Gate 3/Colour/Cloth", "widget": "color" } 
uniform vec3 CT_Colour;

//: param custom { "default": [0.263175, 0.183549, 0.136099], "label": "Leather Primary Colour", "group": "Baldur's Gate 3/Colour/Leather", "widget": "color" } 
uniform vec3 LP_Colour;

//: param custom { "default": [0.073828, 0.063815, 0.136099], "label": "Leather Secondary Colour", "group": "Baldur's Gate 3/Colour/Leather", "widget": "color" } 
uniform vec3 LS_Colour;

//: param custom { "default": [0.121986, 0.060032, 0.051122], "label": "Leather Tertiary Colour", "group": "Baldur's Gate 3/Colour/Leather", "widget": "color" } 
uniform vec3 LT_Colour;

//: param custom { "default": [0.91575, 0.804559, 0.442323], "label": "Metal Primary Colour", "group": "Baldur's Gate 3/Colour/Metal", "widget": "color" } 
uniform vec3 MP_Colour;

//: param custom { "default": [0.940601, 0.774227, 0.329729], "label": "Metal Secondary Colour", "group": "Baldur's Gate 3/Colour/Metal", "widget": "color" } 
uniform vec3 MS_Colour;

//: param custom { "default": [0.605484, 0.605484, 0.605484], "label": "Metal Tertiary Colour", "group": "Baldur's Gate 3/Colour/Metal", "widget": "color" } 
uniform vec3 MT_Colour;

//: param custom { "default": [0.147998, 0.080219, 0.089194], "label": "Accent Colour", "group": "Baldur's Gate 3/Colour/Custom", "widget": "color" } 
uniform vec3 AC_Colour;

//: param custom { "default": [1.0, 1.0, 1.0], "label": "Custom 1 Colour", "group": "Baldur's Gate 3/Colour/Custom", "widget": "color" } 
uniform vec3 C1_Colour;

//: param custom { "default": [1.0, 1.0, 1.0], "label": "Custom 2 Colour", "group": "Baldur's Gate 3/Colour/Custom", "widget": "color" } 
uniform vec3 C2_Colour;



// takes the MSKcloth map colours and turns it into a pure red, green, and blue image depending on the 'catagory'. (ie, cloth, leather, metal, exta)
// other 'catagories' are removed, so you end up with an RGB map for just one type. Only put colours for one catagory into it.
vec3 MSKmaskFinder(vec3 InputMap, vec3 Colour1, vec3 Colour2, vec3 Colour3)
{ 	
	float MSKthreshold = 0.25;
	vec3 ComLength = vec3((length(InputMap - Colour1)), (length(InputMap - Colour2)), (length(InputMap - Colour3)));
	vec3 MSkmaskGrab = vec3((1.0 - (ComLength / sqrt(3.0)) - (1.0 - vec3(MSKthreshold))) / vec3(MSKthreshold));
	vec3 MSkmaskGrabClamped = clamp(MSkmaskGrab, 0.0, 1.0);
	return (MSkmaskGrabClamped);	
}

// takes the RGB map from MSKmaskFinder and adds user selected colours
vec3 MSKmaskMix(vec3 Masks, vec3 ColourA, vec3 ColourB, vec3 ColourC)
{
	vec3 MaskedColours = 
	(Masks.x * ColourA) + (Masks.y * ColourB) + (Masks.z * ColourC);

	return MaskedColours;
}



void shade(V2F inputs)
{

	
  
  //BG3 SPECIFIC
  vec3 MSKcloth = textureSparse(MSKcloth_tex, inputs.sparse_coord).xyz;
	vec3 ClothMasks = MSKmaskFinder(MSKcloth, vec3(1.0, 0.5, 0.0), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.5));
	vec3 LeatherMasks = MSKmaskFinder(MSKcloth, vec3(0.5, 0.0, 1.0), vec3(0.0, 0.0, 1.0), vec3(0.5, 0.5, 1.0));
	vec3 MetalMasks = MSKmaskFinder(MSKcloth, vec3(0.0, 1.0, 0.5), vec3(0.0, 1.0, 0.0), vec3(0.5, 1.0, 0.5));
	vec3 ExtraMasks = MSKmaskFinder(MSKcloth, vec3(1.0, 0.0, 0.5), vec3(0.0, 0.5, 1.0), vec3(0.5, 1.0, 0.0));

  	vec3 FinalMSKColour = vec3(1.0);
		
    if(ColourToggle){
			FinalMSKColour =(
		(MSKmaskMix(ClothMasks, CP_Colour, CS_Colour, CT_Colour)) + 
		(MSKmaskMix(LeatherMasks, LP_Colour, LS_Colour, LT_Colour)) +
		(MSKmaskMix(MetalMasks, MP_Colour, MS_Colour, MT_Colour)) +
		(MSKmaskMix(ExtraMasks, AC_Colour, C1_Colour, C2_Colour))
	  );
		}
  
  vec3 SourceBase = getBaseColor(basecolor_tex, inputs.sparse_coord);
  
  //PBR STARTRS HERE
  vec3 baseColor = SourceBase * FinalMSKColour;
  float roughness = getRoughness(roughness_tex, inputs.sparse_coord);
  float metallic = getMetallic(metallic_tex, inputs.sparse_coord);
  float specularLevel = getSpecularLevel(specularlevel_tex, inputs.sparse_coord);
  vec3 diffColor = generateDiffuseColor(baseColor, metallic);
  vec3 specColor = generateSpecularColor(specularLevel, baseColor, metallic);

  // Get detail (ambient occlusion) and global (shadow) occlusion factors
  // separately in order to blend the bent normals properly
  float shadowFactor = getShadowFactor();
  float occlusion = getAO(inputs.sparse_coord, true, use_bent_normal);
  float specOcclusion = specularOcclusionCorrection(
    use_bent_normal ? shadowFactor : occlusion * shadowFactor,
    metallic,
    roughness);

  LocalVectors vectors = computeLocalFrame(inputs);
  computeBentNormal(vectors,inputs);

  emissiveColorOutput(pbrComputeEmissive(emissive_tex, inputs.sparse_coord));
  albedoOutput(diffColor);
  diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(getDiffuseBentNormal(vectors)));
  specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness, occlusion, getBentNormalSpecularAmount()));

  alphaKill(inputs.sparse_coord);
}
