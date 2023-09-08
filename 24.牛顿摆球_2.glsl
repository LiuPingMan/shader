#iChannel0"./texture/cube/cube_{}.png"
#iChannel0::Type"CubeMap"
#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST.001

const int MAT_BASE=1;
const int MAT_BARS=2;
const int MAT_BALL=3;
const int MAT_LINE=4;

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
vec2 sdfBase(vec3 p){
  /* 底座 */
  float box=sdfBox(p,vec3(1,.1,.5))-.1;
  /* 支架 */
  float bar=length(vec2(sdfBox(p.xy,vec2(.8,1.4))-.15,abs(p.z)-.4))-.04;
  float d=min(box,bar);
  int mat = 0;
  if(d == box) {
    mat = MAT_BASE;
  }else if(d == bar){
    mat = MAT_BARS;
  }
  d=max(d,-p.y);
  return vec2(d, mat);
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
vec2 sdfBall(vec3 p,float a){
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
  float ball=min(sphere,ring);
  float d=min(ball,line);
  int mat=0;
  if(d==ball){
    mat=MAT_BALL;
  }else if(d==line){
    mat=MAT_LINE;
  }
  return vec2(d,mat);
}

vec2 MIN(vec2 a,vec2 b){
  return a.x<b.x?a:b;
}
vec2 getDist(vec3 p){
  vec2 base=sdfBase(p);
  float a=sin(3.*iTime);
  float a1=min(a,0.);
  float a5=max(a,0.);
  vec2 b1=sdfBall(p-vec3(.6,.5,0),a1);
  vec2 b2=sdfBall(p-vec3(.3,.5,0),(a+a1)*.05);
  vec2 b3=sdfBall(p-vec3(0,.5,0),a*.05);
  vec2 b4=sdfBall(p-vec3(-.3,.5,0),(a+a5)*.05);
  vec2 b5=sdfBall(p-vec3(-.6,.5,0),a5);
  vec2 balls=MIN(b1,MIN(b2,MIN(b3,MIN(b4,b5))));
  vec2 d=MIN(base,balls);
  return d;
}

vec3 getNormal(vec3 p){
  float d=getDist(p).x;
  vec2 e=vec2(.01,0);
  vec3 n=d-vec3(getDist(p-e.xyy).x,getDist(p-e.yxy).x,getDist(p-e.yyx).x);
  return normalize(n);
}

vec3 getLight(vec3 p,Ray ray){
  vec3 lightPos=vec3(5.,5.,-5.);
  vec3 n=getNormal(p);
  vec3 l=normalize(lightPos-p);
  vec3 diff=vec3(clamp(dot(n,l),0.,1.));
  vec3 col=vec3(0);
  vec3 r=reflect(ray.rd,n);
  vec3 ref=texture(iChannel0,r).rgb;
  return ref;
}

vec3 setMat(int mat){
  vec3 col=vec3(0);
  if(mat==MAT_BASE){
    col=vec3(.1);
  }else if(mat==MAT_BARS){
    col=vec3(1.);
  }else if(mat==MAT_BALL){
    col=vec3(1.);
  }else if(mat==MAT_LINE){
    col=vec3(.05);
  }
  return col;
}

vec2 rayMarch(vec3 ro,vec3 rd){
  float ds=0.;
  int mat=0;
  for(int i=0;i<MAX_STEPS;i++){
    vec3 p=ro+ds*rd;
    vec2 di=getDist(p);
    ds+=di.x;
    mat=int(di.y);
    if(abs(di.x)<SURF_DIST||ds>MAX_DIST)break;
  }
  return vec2(ds,mat);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec2 m=iMouse.xy/iResolution.xy;
  vec3 cameraPos=vec3(0.,0.,-3.);
  cameraPos.xz*=rotate(-m.x*6.2831);
  cameraPos.yz*=rotate(-m.y*3.1416+1.);
  vec3 lookAt=vec3(0.,1.,0.);
  Ray ray=getRay(uv,cameraPos,lookAt,1.);
  vec2 d=rayMarch(ray.ro,ray.rd);
  vec3 col=texture(iChannel0,ray.rd).rgb;
  if(d.x<MAX_DIST){
    vec3 p=ray.ro+d.x*ray.rd;
    vec3 light=getLight(p,ray);
    col=light;
    vec3 mat=setMat(int(d.y));
    col*=mat;
  }
  col=pow(col,vec3(.4545));
  fragColor=vec4(col,1.);
}