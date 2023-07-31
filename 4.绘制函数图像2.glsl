#define PI 3.141596
#define AA 4

vec2 transformUV(vec2 uv){
  return 6.*(2.*uv-iResolution.xy)/min(iResolution.x,iResolution.y);
}

// 绘制坐标系
vec3 drawGrid(vec2 uv){
  vec3 color=vec3(.4);
  vec2 grid=floor(mod(uv,2.));
  if(grid.x==grid.y)color=vec3(.6);
  color=mix(color,vec3(0.),smoothstep(1.1*fwidth(uv.x),fwidth(uv.x),abs(uv.x)));
  color=mix(color,vec3(0.),smoothstep(1.1*fwidth(uv.y),fwidth(uv.y),abs(uv.y)));
  return color;
}

float drawLineSegment(vec2 uv,vec2 start,vec2 end,float width){
  vec2 l1=end-start;
  vec2 l2=uv-start;
  vec2 l3=clamp(dot(l1,l2)/dot(l1,l1),0.,1.)*l1;
  float dis=length(l3-l2);
  float power=smoothstep(1.5*width,width,dis);
  return power;
}

float func(float x){
  return cos(PI*x+iTime);
}

float drawFunc(vec2 fragCoord){
  float p=0.;
  vec2 uv=transformUV(fragCoord.xy);
  float y=func(uv.x);
  for(int m=0;m<AA;m++){
    for(int n=0;n<AA;n++){
      vec2 offset=(vec2(float(m),float(n))-.5*float(AA))/float(AA)*2.;
      vec2 offsetXY=transformUV(fragCoord.xy+offset);
      p+=smoothstep(y-.01,y+.01,offsetXY.y);
    }
  }
  if(p>float(AA*AA)/2.)p=float(AA*AA)-p;
  p=2.*p/float(AA*AA);
  return p;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=transformUV(fragCoord.xy);
  vec3 color=drawGrid(uv);
  color=mix(color,vec3(1.),drawFunc(fragCoord.xy));
  fragColor=vec4(color,1.);
}