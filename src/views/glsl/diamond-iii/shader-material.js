import dp2_vert from './dp2.v.glsl'
import dp2_frag from './dp2.f.glsl'

export const getDpMaterial = function (THREE, cubeMap, envMap, side) {
    return new THREE.RawShaderMaterial({
        vertexShader: dp2_vert,
        fragmentShader: dp2_frag,
        side: side,
        transparent: true,
        depthWrite: false,
        colorWrite: true,
        depthTest: false,
        // lights: true,
        uniforms: {
            'modelMatrix': { value: new THREE.Matrix4() },
            'InverseModelMatrix': { value: new THREE.Matrix4() },
            'modelViewMatrix': { value: new THREE.Matrix4() },
            'projectionMatrix': { value: new THREE.Matrix4() },
            'cameraPosition': { value: [0, 0, 0] },
            'tCubeMapNormals': { type: 't', value: cubeMap },
            'envMap': { type: 't', value: envMap },
            'envMapIntensity': { value: 1.0 },
            'n2': { value: 2.4 },
            'radius': { value: 1.0 },
            'rIndexDelta': { value: .012 },
            'normalOffset': { value: 0 },
            'squashFactor': { value: .98 },
            'distanceOffset': { value: 0 },
            'geometryFactor': { value: .28 },
            'colorCorrection': { value: [1, 1, 1], type: 'v3' },
            'boostFactors': { value: [.892, .892, .98595025], type: 'v3' },
            'centreOffset': { value: [0, 0, 0], type: 'v3' },
            'opacity': { value: 1 },
            'i_toneMappingExposure': { value: 2.3 },
            'i_toneMappingWhitePoint': { value: 1 },
            'iResolution': { value: [0, 0], type: 'v2' },
            'iMouse': { value: [0, 0, 1], type: 'v3'}
        },
    })
}