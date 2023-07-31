#define PI 3.141596

vec2 transformUV(vec2 uv){
  return 6.*(2.*uv-iResolution.xy)/min(iResolution.x,iResolution.y);
}

vec3 drawGrid(vec2 uv){
  vec2 subdivision=fract(uv);
  vec3 color=vec3(1.-step(fwidth(uv.x),abs(subdivision.x)));
  color+=vec3(1.-step(fwidth(uv.y),abs(subdivision.y)));
  color+=vec3(1.-step(fwidth(uv.x),abs(uv.x)),0.,0.);
  color+=vec3(0.,1.-step(fwidth(uv.y),abs(uv.y)),0.);
  if(color.x>1.){
    color-=vec3(1.);
  }
  if(color.y>1.){
    color-=vec3(1.);
  }
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

float drawFunc(vec2 uv){
  float power=0.;
  for(float x=0.;x<=iResolution.x;x+=1.){
    float fx=transformUV(vec2(x,0.)).x;
    float nfx=transformUV(vec2(x+1.,0.)).x;
    power+=drawLineSegment(uv,vec2(fx,func(fx)),vec2(nfx,func(nfx)),fwidth(uv.x));
  }
  power=clamp(power,0.,1.);
  return power;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=transformUV(fragCoord.xy);
  vec3 color=drawGrid(uv);
  color=mix(color,vec3(1.,1.,0.),drawFunc(uv));
  fragColor=vec4(color,1.);
}