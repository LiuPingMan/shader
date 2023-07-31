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
vec4 N14(float t){
  return fract(sin(t*vec4(123.,1024.,3456.,5987.))*vec4(534.,3561.,5321.,789.));
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
  float s=1./10.;
  float m=0.;
  for(float i=0.;i<1.;i+=s){
    float ti=fract(t+i+side*s*.5);
    vec3 p=vec3(2.,2.,100.-ti*100.);
    m+=bokeh(ray,vec3(2.,2.,100.-ti*100.),.05,.1)*ti*ti*ti;
    m+=bokeh(ray,vec3(-2.,2.,100.-ti*100.),.05,.1)*ti*ti*ti;
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

// 环境光
vec3 envLights(Ray ray,float t){
  float side=step(ray.d.x,0.);
  ray.d.x=abs(ray.d.x);
  float s=1./10.;
  float m=0.;
  vec3 c=vec3(0.);
  for(float i=0.;i<1.;i+=s){
    float ti=fract(t+i+side*s*.5);
    vec4 n=N14(i);
    float fade=ti*ti*ti;
    float occlusion=sin(ti*6.28*10.*n.x)*.5+.5;
    fade=occlusion;
    float x=mix(2.5,10.,n.x);
    float y=mix(.1,1.5,n.y);
    vec3 p=vec3(x,y,50.-ti*50.);
    vec3 col=n.wzy;
    c+=bokeh(ray,p,.05,.1)*col*fade;
  }
  return c;
}
// 雨滴
vec2 rain(vec2 uv,float t){
  t*=40.;
  vec2 ratio=vec2(3.,1.);
  vec2 st=uv*ratio;
  vec2 id=floor(st);
  st.y+=t*.22;
  float n=fract(sin(id.x*713.32)*981.32);
  st.y+=n;
  uv.y+=n;
  // 更新id,保持一个子st坐标系里的id不变
  id=floor(st);
  st=fract(st)-.5;
  t+=fract(sin(id.x*713.32+id.y*387.22)*981.32)*6.283;
  float y=-sin(t+sin(t+sin(t)*.5))*.43;
  // 雨滴
  vec2 p1=vec2(0.,y);
  vec2 o1=(st-p1)/ratio;
  float d=length(o1);
  float m1=smoothstep(.07,.0,d);
  // 雨滴痕迹
  vec2 o2=(fract(uv*ratio.x*vec2(1.,2.))-.5)/vec2(1.,2.);
  d=length(o2);
  float m2=smoothstep(.3*(.5-st.y),.0,d)*smoothstep(-.1,.1,st.y-p1.y);
  // if(st.x>.47||st.y>.49)m1=1.;
  return vec2(m1*o1*40.+m2*o2*10.);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv.x*=iResolution.x/iResolution.y;
  
  vec2 m=iMouse.xy/iResolution.xy;
  float t=iTime*.05+m.x;
  
  vec3 camPos=vec3(.5,.2,.0);
  vec3 lookAt=vec3(.5,.2,1.);
  vec2 rainDistort=rain(uv*5.,t);
  rainDistort+=rain(uv*7.,t);
  uv.x+=sin(uv.y*70.)*.002;
  uv.y+=sin(uv.x*170.)*.001;
  Ray ray=getRay(uv-rainDistort*.2,camPos,lookAt,2.);
  vec3 col=streetLights(ray,t);
  col+=headLights(ray,t);
  col+=tailLights(ray,t);
  col+=envLights(ray,t);
  col+=(ray.d.y+.25)*vec3(.2,.1,.5);
  // col=vec3(rainDistort,0.);
  fragColor=vec4(col,1.);
}