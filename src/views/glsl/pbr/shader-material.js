import vs from './vs.glsl'
import fs from './fs.glsl'

export const getDpMaterial = function (THREE, side, albedoMap, metallicMap, roughnessMap) {
    return new THREE.RawShaderMaterial({
        vertexShader: vs,
        fragmentShader: fs,
        side: side,
        transparent: false,
        // depthWrite: false,
        // colorWrite: true,
        // depthTest: false,
        // lights: true,
        uniforms: {
            'modelMatrix': { value: new THREE.Matrix4() },
            'modelViewMatrix': { value: new THREE.Matrix4() },
            'projectionMatrix': { value: new THREE.Matrix4() },
            'cameraPosition': { value: [0, 0, 0], type: 'v3' },
            // 'albedo': { value: [0.5, 0.0, 0.0], type: 'v3' },
            // 'roughness': { value: 0 },
            'ao': { value: 1.0 },
            // 'metallic': { value: 1.0 },
            'lightPositions': {
                type: 'v3v',
                value: [
                    new THREE.Vector3(150, 10, 0),
                    new THREE.Vector3(-150, 0, 0),
                    new THREE.Vector3(0, -10, -150),
                    new THREE.Vector3(0, 0, 150)
                ]
            },
            'lightColors': {
                type: 'v3v',
                value: [
                    new THREE.Vector3(300.0, 300.0, 300.0),
                    new THREE.Vector3(300.0, 300.0, 300.0),
                    new THREE.Vector3(300.0, 300.0, 300.0),
                    new THREE.Vector3(300.0, 300.0, 300.0)
                ]
            },
            'metallicMap': {
                type: 't',
                value: metallicMap
            },
            'roughnessMap': {
                type: 't',
                value: roughnessMap
            },
            'albedoMap': {
                type: 't',
                value: albedoMap
            }
        },
    })
}