#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.01

// 获取点P到平面或小球的最短距离
float getDist(vec3 p){
  vec4 sphere=vec4(0.,1.,6.,1.);
  float distPlane=p.y;
  float distSphere=length(sphere.xyz-p)-sphere.w;
  return min(distPlane,distSphere);
}

float rayMarch(vec3 ro,vec3 rd){
  float di=0.;
  
  for(int i=0;i<MAX_STEPS;i++){
    vec3 p=ro+di*rd;
    float ds=getDist(p);
    di+=ds;
    if(di>MAX_DIST||ds<SURF_DIST)break;
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
  lightPos.xz+=vec2(sin(iTime),cos(iTime));
  vec3 l=normalize(lightPos-p);
  vec3 n=getNormal(p);
  float dif=clamp(dot(n,l),0.,1.);
  float d=rayMarch(p+n*SURF_DIST,l);
  if(d<length(lightPos-p))dif*=.1;
  return dif;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec3 ro=vec3(0.,1.,0.);
  vec3 rd=normalize(vec3(uv.x,uv.y,1.));
  float dist=rayMarch(ro,rd);
  vec3 p=ro+dist*rd;
  float dif=getLight(p);
  vec3 col=vec3(dif);
  fragColor=vec4(col,1.);
}