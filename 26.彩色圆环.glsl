vec3 hash33(vec3 p3)
{
  p3=fract(p3*vec3(.1031,.11369,.13787));
  p3+=dot(p3,p3.yxz+19.19);
  return-1.+2.*fract(vec3(p3.x+p3.y,p3.x+p3.z,p3.y+p3.z)*p3.zyx);
}
float snoise3(vec3 p)
{
  const float K1=.333333333;
  const float K2=.166666667;
  
  vec3 i=floor(p+(p.x+p.y+p.z)*K1);
  vec3 d0=p-(i-(i.x+i.y+i.z)*K2);
  
  vec3 e=step(vec3(0.),d0-d0.yzx);
  vec3 i1=e*(1.-e.zxy);
  vec3 i2=1.-e.zxy*(1.-e);
  
  vec3 d1=d0-(i1-K2);
  vec3 d2=d0-(i2-K1);
  vec3 d3=d0-.5;
  
  vec4 h=max(.6-vec4(dot(d0,d0),dot(d1,d1),dot(d2,d2),dot(d3,d3)),0.);
  vec4 n=h*h*h*h*vec4(dot(d0,hash33(i)),dot(d1,hash33(i+i1)),dot(d2,hash33(i+i2)),dot(d3,hash33(i+1.)));
  
  return dot(vec4(31.316),n);
}

vec4 extractAlpha(vec3 colorIn)
{
  vec4 colorOut;
  float maxValue=min(max(max(colorIn.r,colorIn.g),colorIn.b),1.);
  if(maxValue>1e-5)
  {
    colorOut.rgb=colorIn.rgb*(1./maxValue);
    colorOut.a=maxValue;
  }
  else
  {
    colorOut=vec4(0.);
  }
  return colorOut;
}

float light1(float intensity,float attenuation,float dist){
  return intensity/(1.+dist*attenuation);
}
float light2(float intensity,float attenuation,float dist)
{
  return intensity/(1.+dist*dist*attenuation);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv*=2.;
  uv.x*=iResolution.x/iResolution.y;
  
  const vec3 color1=vec3(.611765,.262745,.996078);
  const vec3 color2=vec3(.298039,.760784,.913725);
  const vec3 color3=vec3(.062745,.078431,.600000);
  const float innerRadius=.6;
  const float noiseScale=.65;
  
  float ang=atan(uv.y,uv.x);
  float len=length(uv);
  float v0,v1,v2,v3,cl;
  float r0,d0,n0;
  float r,d;
  
  // ring
  n0=snoise3(vec3(uv*noiseScale,iTime*.5))*.5+.5;
  r0=mix(mix(innerRadius,1.,.4),mix(innerRadius,1.,.6),n0);
  d0=distance(uv,r0/len*uv);
  v0=light1(1.,10.,d0);
  v0*=smoothstep(r0*1.05,r0,len);
  cl=cos(ang+iTime*2.)*.5+.5;
  
  // high light
  float a=iTime*-1.;
  vec2 pos=vec2(cos(a),sin(a))*r0;
  d=distance(uv,pos);
  v1=light2(1.5,5.,d);
  v1*=light1(1.,50.,d0);
  
  // back decay
  v2=smoothstep(1.,mix(innerRadius,1.,n0*.5),len);
  
  // hole
  v3=smoothstep(innerRadius,mix(innerRadius,1.,.5),len);
  
  // color
  vec3 col=mix(color1,color2,cl);
  col=mix(color3,col,v0);
  col=(col+v1)*v2*v3;
  col.rgb=clamp(col.rgb,0.,1.);
  fragColor=vec4(vec3(col),1.);
}