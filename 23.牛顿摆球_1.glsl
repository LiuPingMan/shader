#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.001

struct Ray{
  vec3 ro,rd;
};

Ray getRay(vec2 uv,vec3 camPos,vec3 lookAt,float zoom){
  Ray ray;
  ray.ro=camPos;
  vec3 f=normalize(lookAt-camPos);
  vec3 r=normalize(cross(vec3(0.,1.,0.),f));
  vec3 u=normalize(cross(f,r));
  ray.rd=normalize(f*zoom+r*uv.x+u*uv.y);
  return ray;
}

mat2 rotate(float r){
  return mat2(cos(r),-sin(r),sin(r),cos(r));
}

float sdfSphere(vec3 p,vec4 sphere){
  return length(p-sphere.xyz)-sphere.w;
}

float sdfBox(vec3 p,vec3 b){
  vec3 q=abs(p)-b;
  return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}
float sdfBox(vec2 p,vec2 b){
  vec2 q=abs(p)-b;
  return length(max(q,0.))+min(max(q.x,q.y),0.);
}
/* 主体 */
float sdfBase(vec3 p){
  /* 底座 */
  float box=sdfBox(p,vec3(1,.1,.5))-.1;
  /* 支架 */
  float bar=length(vec2(sdfBox(p.xy,vec2(.8,1.4))-.15,abs(p.z)-.4))-.04;
  float d=min(box,bar);
  d=max(d,-p.y);
  return d;
}

float sdfRing(vec3 p,vec2 r){
  vec2 q=vec2(length(p.xy)-r.x,p.z);
  return length(q)-r.y;
}
float sdfLineSeg(vec3 p,vec3 a,vec3 b){
  vec3 ab=b-a,ap=p-a;
  float t=clamp(dot(ab,ap)/dot(ab,ab),0.,1.);
  vec3 c=a+t*ab;
  return length(p-c);
}
/* 小球 */
float sdfBall(vec3 p,float a){
  /* 摆动 */
  p.y-=1.;
  p.xy*=rotate(sin(a));
  p.y+=1.;
  /* 球体 */
  float sphere=length(p)-.15;
  /* 圆环 */
  float ring=sdfRing(p-vec3(0,.15,0),vec2(.03,.01));
  /* 线 */
  p.z=abs(p.z);
  float line=sdfLineSeg(p,vec3(0,.15,0),vec3(0,1,.4))-.005;
  float d=min(sphere,ring);
  d=min(d,line);
  return d;
}

float getDist(vec3 p){
  float base=sdfBase(p);
  float a=sin(3.*iTime);
  float a1=min(a,0.);
  float a5=max(a,0.);
  float b1=sdfBall(p-vec3(.6,.5,0),a1);
  float b2=sdfBall(p-vec3(.3,.5,0),(a+a1)*.05);
  float b3=sdfBall(p-vec3(0,.5,0),a*.05);
  float b4=sdfBall(p-vec3(-.3,.5,0),(a+a5)*.05);
  float b5=sdfBall(p-vec3(-.6,.5,0),a5);
  float balls=min(b1,min(b2,min(b3,min(b4,b5))));
  float d=min(base,balls);
  return d;
}

vec3 getNormal(vec3 p){
  float d=getDist(p);
  vec2 e=vec2(.01,0);
  vec3 n=d-vec3(getDist(p-e.xyy),getDist(p-e.yxy),getDist(p-e.yyx));
  return normalize(n);
}

float getLight(vec3 p){
  vec3 lightPos=vec3(5.,5.,-5.);
  vec3 n=getNormal(p);
  vec3 l=normalize(lightPos-p);
  float diff=clamp(dot(n,l),0.,1.);
  return diff;
}

float rayMarch(vec3 ro,vec3 rd){
  float ds=0.;
  for(int i=0;i<MAX_STEPS;i++){
    vec3 p=ro+ds*rd;
    float di=getDist(p);
    ds+=di;
    if(abs(di)<SURF_DIST||ds>MAX_DIST)break;
  }
  return ds;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec2 m=iMouse.xy/iResolution.xy;
  vec3 cameraPos=vec3(0.,0.,-3.);
  cameraPos.xz*=rotate(-m.x*6.2831);
  cameraPos.yz*=rotate(-m.y*3.1416+1.);
  vec3 lookAt=vec3(0.,1.,0.);
  Ray ray=getRay(uv,cameraPos,lookAt,1.);
  float d=rayMarch(ray.ro,ray.rd);
  vec3 col=vec3(0.);
  if(d<MAX_DIST){
    vec3 p=ray.ro+d*ray.rd;
    float light=getLight(p);
    col=vec3(light)*.9+.1;
  }
  col=pow(col,vec3(.4545));
  fragColor=vec4(col,1.);
}