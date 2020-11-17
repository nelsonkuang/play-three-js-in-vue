
import frontMaterial_vert from './front-material-vs.glsl'
import frontMaterial_frag from './front-material-fs.glsl'
import backMaterial_vert from './back-material-vs.glsl'
import backMaterial_frag from './back-material-fs.glsl'

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