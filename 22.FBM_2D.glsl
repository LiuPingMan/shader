#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.01

mat2 rotate(float r){
  return mat2(cos(r),-sin(r),sin(r),cos(r));
}

float random(in vec2 st){
  float r=fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
  return r;
}
// 分形布朗运动（Fractal Brownian Motion）
float noise(in vec2 st){
  vec2 i=floor(st);
  vec2 f=fract(st);
  
  // Four corners in 2D of a tile
  float a=random(i);
  float b=random(i+vec2(1.,0.));
  float c=random(i+vec2(0.,1.));
  float d=random(i+vec2(1.,1.));
  
  vec2 u=f*f*(3.-2.*f);
  
  return mix(a,b,u.x)+
  (c-a)*u.y*(1.-u.x)+
  (d-b)*u.x*u.y;
}

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

// 获取点P到平面的最短距离
float getDist(vec3 p){
  float distPlane=dot(p,vec3(0.,1.,0.))-noise(p.xz);
  return distPlane;
}

float rayMarch(vec3 ro,vec3 rd){
  float di=0.;
  
  for(int i=0;i<MAX_STEPS;i++){
    vec3 p=ro+di*rd;
    float ds=getDist(p);
    di+=ds;
    if(di>MAX_DIST||abs(ds)<SURF_DIST)break;
  }
  return di;
}

vec3 getNormal(vec3 p){
  float d=getDist(p);
  vec2 e=vec2(.01,0.);
  vec3 n=d-vec3(
    getDist(p-e.xyy),
    getDist(p-e.yxy),
    getDist(p-e.yyx)
  );
  return normalize(n);
}

float getLight(vec3 p){
  vec3 lightPos=vec3(0.,5.,6.);
  vec3 l=normalize(lightPos-p);
  vec3 n=getNormal(p);
  float dif=clamp(dot(n,l),0.,1.);
  float d=rayMarch(p+n*SURF_DIST,l);
  if(d<length(lightPos-p))dif*=.1;
  return dif;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec2 m=iMouse.xy/iResolution.xy;
  vec3 cameraPos=vec3(0.,5.,-3.);
  cameraPos.yz*=rotate(-m.y*3.14+1.);
  cameraPos.xz*=rotate(-m.x*6.28);
  Ray ray=getRay(uv,cameraPos,vec3(0.,1.,0.),1.);
  vec3 rd=normalize(vec3(uv.x,uv.y,1.));
  float dist=rayMarch(ray.o,ray.d);
  vec3 p=ray.o+dist*ray.d;
  float dif=getLight(p);
  vec3 n=getNormal(p);
  vec3 col=vec3(dif);
  fragColor=vec4(col,1.);
}