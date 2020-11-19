
import frontMaterial_vert from './front-material-vs.glsl'
import frontMaterial_frag from './front-material-fs.glsl'
import backMaterial_vert from './back-material-vs.glsl'
import backMaterial_frag from './back-material-fs.glsl'
import dp2_vert from './dp2.v.glsl'
import dp2_frag from './dp2.f.glsl'

export const getFrontMaterial = function (THREE, cubeTexture, refractTexture) {
    return new THREE.ShaderMaterial({
        vertexShader: frontMaterial_vert,
        fragmentShader: frontMaterial_frag,
        side: THREE.FrontSide,
        transparent: true,
        depthWrite: false,
        uniforms: {
            "tCube": { type: "t", value: cubeTexture },
            "cameraWorldPos": { value: [0, 0, 0] },
            "modelMatrix": { value: new THREE.Matrix4() },
            "Color": { value: new THREE.Vector3(1, 1, 1) },
            "environmentLight": { value: 0.4 },
            "emission": { value: 0.7 },
            "backAlpha": { value: 0.5 },
            "frontAlpha": { value: 0.5 },
            "reflectionStrength": { value: 2.0 },
            "refractTex": { type: "t", value: refractTexture },
        },
    })
}

export const getBackMaterial = function (THREE, cubeTexture, refractTexture) {
    return new THREE.ShaderMaterial({
        vertexShader: backMaterial_vert,
        fragmentShader: backMaterial_frag,
        side: THREE.BackSide,
        transparent: true,
        depthWrite: false,
        uniforms: {
            "tCube": { type: "t", value: cubeTexture },
            "refractTex": { type: "t", value: refractTexture },
            "cameraWorldPos": { value: [0, 0, 0] },
            "modelMatrix": { value: new THREE.Matrix4() },
            "Color": { value: new THREE.Vector3(1, 1, 1) },
            "environmentLight": { value: 0.4 },
            "emission": { value: 0.7 },
            "backAlpha": { value: 0.5 },
            "frontAlpha": { value: 0.5 },
            "reflectionStrength": { value: 2.0 },
        },
    })
}

export const getDpMaterial = function (THREE, cubeMap, envMap, side) {
    return new THREE.RawShaderMaterial({
        vertexShader: dp2_vert,
        fragmentShader: dp2_frag,
        side: side,
        transparent: true,
        depthWrite: false,
        // colorWrite: true,
        // lights: true,
        uniforms: {
            'modelMatrix': { value: new THREE.Matrix4() },
            'InverseModelMatrix': { value: new THREE.Matrix4() },
            'modelViewMatrix': { value: new THREE.Matrix4() },
            'projectionMatrix': { value: new THREE.Matrix4() },
            'cameraPosition': { value: [0, 0, 0] },
            'tCubeMapNormals': { type: 't', value: cubeMap },
            'envMap': { type: 't', value: envMap },
            'envMapIntensity': { value: 2.5 },
            'n2': { value: 6.0 },
            'radius': { value: 5.0 },
            'rIndexDelta': { value: 0.5 },
            'normalOffset': { value: 1.5 },
            'squashFactor': { value: 1.0 },
            'distanceOffset': { value: 11.9 },
            'geometryFactor': { value: 20.0 },
            'colorCorrection': { value: [-0.0009, -0.001, -0.0009] },
            'boostFactors': { value: [1, 10, 10] },
            'centreOffset': { value: [1, 1, 1] },
            'opacity': { value: 0.8 },
            'i_toneMappingExposure': { value: 20.0 },
            'i_toneMappingWhitePoint': { value: 1.0 }
        },
    })
}