#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.01

// 小球SDF
float sdfSphere(vec3 p,vec4 sphere){
  float d=length(p-sphere.xyz)-sphere.w;
  return d;
}

float getDist(vec3 p){
  float planeDist=p.y;
  // 并集
  float sphereDist_1=sdfSphere(p,vec4(0.,1.,6.,.5));
  float sphereDist_2=sdfSphere(p,vec4(.5,1.,6.,.5));
  float d1=min(sphereDist_1,sphereDist_2);
  
  // 并集
  float sphereDist_3=sdfSphere(p,vec4(1.5,1.,6.,.5));
  float sphereDist_4=sdfSphere(p,vec4(2.,1.,6.,.5));
  float d2=max(sphereDist_3,sphereDist_4);
  
  // 差集
  float sphereDist_5=sdfSphere(p,vec4(-1.5,1.,6.,.5));
  float sphereDist_6=sdfSphere(p,vec4(-2.,1.5,6.,.5));
  float d3=max(-sphereDist_5,sphereDist_6);
  
  float d=min(d1,planeDist);
  d=min(d,d2);
  d=min(d,d3);
  
  return d;
}

float rayMarch(vec3 ro,vec3 rd){
  float ds=0.;
  for(int i=0;i<MAX_STEPS;i++){
    vec3 p=ro+ds*rd;
    float di=getDist(p);
    ds+=di;
    if(ds>MAX_DIST||di<SURF_DIST)break;
  }
  return ds;
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
  vec3 lightPos=vec3(3.,5.,4.);
  lightPos.xz+=vec2(sin(iTime),cos(iTime));
  vec3 n=getNormal(p);
  vec3 l=normalize(lightPos-p);
  float dif=clamp(dot(n,l),0.,1.);
  float d=rayMarch(p+n*SURF_DIST*1.01,l);
  if(d<length(lightPos-p))dif*=.1;
  return dif;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  
  vec3 ro=vec3(0.,2.,0.);
  vec3 rd=normalize(vec3(uv.x,uv.y-.2,.5));
  
  float d=rayMarch(ro,rd);
  vec3 p=ro+d*rd;
  float dif=getLight(p);
  vec3 col=vec3(dif);
  fragColor=vec4(col,1.);
}