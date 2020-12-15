precision mediump float;

// 动画相关参数
float dotSize = 0.01;
float iteration = 100.;
float xAmp = 0.3;
float yAmp = 0.1;
float speed = 0.05;
float rotateCanvas = 0.;
float rotateParticles = 1.;
float rotateMultiplier = 10.;
vec2 pos = vec2(.5, .5);
float xFactor = 0.2;
float yFactor = 0.2;

#define RENDERSIZE vec2(512., 512.)
uniform float time;
varying vec2 v_texCoord;

// rotation
vec2 rot(vec2 uv, float a)
{
	// [uv.x uv.y] * [cos(a),  sin(a),
	//                -sin(a), cos(a)]
	return vec2(uv.x * cos(a) - uv.y * sin(a), uv.y * cos(a) + uv.x * sin(a));
}

float circle(vec2 uv, float size)
{
	// 向量长度在范围内为白色，范围外为黑
	return length(uv) > size ? 0.0 : 1.0;
}

void main( void ) 
{
   vec2 uv = v_texCoord;
   uv -= vec2(pos);// [-.5, .5]
   uv.x *= RENDERSIZE.x / RENDERSIZE.y;	// ratio = X/Y

   vec3 color = vec3(0);

   // 第一个粒子(i == 0)的 uv【其实第一个粒子是看不见的，因为size == 0】
	uv = rot(uv, rotateCanvas);

   // 99个粒子
	for (float i = 0.0; i < 100.0; i++)
	{
		// set max number of iterations
		if (iteration < i)
			break;

		// x:sin() y:cos() 的旋转动画
		vec2 new_pos = vec2(cos(i * xFactor * (time * speed)) * xAmp,
				sin(i * yFactor * (time * speed)) * yAmp);
		// st:新位置到uv的向量
		vec2 st = uv - new_pos;

		// 计算st向量的长度，并设置粒子的尺寸（从小到大）
		float dots = circle((st), dotSize * (i * 0.01));

		// 旋转当前粒子的 uv 得到下一个粒子的uv
		uv = rot(uv, rotateParticles * rotateMultiplier);

		// 更新纹素的颜色（只要当前纹素属于其中一个粒子，则置为白色，否则仍然是黑色）
		// 严谨的话是应该clamp，但是超过1也是白色
		color += dots;
	}

	gl_FragColor = vec4(vec3(color), 1.0);

}