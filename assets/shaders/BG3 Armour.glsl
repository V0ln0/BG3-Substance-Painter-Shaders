// ==========================
//  BG3 Armour Tint by Volno
// ==========================
// Nexus Mods (https://next.nexusmods.com/profile/Volno/about-me)
// Discord @Volno
// The following is an modification of Adobe's 'Substance 3D Painter Metal/Rough PBR shader' which has been edited for the creation of armour for use in BG3.
// You are free to modify, share, and adapt the file I have made freely, provided that you: 
// 1. give credit to me as the original creator
// 2. that you do not put the file behind a paywall
// 3. that you give others the same rights to modify the work as I have here.
// Happy Modding


//- Substance 3D Painter Metal/Rough PBR shader
//- ====================================
//-
//- Import from libraries.
import lib-pbr.glsl
import lib-bent-normal.glsl
import lib-emissive.glsl
import lib-pom.glsl
import lib-sss.glsl
import lib-utils.glsl

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
//: param auto channel_user0
uniform SamplerSparse MSKcloth_tex;


//: param custom { "default": [0.091518, 0.091518, 0.136099], "label": "Cloth Primary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 CP_Colour;

//: param custom { "default": [0.43134, 0.163641, 0.238828], "label": "Cloth Secondary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 CS_Colour;

//: param custom { "default": [0.190463, 0.186989, 0.197516], "label": "Cloth Tertiary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 CT_Colour;

//: param custom { "default": [0.263175, 0.183549, 0.136099], "label": "Leather Primary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 LP_Colour;

//: param custom { "default": [0.073828, 0.063815, 0.136099], "label": "Leather Secondary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 LS_Colour;

//: param custom { "default": [0.121986, 0.060032, 0.051122], "label": "Leather Tertiary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 LT_Colour;

//: param custom { "default": [0.91575, 0.804559, 0.442323], "label": "Metal Primary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 MP_Colour;

//: param custom { "default": [0.940601, 0.774227, 0.329729], "label": "Metal Secondary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 MS_Colour;

//: param custom { "default": [0.605484, 0.605484, 0.605484], "label": "Metal Tertiary Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 MT_Colour;

//: param custom { "default": [0.147998, 0.080219, 0.089194], "label": "Accent Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 AC_Colour;

//: param custom { "default": [1.0, 1.0, 1.0], "label": "Custom 1 Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 C1_Colour;

//: param custom { "default": [1.0, 1.0, 1.0], "label": "Custom 2 Colour", "group": "BG3 Colour Settings", "widget": "color" } 
uniform vec3 C2_Colour;

//: param custom { "default": false, "label": "Colour Toggle", "group": "BG3 Colour Settings"  }
uniform bool ColourToggle;

vec3 MSKmaskFinder(vec3 InputMap, vec3 Colour1, vec3 Colour2, vec3 Colour3)
{ 	
	float MSKthreshold = 0.25;
	vec3 ComLength = vec3((length(InputMap - Colour1)), (length(InputMap - Colour2)), (length(InputMap - Colour3)));
	vec3 MSkmaskGrab = vec3((1.0 - (ComLength / sqrt(3.0)) - (1.0 - vec3(MSKthreshold))) / vec3(MSKthreshold));
	vec3 MSkmaskGrabClamped = clamp(MSkmaskGrab, 0.0, 1.0);
	return (MSkmaskGrabClamped);	
}

vec3 MSKmaskMix(vec3 Masks, vec3 ColourA, vec3 ColourB, vec3 ColourC)
{
	vec3 MaskedColours = 
	(Masks.x * ColourA) + (Masks.y * ColourB) + (Masks.z * ColourC);

	return MaskedColours;
}



void shade(V2F inputs)
{
  // Apply parallax occlusion mapping if possible
  vec3 viewTS = worldSpaceToTangentSpace(getEyeVec(inputs.position), inputs);
  applyParallaxOffset(inputs, viewTS);
	
  
  //BG3 SPECIFIC
  vec3 MSKcloth = textureSparse(MSKcloth_tex, inputs.sparse_coord).xyz;
	vec3 ClothMasks = MSKmaskFinder(MSKcloth, vec3(1.0, 0.5, 0.0), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.5));
	vec3 LeatherMasks = MSKmaskFinder(MSKcloth, vec3(0.5, 0.0, 1.0), vec3(0.0, 0.0, 1.0), vec3(0.5, 0.5, 1.0));
	vec3 MetalMasks = MSKmaskFinder(MSKcloth, vec3(0.0, 1.0, 0.5), vec3(0.0, 1.0, 0.0), vec3(0.5, 1.0, 0.5));
	vec3 ExtraMasks = MSKmaskFinder(MSKcloth, vec3(1.0, 0.0, 0.5), vec3(0.0, 0.5, 1.0), vec3(0.5, 1.0, 0.0));

  	vec3 FinalMSKColour = (
		(MSKmaskMix(ClothMasks, CP_Colour, CS_Colour, CT_Colour)) + 
		(MSKmaskMix(LeatherMasks, LP_Colour, LS_Colour, LT_Colour)) +
		(MSKmaskMix(MetalMasks, MP_Colour, MS_Colour, MT_Colour)) +
		(MSKmaskMix(ExtraMasks, AC_Colour, C1_Colour, C2_Colour))
	);
		if(ColourToggle){
			FinalMSKColour = vec3(1.0);
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

  // Feed parameters for a physically based BRDF integration
  emissiveColorOutput(pbrComputeEmissive(emissive_tex, inputs.sparse_coord));
  albedoOutput(diffColor);
  diffuseShadingOutput(occlusion * shadowFactor * envIrradiance(getDiffuseBentNormal(vectors)));
  specularShadingOutput(specOcclusion * pbrComputeSpecular(vectors, specColor, roughness, occlusion, getBentNormalSpecularAmount()));
  sssCoefficientsOutput(getSSSCoefficients(inputs.sparse_coord));
  sssColorOutput(getSSSColor(inputs.sparse_coord));
}
