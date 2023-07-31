#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.01

// 小球SDF
float sdfSphere(vec3 p,vec4 sphere){
  float d=length(p-sphere.xyz)-sphere.w;
  return d;
}

// 胶囊SDF
float sdfCapsule(vec3 p,vec3 a,vec3 b,float r){
  vec3 ab=b-a;
  vec3 ap=p-a;
  float t=dot(ab,ap)/dot(ab,ab);
  t=clamp(t,0.,1.);
  vec3 c=a+t*ab;
  return length(p-c)-r;
}

// 圆环SDF
float sdfTorus(vec3 p,vec2 r){
  vec2 q=vec2(length(p.xz)-r.x,p.y);
  return length(q)-r.y;
}

// 盒子SDF
float sdfBox(vec3 p,vec3 b){
  vec3 q=abs(p)-b;
  return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}

// 圆柱体
float sdfCylinder(vec3 p,vec3 a,vec3 b,float r){
  vec3 ab=b-a;
  vec3 ap=p-a;
  float t=dot(ap,ab)/dot(ab,ab);
  vec3 c=a+t*ab;
  
  float x=length(p-c)-r;
  float y=(abs(t-.5)-.5)*length(ab);
  return length(max(vec2(x,y),0.))+min(max(x,y),0.);
}

float getDist(vec3 p){
  float planeDist=p.y;
  float sphereDist=sdfSphere(p,vec4(0.,1.,6.,1.));
  float capsuleDist=sdfCapsule(p,vec3(-2.8,1.,6.),vec3(-2.3,2.5,7.),.2);
  float torusDist=sdfTorus(p-vec3(2.5,.5,6.),vec2(.8,.3));
  float boxDist=sdfBox(p-vec3(-2.5,.5,9.),vec3(.5,.5,.5));
  float cylinderDist=sdfCylinder(p,vec3(1.8,1.5,6.),vec3(1.3,3.,7.),.3);
  float d=min(planeDist,sphereDist);
  d=min(d,capsuleDist);
  d=min(d,torusDist);
  d=min(d,boxDist);
  d=min(d,cylinderDist);
  
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
  vec3 rd=normalize(vec3(uv.x,uv.y-.2,1.));
  
  float d=rayMarch(ro,rd);
  vec3 p=ro+d*rd;
  float dif=getLight(p);
  vec3 col=vec3(dif);
  fragColor=vec4(col,1.);
}