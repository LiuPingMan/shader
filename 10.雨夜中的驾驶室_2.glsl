struct Ray{
  vec3 o,d;
};
Ray getRay(vec2 uv,vec3 camPos,vec3 lookAt,float zoom){
  Ray ray;
  ray.o=camPos;
  vec3 f=normalize(lookAt-camPos);
  vec3 r=normalize(cross(vec3(0.,1.,0.),f));
  vec3 u=cross(f,r);
  ray.d=normalize(f*zoom+uv.x*r+uv.y*u);
  return ray;
}

// 计算点p到射线ray的最短距离
float disRay(Ray ray,vec3 p){
  vec3 closestPoint=ray.o+max(0.,dot(p-ray.o,ray.d))*ray.d;
  return length(p-closestPoint);
}
// 绘制光圈
float bokeh(Ray ray,vec3 p,float size,float blur){
  float d=disRay(ray,p);
  // 点到相机距离不同，大小不变
  size*=length(p-ray.o);
  float c=smoothstep(size,size*(1.-blur),d);
  c*=mix(.6,1.,smoothstep(size*.8,size,d));
  return c;
}
// 绘制路灯
vec3 streetLights(Ray ray,float t){
  float side=step(ray.d.x,0.);
  ray.d.x=abs(ray.d.x);
  float s=1./10.;
  float m=0.;
  for(float i=0.;i<1.;i+=s){
    float ti=fract(t+i+side*s*.5);
    vec3 p=vec3(2.,2.,100.-ti*100.);
    m+=bokeh(ray,p,.03,.1)*ti*ti*ti;
  }
  vec3 col=vec3(1.,.6,.1)*m;
  return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv.x*=iResolution.x/iResolution.y;
  float t=iTime*.1;
  
  vec3 camPos=vec3(0.,.2,0.);
  vec3 lookAt=vec3(.2,.2,1.);
  Ray ray=getRay(uv,camPos,lookAt,2.);
  vec3 col=streetLights(ray,t);
  fragColor=vec4(col,1.);
}