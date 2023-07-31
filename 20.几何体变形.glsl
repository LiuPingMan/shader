#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.01

mat2 Rot(float a){
  return mat2(cos(a),-sin(a),sin(a),cos(a));
}

// 盒子SDF
float sdfBox(vec3 p,vec3 b){
  vec3 q=abs(p)-b;
  float d=length(max(q,0.))+min(max(max(q.x,q.y),q.z),0.);
  return d;
}

float getDist(vec3 p){
  
  /* 切割 */
  // 切割面
  float cutPlaneDist=dot(p-vec3(0.,1.,10.),normalize(vec3(1.,1.,-1.)))-.5;
  float boxDist_1=sdfBox(p-vec3(0.,1.,10.),vec3(1.,1.,1.));
  float d1=max(cutPlaneDist,boxDist_1);
  
  // 带厚度的盒子
  float boxDist_2=sdfBox(p-vec3(2.5,1.,12.),vec3(1.,1.,1.));
  boxDist_2=abs(boxDist_2)-.1;
  float d2=max(boxDist_2,cutPlaneDist);
  
  // 波浪面
  vec3 box3Pos=p-vec3(-2.5,1.,10.);
  box3Pos.z+=sin(p.x*10.)*.03;
  float boxDist_3=sdfBox(box3Pos,vec3(1.,1.,1.));
  
  // 缩放
  vec3 box4Pos=p-vec3(-5.,2.,10.);
  float scale=mix(1.,3.,smoothstep(-1.,1.,box4Pos.y));
  box4Pos.xz*=scale;
  float boxDist_4=sdfBox(box4Pos,vec3(1.,2.,1.))/scale;
  
  // 扭曲
  vec3 box5Pos=p-vec3(5.,2.,10.);
  box5Pos.xz*=Rot(box5Pos.y);
  float boxDist_5=sdfBox(box5Pos,vec3(1.,2.,1.));
  
  // 对称
  vec3 box6Pos=p-vec3(0.,-2.,0.);
  vec3 n=normalize(vec3(1.,-1.,0.));
  box6Pos-=2.*n*min(dot(n,p),0.);
  float boxDist_6=sdfBox(box6Pos,vec3(1.,2.,1.));
  
  float d=d1;
  d=min(d,d2);
  d=min(d,boxDist_3);
  d=min(d,boxDist_4);
  d=min(d,boxDist_5);
  d=min(d,boxDist_6);
  
  return d;
}

float rayMarch(vec3 ro,vec3 rd){
  float ds=0.;
  for(int i=0;i<MAX_STEPS;i++){
    vec3 p=ro+ds*rd;
    float di=getDist(p);
    ds+=di;
    if(ds>MAX_DIST||abs(di)<SURF_DIST)break;
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
  vec3 lightPos=vec3(0.,6.,-6.);
  // lightPos.xz+=vec2(sin(iTime),cos(iTime))*5.;
  vec3 n=getNormal(p);
  vec3 l=normalize(lightPos-p);
  float dif=clamp(dot(n,l),0.,1.);
  float d=rayMarch(p+n*SURF_DIST*2.,l);
  if(d<length(lightPos-p))dif*=.1;
  return dif;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  
  vec3 ro=vec3(0.,2.,-20.);
  vec3 rd=normalize(vec3(uv.x,uv.y-.2,1.));
  
  float d=rayMarch(ro,rd);
  vec3 p=ro+d*rd;
  float dif=getLight(p);
  vec3 col=vec3(dif);
  fragColor=vec4(col,1.);
}