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

float N(float t){
  return fract(sin(t*3456.)*6547.);
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
    m+=bokeh(ray,p,.05,.1)*ti*ti*ti;
  }
  vec3 col=vec3(1.,.6,.1)*m;
  return col;
}
// 绘制车流前灯
vec3 headLights(Ray ray,float t){
  t*=2.;
  float carWidth=.5;
  float s=1./30.;
  float m=0.;
  
  for(float i=0.;i<1.;i+=s){
    // 过滤一些车灯
    float n=N(i);
    if(n>.1)continue;
    
    float ti=fract(t+i);
    float z=100.-ti*100.;
    float fade=ti*ti*ti*ti*ti;
    float foucs=smoothstep(.8,1.,ti);
    float size=mix(.05,.03,foucs);
    // 车灯
    m+=bokeh(ray,vec3(-1.-carWidth/2.,.15,z),size,.1)*fade;
    m+=bokeh(ray,vec3(-1.+carWidth/2.,.15,z),size,.1)*fade;
    // 灯光光晕散射
    m+=bokeh(ray,vec3(-1.-carWidth/2.*1.2,.15,z),size,.1)*fade;
    m+=bokeh(ray,vec3(-1.+carWidth/2.*1.2,.15,z),size,.1)*fade;
    // 倒影反射
    float ref=0.;
    ref+=bokeh(ray,vec3(-1.-carWidth/2.*1.2,-.15,z),size*3.,1.)*fade;
    ref+=bokeh(ray,vec3(-1.+carWidth/2.*1.2,-.15,z),size*3.,1.)*fade;
    m+=ref*foucs;
  }
  vec3 col=vec3(.9,.9,1.)*m;
  return col;
}

// 绘制车流尾灯
vec3 tailLights(Ray ray,float t){
  t*=.25;
  float carWidth=.5;
  float s=1./15.;
  float m=0.;
  for(float i=0.;i<1.;i+=s){
    // 过滤一些车灯
    float n=N(i);
    if(n>.5)continue;
    
    // 选择车道
    float lane=step(.25,n);
    
    float ti=fract(t+i);
    float z=100.-ti*100.;
    float fade=ti*ti*ti*ti*ti;
    float foucs=smoothstep(.8,1.,ti);
    float size=mix(.05,.03,foucs);
    float x=1.5-lane*smoothstep(1.,.96,ti);
    float blink=step(0.,sin(t*1000.))*7.*lane*step(.96,ti);
    // 车灯
    m+=bokeh(ray,vec3(x-carWidth/2.,.15,z),size,.1)*fade;
    m+=bokeh(ray,vec3(x+carWidth/2.,.15,z),size,.1)*fade;
    // 灯光光晕散射
    m+=bokeh(ray,vec3(x-carWidth/2.*1.2,.15,z),size,.1)*fade;
    m+=bokeh(ray,vec3(x+carWidth/2.*1.2,.15,z),size,.1)*fade*(1.+blink);
    // 倒影反射
    float ref=0.;
    ref+=bokeh(ray,vec3(x-carWidth/2.*1.2,-.15,z),size*3.,1.)*fade;
    ref+=bokeh(ray,vec3(x+carWidth/2.*1.2,-.15,z),size*3.,1.)*fade*(1.+blink*.1);
    m+=ref*foucs;
  }
  vec3 col=vec3(1.,.1,.03)*m;
  return col;
}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv.x*=iResolution.x/iResolution.y;
  
  vec2 m=iMouse.xy/iResolution.xy;
  float t=iTime*.1+m.x;
  
  vec3 camPos=vec3(.5,.2,.0);
  vec3 lookAt=vec3(.5,.2,1.);
  Ray ray=getRay(uv,camPos,lookAt,2.);
  vec3 col=streetLights(ray,t);
  col+=headLights(ray,t);
  col+=tailLights(ray,t);
  fragColor=vec4(col,1.);
}